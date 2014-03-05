require 'http_router/route'
require 'lotus/routing/path'

module Lotus
  module Routing
    # Entry of the routing system
    #
    # @api private
    #
    # @since 0.1.0
    #
    # @see http://rdoc.info/gems/http_router/HttpRouter/Route
    #
    # @example
    #   require 'lotus/router'
    #
    #   router = Lotus::Router.new
    #   router.get('/', to: endpoint) # => #<Lotus::Routing::Route:0x007f83083ba028 ...>
    class Route < HttpRouter::Route
      DEFAULT_VERBS = [:get, :head]

      attr_accessor :_path, :_verbs, :_endpoint, :_compiled_path

      def initialize(path: nil, verbs: DEFAULT_VERBS, options: {})
        @_path     = path
        @_verbs    = Array(verbs)
        @_endpoint = options[:endpoint]
        @_compiled_path = nil
        @_fixed         = true

        # TODO remove this conditional once the refactoring will be done
        if @_path
          path = Path.new(@_path, options)
          @_compiled_path = path.compiled
          @_fixed         = path.fixed?
        end
      end

      # Asks the given resolver to return an endpoint that will be associated
      #   with the other options.
      #
      # @param resolver [Lotus::Routing::EndpointResolver, #resolve] this may change
      #   according to the :resolve option passed to Lotus::Router#initialize.
      #
      # @param options [Hash] options to customize the route
      # @option options [Symbol] :as the name we want to use for the route
      #
      # @since 0.1.0
      #
      # @api private
      #
      # @see Lotus::Router#initialize
      #
      # @example
      #   require 'lotus/router'
      #
      #   router = Lotus::Router.new
      #   router.get('/', to: endpoint, as: :home_page).name # => :home_page
      #
      #   router.path(:home_page) # => '/'
      def generate(resolver, options = {}, &endpoint)
        self.to   = resolver.resolve(options, &endpoint)
        self.name = options[:as].to_sym if options[:as]
        self
      end

      def fixed?
        @_fixed
      end

      private
      def to=(dest = nil, &blk)
        self.to dest, &blk
      end
    end
  end
end
