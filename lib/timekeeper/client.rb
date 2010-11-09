require 'socket'
require 'faraday'

module Timekeeper
  class Client

    def initialize(location='http://localhost:31313')
      @conn = Faraday::Connection.new(:url => location) do |builder|
        builder.request  :yajl
        builder.adapter  :logger
        builder.adapter  :typhoeus
        builder.response :yajl
      end
    end
    
    def store(metric, value)
      write({ :time => Time.now.utc, :host => Socket.gethostname, :name => metric, :val => value.to_f })
    end

    private

    def write(options)
      @conn.post '/metrics' do |req|
        req.body = options
      end
    end

  end
end