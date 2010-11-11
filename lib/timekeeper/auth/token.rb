require 'rack/auth/abstract/handler'
require 'rack/auth/abstract/request'

module Rack
  module Auth
    class Token
      
      class Request < Rack::Auth::AbstractRequest
        def token?
          :token == scheme && token
        end
        
        def credentials
          @credentials ||= parse(params)
        end

        def token
          credentials['token']
        end
        
        private

        def parse(str)
          split_header_value(str).inject({}) do |header, param|
            k, v = param.split('=', 2)
            header[k] = dequote(v)
            header
          end
        end

        def dequote(str) # From WEBrick::HTTPUtils
          ret = (/\A"(.*)"\Z/ =~ str) ? $1 : str.dup
          ret.gsub!(/\\(.)/, "\\1")
          ret
        end

        def split_header_value(str)
          str.scan( /(\w+\=(?:"[^\"]+"|[^,]+))/n ).collect{ |v| v[0] }
        end
      end
      
    end
  end
end

module Timekeeper
  module Auth
    module Token
      
      def self.included(base)
        base.instance_eval do

          before(/\/metrics/) do
            auth = ::Rack::Auth::Token::Request.new(env)
            return halt(401, 'No authentication header provided') unless auth.provided?
            return halt(401, 'No token provided') unless auth.token?

            if valid?(auth.token)
              env['REMOTE_USER'] = auth.token
            else
              halt(402, 'Unauthorized, please verify token')
            end
          end

          helpers do
            def valid?(token)
              coll = master_db.collection('applications')
              result = coll.find_one('token' => token)
              p result
              result
            end
          end

        end
      end

    end
  end
end