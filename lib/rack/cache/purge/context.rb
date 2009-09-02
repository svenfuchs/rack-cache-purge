module Rack::Cache::Purge
  class Context
    include Rack::Cache::Tools::Options

    # Enable http purge support, disabled by default
    option_accessor :allow_http_purge

    attr_reader :env, :request

    def initialize(backend, options = {})
      @backend = backend

      initialize_options(options,
        'rack-cache.allow_http_purge' => false,
        'rack-cache.purger'           => purger
      )

      yield self if block_given?
    end

    def call(env)
      # hmmm ...
      @env = env.merge('rack-cache.allow_http_purge' => allow_http_purge?, 'rack-cache.purger' => purger)
      @request = Rack::Cache::Request.new(env)

      response =
        if http_purge? && allow_http_purge?
          http_purge
        else
          forward
        end

      purger.purge(response) if response.headers.key?(PURGE_HEADER)

      response.to_a
    end

    def purger
      @purger ||= Purger.new(self)
    end

    protected

      def forward
        Rack::Cache::Response.new(*@backend.call(@env))
      end

      def http_purge?
        @env['REQUEST_METHOD'] == 'PURGE'
      end

      def http_purge
        purger.purge(@request)
        Rack::Cache::Response.new(200, {}, 'Purged')
      end
  end
end