# frozen_string_literal: true

require 'wisper'

module ProxES
  module Middleware
    class Metrics
      include Wisper::Publisher

      def initialize(app)
        @app = app
      end

      def call(env)
        request = Request.from_env(env)
        broadcast(:call_started, request)

        result = @app.call request.env

        broadcast(:call_completed, request) if result[0].to_i >= 200 && result[0].to_i < 300
        result
      end
    end
  end
end
