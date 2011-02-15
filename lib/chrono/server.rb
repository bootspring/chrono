require 'erb'
require 'mongo'
require 'sinatra/base'
require 'yajl'
require 'active_support/core_ext/time/zones'
require 'active_support/core_ext/time/calculations'
require 'active_support/core_ext/date/calculations'
require 'active_support/core_ext/numeric/time'
require 'chronic'
require 'tzinfo'

module Chrono
  class Server < Sinatra::Base
    set :sessions, false
    set :public, File.expand_path(File.dirname(__FILE__) + '/../../public')

    configure do
      Time.zone = TZInfo::Timezone.get("UTC")
      Time.zone_default = TZInfo::Timezone.get("UTC")
      Chronic.time_class = Time.zone
    end
    
    get '/' do
      erb :index, {}, :metrics => current_metrics
    end

    get '/metrics' do
      authorize do
        content_type 'application/json'
        expires 300, :public
        Yajl.dump(current_metrics)
      end
    end

    post '/metrics' do
      authorize do
        write
        201
      end
    end

    get '/metrics/:name' do
      authorize do
        name = params['name']
        halt(401, "Invalid metric name: #{name}") if name !~ /\A\w+\Z/
        coll = metrics_db.collection(name)
        results = []
        coll.find(query, :fields => %w(k v at)) do |cursor|
          results[0] = cursor.map { |x| x.delete('_id'); x }
        end
        if params[:previous]
          params[:previous].to_i.times do |x|
            idx = x + 1
            coll.find(query(-idx.weeks.to_i), :fields => %w(k v at)) do |cursor|
              results[idx] = cursor.map { |x| x.delete('_id'); x }
            end
          end
        end
        content_type 'application/json'
        expires 300, :public
        Yajl::Encoder.encode results
      end
    end

    delete '/metrics/:name' do
      authorize do
        coll = metrics_db.collection(params['name'])
        coll.remove(query)
      end
    end

    private
    
    def authorize
      yield
      # return halt(401, 'No token provided') unless app_token
      # 
      # coll = master_db.collection('applications')
      # @app = coll.find_one('token' => app_token)
      # if app
      #   yield
      # else
      #   halt(402, 'Unauthorized, please verify token')
      # end
    end

    def query(offset=0)
      query = {}
      query['at'] = {} if params['start_time'] || params['end_time']
      query['at']["$gte"] = chronic('start_time') + offset if params['start_time']
      query['at']["$lt"] = chronic('end_time') + offset if params['end_time']
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
    
    def current_metrics
      metrics_db.collections.reject { |c| c.name =~ /^system\./ }.map { |c| c.name }
    end
    
    def metrics_db
      p environment
      @metrics ||= Mongo::Connection.new
      @metrics.db("chrono_metrics_#{environment}")
    end

    def ip(str)
      str.split('.').inject(0) { |i, a| i << 8 | a.to_i }
    end
    
    def environment
      self.class.environment
    end
  end
end