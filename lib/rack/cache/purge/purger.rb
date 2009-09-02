module Rack::Cache::Purge
  class Purger
    attr_reader :cache

    def initialize(cache)
      @cache = cache
    end

    def purge(request, *args)
      case args.first
      when NilClass
        purge_by_request(request)
      when Rack::Cache::Response
        purge_by_uris(request, args.first.headers[PURGE_HEADER])
      else
        purge_by_uris(request, args)
      end
    end

    protected
    
      def purge_by_request(request)
        key = metastore.cache_key(request)
        do_purge(key)
      end
      
      def purge_by_uris(request, uris)
        normalize_uris(uris).each do |uri|
          key = Rack::Cache::Tools::Key.call(request, uri)
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
        uri = cache.env['rack-cache.metastore']
        storage.resolve_metastore_uri(uri)
      end

      def entitystore
        uri = cache.env['rack-cache.entitystore']
        storage.resolve_metastore_uri(uri)
      end

      def storage
        Rack::Cache::Storage.instance
      end
  end
end