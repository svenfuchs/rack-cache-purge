module Rack::Cache::Purge
  class Context
    include Rack::Cache::Tools::Options

    PURGE_HEADER = 'X-Cache-Purge'

    # Enable http purge support, disabled by default
    option_accessor :allow_http_purge

    def initialize(backend, options = {})
      @backend = backend

      initialize_options(options,
        'rack-cache.allow_http_purge' => false
      )

      yield self if block_given?
    end

    def call(env)
      @env = env
      @request = Rack::Cache::Request.new(env)

      response =
        if http_purge? && allow_http_purge?
          http_purge
        else
          forward
        end

      purge_by_header(response) if response.headers.key?(PURGE_HEADER)

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
        key = metastore.cache_key(@request)
        metastore.purge(key)
        Rack::Cache::Response.new(200, {}, 'Purged')
      end

      def purge_by_header(response)
        each_purge_header_uri(response) do |uri|
          key = key(uri)
          metastore.purge(key)
        end
      end

      def each_purge_header_uri(response)
        uris = Array(response.headers[PURGE_HEADER])
        uris = uris.join("\n").split("\n")
        uris.each { |uri| yield(uri) }
      end

      def key(uri)
        uri = URI.parse(uri) unless uri.respond_to?(:scheme)
        expand_relative_uri(uri)

        parts = []
        parts << uri.scheme << "://"
        parts << uri.host
        parts << ":" << uri.port.to_s if irregular_port?(uri)
        parts << uri.path
        parts << "?" << uri.query if uri.query
        parts.join
      end

      def expand_relative_uri(uri)
        uri.scheme ||= @request.scheme
        uri.host ||= @request.host
        uri.port ||= @request.port
      end

      def irregular_port?(uri)
        uri.scheme == "https" && uri.port != 443 ||
        uri.scheme == "http" && uri.port != 80
      end

      def metastore
        uri = @env['rack-cache.metastore']
        storage.resolve_metastore_uri(uri)
      end

      def storage
        Rack::Cache::Storage.instance
      end
  end
end