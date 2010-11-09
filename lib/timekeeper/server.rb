require 'mongo'
require 'sinatra/base'
require 'yajl'

module Timekeeper
  class Server < Sinatra::Base
    set :sessions, false

    get '/' do
      "Timekeeper v#{Timekeeper::VERSION}"
    end
    
    post '/metrics' do
      write(params)
      201
    end
    
    get '/query' do
      p params
      query = {}
      query['time'] = { "$gte" => Time.at(Integer(params['start_time'])), "$lt" => Time.at(Integer(params['end_time'])) }
      coll = connection.collection(params['name'])
      Yajl::Encoder.encode coll.find(query).to_a
    end

    private

    def write(options)
      options['time'] = Time.at(Integer(options['time']))
      options['val'] = Float(options['val'])
      coll = connection.collection(options['name'])
      coll.insert(options)
    end
    
    def connection
      @db ||= Mongo::Connection.new.db('metrics')
    end 

  end
end