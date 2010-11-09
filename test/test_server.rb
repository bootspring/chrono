require 'helper'
require 'timekeeper/server'

class TestServer < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Timekeeper::Server
  end

  def test_default
    get '/'
    assert_equal "Timekeeper v#{Timekeeper::VERSION}", last_response.body
  end
  
  def test_metrics_push
    load('foo.bar')
  end
  
  def test_query
    load('foo.bar')
    load('foo.bar')

    get('/query', { :name => 'foo.bar', :start_time => Time.now.utc.to_i - 100, :end_time => Time.now.utc.to_i + 5 })
    assert_equal 200, last_response.status
    assert_equal [], Yajl::Parser.parse(last_response.body)
  end
  
  private
  
  def load(name, value=nil)
    post('/metrics', { :time => Time.now.utc.to_i, :host => Socket.gethostname, :name => name, :val => (value || 12.to_f) })
    assert_equal 201, last_response.status, last_response.errors
    assert_equal '', last_response.body, last_response.errors
  end
end