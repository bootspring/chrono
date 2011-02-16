namespace :chrono do
  task :rollup do
    metric_collections.each do |name|
      aggregate_metrics(name)
    end
  end
end

def metric_collections
  @metrics ||= Mongo::Connection.new
  @db = @metrics.db("chrono_metrics_#{ENV['RACK_ENV'] || 'development'}")
  db.collections
end

def aggregate_metrics(name)
  query = {}
  query['at'] = {}
  query['at']["$gte"] = 1.hour.ago
  query['at']["$lt"] = Time.now
  
  @db.collection(name).find(query)
end