# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/object/blank'
require 'ditty/services/logger'
require 'proxes/models/permission'
require 'proxes/helpers/indices'

module ProxES
  class RequestPolicy
    include Helpers::Indices

    attr_reader :user, :record
    alias request record

    def initialize(user, record)
      @user = user
      @record = record
    end

    def method_missing(method_sym, *arguments, &block)
      return super if method_sym.to_s[-1] != '?'

      return false if request.indices? && !index_allowed?
      action_allowed? method_sym[0..-2].upcase
    end

    def respond_to_missing?(name, _include_private = false)
      name[-1] == '?'
    end

    def index_allowed?
      patterns = patterns_for('INDEX').map do |permission|
        return nil if permission.pattern.blank?
        permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
      end
      filter(request.index, patterns).count > 0
    end

    def action_allowed?(action)
      # Give me all the user's permissions that match the verb
      patterns_for(action).each do |permission|
        return true if request.path =~ /#{permission.pattern}/
      end
      false
    end

    class Scope
      include Helpers::Indices

      attr_reader :user, :scope
      alias request scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        return [] if user.nil?
        filter request.index, patterns
      end
    end
  end
end
