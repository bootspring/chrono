require 'mongo'
require 'sinatra/base'
require 'yajl'
require 'timekeeper/auth/token'

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
      p params
      coll = connection.collection(params['name'])
      Yajl::Encoder.encode coll.find(query_for(params)).to_a
    end
    
    delete '/metrics' do
      coll = connection.collection(params['name'])
      coll.remove(query_for(params))
    end

    private

    def query_for(params)
      query = {}
      query['time'] = {} if params['start_time'] || params['end_time']
      query['time']["$gte"] = time('start_time') if params['start_time']
      query['time']["$lt"] = time('end_time') if params['end_time']
      query
    end

    def time(name)
      Time.at(Integer(params[name]))
    end

    def write
      params['time'] = time('time')
      params['val'] = Float(params['val'])
      coll = connection.collection(params['name'])
      coll.insert(params)
    end
    
    def connection
      @metrics ||= Mongo::Connection.new.db('metrics')
    end 

  end
end