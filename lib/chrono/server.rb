require 'mongo'
require 'sinatra/base'
require 'yajl'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'
require 'chronic'

module Chrono
  class Server < Sinatra::Base
    set :sessions, false
    set :public, File.dirname(__FILE__) + '/../../public'
    
    configure do
      Time.zone = "UTC"
      Chronic.time_class = Time.zone
    end
    
    get '/' do
      "Chrono v#{Chrono::VERSION}"
    end
    
    post '/metrics' do
      authorize do
        write
        201
      end
    end
    
    get '/metrics' do
      authorize do
        name = params[:name] || params[:k]
        coll = metrics_db.collection(name)
        results = []
        coll.find(query, :fields => %w(k v at)) do |cursor|
          results = cursor.map { |x| x.delete('_id'); x }
        end
        content_type 'application/json'
        expires 300, :public
        Yajl::Encoder.encode results
      end
    end
    
    delete '/metrics' do
      authorize do
        coll = metrics_db.collection(params['k'])
        coll.remove(query)
      end
    end

    post '/applications' do
      apps = master_db.collection('applications')
      apps.create_index('token', :unique => true)
      apps.insert(params)
      201
    end
    
    get '/applications' do
      apps = master_db.collection('applications')
      apps.find.to_a.inspect
    end

    private

    def authorize
      token = params['token']
      return halt(401, 'No token provided') unless token

      coll = master_db.collection('applications')
      app = coll.find_one('token' => token)
      if app
        env['REMOTE_USER'] = token
        yield
      else
        halt(402, 'Unauthorized, please verify token')
      end
    end

    def query
      query = {}
      query['at'] = {} if params['start_time'] || params['end_time']
      query['at']["$gte"] = chronic('start_time') if params['start_time']
      query['at']["$lt"] = chronic('end_time') if params['end_time']
      query
    end

    def time(name)
      Time.at(Integer(params[name])).utc
    end

    def chronic(name)
      parsed = Chronic.parse(params[name])
      parsed ? parsed.time : Time.at(Integer(params[name])).utc
    end

    def write
      doc = { :at => time('at'), :v => params['v'].to_f, :ip => ip(env['REMOTE_ADDR']), :k => params['k'] }
      coll = metrics_db.collection(doc[:k])
      coll.insert(doc)
    end
    
    def metrics_db
      @metrics ||= Mongo::Connection.new
      @metrics.db('metrics')
    end

    def master_db
      @master ||= Mongo::Connection.new
      @master.db("chrono_#{environment}")
    end

    def ip(str)
      str.split('.').inject(0) { |i, a| i << 8 | a.to_i }
    end
    
    def environment
      self.class.environment
    end
  end
end