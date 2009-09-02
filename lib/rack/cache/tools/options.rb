module Rack::Cache::Tools
  module Options
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      # Configuration options and utility methods for option access. Rack::Cache
      # uses the Rack Environment to store option values. All options documented
      # below are stored in the Rack Environment as "rack-cache.<option>", where
      # <option> is the option name.

      def option_accessor(key)
        name = option_name(key)
        define_method(key) { || options[name] }
        define_method("#{key}=") { |value| options[name] = value }
        define_method("#{key}?") { || !! options[name] }
      end

      def option_name(key)
        case key
        when Symbol ; "rack-cache.#{key}"
        when String ; key
        else raise ArgumentError
        end
      end
    end
    include ClassMethods

    attr_reader :default_options

    def options
      @env || default_options
    end

    # Set multiple options.
    def options=(hash={})
      hash.each { |key,value| write_option(key, value) }
    end

    # Set an option. When +option+ is a Symbol, it is set in the Rack
    # Environment as "rack-cache.option". When +option+ is a String, it
    # exactly as specified. The +option+ argument may also be a Hash in
    # which case each key/value pair is merged into the environment as if
    # the #set method were called on each.
    def set(option, value=self, &block)
      if block_given?
        write_option option, block
      elsif value == self
        self.options = option.to_hash
      else
        write_option option, value
      end
    end

    protected

      def initialize_options(options = {}, default_options = {})
        @default_options = default_options
        self.options = options
      end

      def read_option(key)
        options[option_name(key)]
      end

      def write_option(key, value)
        options[option_name(key)] = value
      end
  end
end