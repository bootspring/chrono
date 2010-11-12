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
      @conn.token_auth token
    end

    def store(metric, value)
      write({ :at => Time.now.utc, :k => metric, :v => value.to_f })
    end

    private

    def write(options)
      @conn.post '/metrics' do |req|
        req.body = options
      end
    end

  end
end