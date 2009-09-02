require 'rack/utils'

module Rack::Cache::Tools
  class Key
    include Rack::Utils

    # Implement .call, since it seems like the "Rack-y" thing to do. Plus, it
    # opens the door for cache key generators to just be blocks.
    def self.call(*args)
      new(*args).generate
    end

    def initialize(request, uri = nil)
      self.request = request
      self.uri = uri if uri
    end

    attr_reader :request, :uri

    def source
      @source ||= uri || request
    end
    
    %w(scheme host port path query script_name).each do |method|
      class_eval "def #{method}; source.#{method}; end"
    end

    def generate
      parts = []
      parts << scheme << "://"
      parts << host
      parts << ":" << port.to_s if irregular_port?
      parts << script_name
      parts << path
      parts << "?" << normalize_query(query) unless query.nil? || query.empty?
      parts.join
    end

    protected

      def request=(request)
        @request = Request.new(request)
      end

      def uri=(uri)
        uri  = URI.parse(uri) unless uri.respond_to?(:scheme)
        @uri = Uri.new(uri)
        expand_relative_uri!
      end

      def expand_relative_uri!
        uri.scheme ||= request.scheme
        uri.host   ||= request.host
        uri.port   ||= request.port
      end

      def irregular_port?
        scheme == "https" && port != 443 || scheme == "http" && port != 80
      end

      def normalize_query(query)
        query.
          split(/[&;] */n).
          map { |p| unescape(p).split('=', 2) }.
          sort.
          map { |k,v| "#{escape(k)}=#{escape(v)}" }.
          join('&')
      end

      # simple adapters to straighten URI and Rack::Request APIs 
      class Adapter
        def initialize(target)
          @target = target
        end

        def method_missing(*args, &block)
          @target.send(*args, &block)
        end
      end
    
      class Uri < Adapter
        def script_name
          nil
        end
      end
    
      class Request < Adapter
        def path
          @target.path_info
        end
      
        def query
          @target.query_string
        end
      end
  end
end
