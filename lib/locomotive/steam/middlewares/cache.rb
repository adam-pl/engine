puts "[KOALA] loading cache..."
module Locomotive
  module Steam
    module Middlewares

      class Cache

        attr_reader :app

        CACHEABLE_REQUEST_METHODS = %w(GET HEAD).freeze

        def initialize(app)
          @app = app
        end

        def call(env)
          if cacheable?(env)
            fetch_cached_response(env)
          else
            app.call(env)
          end
        end

        private

        def fetch_cached_response(env)
          key = cache_key(env)

          if marshaled = Rails.cache.read(key)
            Rails.logger.info "CACHE INFO :: read key OK :: Cache.fetch_cached_response() :: key -> #{key}"
            Marshal.load(marshaled)
          else
            Rails.logger.info "CACHE INFO :: read key NOT OK:: Cache.fetch_cached_response() :: key -> #{key}"
            app.call(env).tap do |response|
              Rails.logger.warn "CACHE INFO :: write key -> #{key}"
              Rails.cache.write(key, marshal(response))
            end
          end
        end

        def marshal(response)
          code, headers, body = response

          # only keep string value headers
          _headers = headers.reject { |key, val| !val.respond_to?(:to_str) }

          Marshal.dump([code, _headers, body])
        end

        def cacheable?(env)
          CACHEABLE_REQUEST_METHODS.include?(env['REQUEST_METHOD']) &&
          !env['steam.live_editing'] &&
          env['steam.site'].try(:cache_enabled) &&
          env['steam.page'].try(:cache_enabled) &&
          is_redirect_url?(env['steam.page'], env['steam.locale'])
        end

        def cache_key(env)
          site, path, query = env['steam.site'], env['PATH_INFO'], env['QUERY_STRING']
          key = "#{Locomotive::VERSION}/site/#{site._id}/#{site.last_modified_at.to_i}/page/#{path}/#{query}"
          Digest::MD5.hexdigest(key)
        end

        def is_redirect_url?(page, locale)
          return false if page.nil?
          (page.try(:redirect_url) || {})[locale].blank?
        end

      end

    end
  end
end
puts "[KOALA] loaded cache"