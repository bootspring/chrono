require 'socket'
require 'faraday'

module Timekeeper
  class Client

    def initialize(token, location='http://localhost:31313')
      @conn = Faraday::Connection.new(:url => location) do |builder|
        builder.request  :yajl
        builder.adapter  :logger
        builder.adapter  :typhoeus
        builder.response :yajl
      end
      # http://coderrr.wordpress.com/2008/05/28/get-your-local-ip-address/
      @ip = UDPSocket.open {|s| s.connect('65.59.196.211', 1); s.addr.last }
      @conn.token_auth key
    end
    
    def store(metric, value)
      write({ :time => Time.now.utc, :ip => @ip, :name => metric, :val => value.to_f })
    end

    private

    def write(options)
      @conn.post '/metrics' do |req|
        req.body = options
      end
    end

  end
end