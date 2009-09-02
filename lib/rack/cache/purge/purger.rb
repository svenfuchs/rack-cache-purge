module Rack::Cache::Purge
  class Purger
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def purge(arg)
      case arg
      when Rack::Request
        purge_by_request(arg)
      when Rack::Cache::Response
        purge_by_uris(arg.headers[PURGE_HEADER])
      else
        purge_by_uris(arg)
      end
    end

    protected
    
      def purge_by_request(request)
        key = metastore.cache_key(request)
        do_purge(key)
      end
      
      def purge_by_uris(uris)
        normalize_uris(uris).each do |uri|
          key = Rack::Cache::Tools::Key.call(context.request, uri)
          do_purge(key)
        end
      end
      
      def normalize_uris(uris)
        Array(uris).flatten.join("\n").split("\n")
      end
      
      def do_purge(key)
        metastore.purge(key)
        entitystore.purge(key)
      end

      def metastore
        uri = context.env['rack-cache.metastore']
        storage.resolve_metastore_uri(uri)
      end

      def entitystore
        uri = context.env['rack-cache.entitystore']
        storage.resolve_metastore_uri(uri)
      end

      def storage
        Rack::Cache::Storage.instance
      end
  end
end