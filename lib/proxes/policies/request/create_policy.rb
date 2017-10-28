# frozen_string_literal: true

require 'proxes/policies/request_policy'

module ProxES
  class Request
    class CreatePolicy < RequestPolicy
      class Scope < RequestPolicy::Scope
        def resolve
          return [] if user.nil?

          patterns = Permission.for_user(user, 'INDEX').map do |permission|
            permission.pattern.gsub(/\{user.(.*)\}/) { |_match| user.send(Regexp.last_match[1].to_sym) }
          end
          filter(request.index, patterns).count > 0 ? request.index : []
        end
      end
    end
  end
end
