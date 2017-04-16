# frozen_string_literal: true
require 'proxes/db'
require 'proxes/models/permission'
require 'proxes/services/logger'
require 'proxes/helpers/indices'

module ProxES
  class RequestPolicy
    include Helpers::Indices

    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def method_missing(method_sym, *arguments, &block)
      if method_sym.to_s[-1] == '?'
        return false if user.nil?

        if record.indices?
          return true if index_allowed?
        else
          return true if action_allowed? method_sym[0..-2].upcase
        end
        false
      else
        super
      end
    end

    def user_permissions(action)
      this_user = user
      Permission.where(verb: action).where{Sequel.|({role: this_user.roles}, {user_id: this_user.id})}
    end

    def index_allowed?
      patterns = user_permissions('INDEX').map do |permission|
        permission.pattern.gsub(/\{user.(.*)\}/) { |match| user.send(Regexp.last_match[1].to_sym) }
      end
      return filter(record.index, patterns).count.positive?
    end

    def action_allowed?(action)
      # Give me all the user's permissions that match the verb
      user_permissions(action).each do |permission|
        return true if record.path =~ %r{#{permission.pattern}}
      end
      false
    end

    def respond_to_missing?(name, _include_private = false)
      name[-1] == '?'
    end

    def logger
      @logger ||= ProxES::Services::Logger.instance
    end

    class Scope
      include Helpers::Indices

      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def logger
        @logger ||= ProxES::Services::Logger.instance
      end
    end
  end
end

require 'proxes/policies/request/root_policy'
require 'proxes/policies/request/stats_policy'
require 'proxes/policies/request/search_policy'
require 'proxes/policies/request/snapshot_policy'
