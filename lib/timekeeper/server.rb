require 'mongo'
require 'sinatra/base'
require 'yajl'
require 'timekeeper/auth/token'
require 'ipaddr'

module Timekeeper
  class Server < Sinatra::Base
    set :sessions, false
    
    include Timekeeper::Auth::Token

    get '/' do
      "Timekeeper v#{Timekeeper::VERSION}"
    end
    
    post '/metrics' do
      write
      201
    end
    
    get '/query' do
      coll = connection.collection(params['k'])
      Yajl::Encoder.encode coll.find(query_for(params)).to_a
    end
    
    delete '/metrics' do
      coll = connection.collection(params['k'])
      coll.remove(query_for(params))
    end

    private

    def query_for(params)
      query = {}
      query['at'] = {} if params['start_time'] || params['end_time']
      query['at']["$gte"] = time('start_time') if params['start_time']
      query['at']["$lt"] = time('end_time') if params['end_time']
      query
    end

    def time(name)
      Time.at(Integer(params[name]))
    end

    def write
      params['at'] = time('at')
      params['v'] = params['v'].to_f
      params['ip'] = ip(env['REMOTE_ADDR'])
      coll = connection.collection(params['k'])
      coll.insert(params)
    end
    
    def connection
      @metrics ||= Mongo::Connection.new.db('metrics')
    end 

    def ip(str)
      str.split('.').inject(0) { |i, a| i << 8 | a.to_i }
    end
  end
end