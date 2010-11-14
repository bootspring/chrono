require 'helper'
require 'chrono/server'

class TestServer < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Chrono::Server
  end
  
  def setup
    create_app
  end

  def test_default
    get '/'
    assert_equal "Chrono v#{Chrono::VERSION}", last_response.body
  end
  
  def test_metrics_push
    load('foo_bar')
  end
  
  def test_query
    load('foo_bar')
    load('foo_bar')

    get("/apps/#{credentials}/metrics/foo_bar", { :start_time => Time.now.utc.to_i - 100, :end_time => Time.now.utc.to_i + 5 })
    assert_equal 200, last_response.status, last_response.errors
    result = Yajl::Parser.parse(last_response.body)
    assert_equal Array, result.class
    refute_equal 0, result.size
    assert_equal Hash, result[0].class
    assert_equal 3, result[0].size, result[0].inspect
  end
  
  def test_delete
    load('foo_bar')
    load('foo_bar')
    delete("/apps/#{credentials}/metrics/foo_bar", { :end_time => Time.now.utc.to_i + 5 })
    assert_equal 200, last_response.status, last_response.errors
    assert_equal '', last_response.body, last_response.errors
  end
  
  def test_invalid_metric_name
    get("/apps/#{credentials}/metrics/foo.bar", { :start_time => Time.now.utc.to_i - 100, :end_time => Time.now.utc.to_i + 5 })
    assert_equal 401, last_response.status, last_response.errors
  end

  private
  
  def credentials
    'xyz'
  end
  
  def create_app(name='Ninja', token='xyz')
    post("/apps", :name => name, :token => token)
    assert_equal 201, last_response.status, last_response.errors
    assert_equal '', last_response.body, last_response.errors
  end
  
  def load(name, value=nil)
    post("/apps/#{credentials}/metrics", Yajl::Encoder.encode([{ :at => Time.now.utc.to_i, :k => name, :v => (value || 12.to_f) }]))
    assert_equal 201, last_response.status, last_response.errors
    assert_equal '', last_response.body, last_response.errors
  end
end