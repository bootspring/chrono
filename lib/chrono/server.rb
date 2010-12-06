require 'mongo'
require 'redis'
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

    get '/apps' do
      apps = master_db.collection('applications')
      apps.find.to_a.inspect
    end

    post '/apps' do
      apps = master_db.collection('applications')
      apps.create_index('token', :unique => true)
      apps.insert(params)
      201
    end

    get '/apps/:token/metrics' do
      authorize do
        content_type 'application/json'
        expires 300, :public
        Yajl::Encoder.encode redis.smembers("metrics-#{app_token}")
      end
    end

    post '/apps/:token/metrics' do
      authorize do
        write
        201
      end
    end

    get '/apps/:token/metrics/:name' do
      authorize do
        name = params['name']
        halt(401, "Invalid metric name: #{name}") if name !~ /\A\w+\Z/
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

    delete '/apps/:token/metrics/:name' do
      authorize do
        coll = metrics_db.collection(params['name'])
        coll.remove(query)
      end
    end

    private
    
    def app_token
      params['token']
    end

    def authorize
      return halt(401, 'No token provided') unless app_token

      coll = master_db.collection('applications')
      @app = coll.find_one('token' => app_token)
      if app
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

    def time(value)
      Time.at(Integer(value)).utc
    end

    def chronic(name)
      parsed = Chronic.parse(params[name])
      parsed ? parsed.time : Time.at(Integer(params[name])).utc
    end

    def insert_one(hash)
      halt(401, "Invalid metric name: #{hash['k']}") if hash['k'] !~ /\A\w+\Z/
      doc = { :at => time(hash['at']), :v => hash['v'].to_f, :ip => ip(env['REMOTE_ADDR']), :k => hash['k'] }
      coll = metrics_db.collection(doc[:k])
      coll.insert(doc)
    
      redis.sadd("metrics-#{app_token}", hash['k'])
    end
      
    def write
      metrics = Yajl::Parser.parse(env['rack.input'])
      case metrics
      when Hash
        insert_one(metrics)
      when Array
        metrics.each do |metric|
          insert_one(metric)
        end
      else
        halt(500, "#{metrics.class.name}")
      end
    end
    
    def metrics_db
      @metrics ||= Mongo::Connection.new
      @metrics.db("chrono_metrics_#{environment}")
    end

    def master_db
      @master ||= Mongo::Connection.new
      @master.db("chrono_master_#{environment}")
    end
    
    def redis
      @redis ||= Redis.new
    end

    def ip(str)
      str.split('.').inject(0) { |i, a| i << 8 | a.to_i }
    end
    
    def environment
      self.class.environment
    end
  end
end