require 'helper'
require 'timekeeper/server'

class TestServer < MiniTest::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Timekeeper::Server
  end
  
  def setup
    create_app
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

    get('/metrics', { :k => 'foo.bar', :start_time => Time.now.utc.to_i - 100, :end_time => Time.now.utc.to_i + 5 }, credentials)
    assert_equal 200, last_response.status, last_response.body
    result = Yajl::Parser.parse(last_response.body)
    assert_equal Array, result.class
    refute_equal 0, result.size
    assert_equal Hash, result[0].class
    assert_equal 5, result[0].size
  end
  
  def test_delete
    load('foo.bar')
    load('foo.bar')
    delete('/metrics', { :k => 'foo.bar', :end_time => Time.now.utc.to_i + 5 }, credentials)
    assert_equal 200, last_response.status, last_response.errors
    assert_equal '', last_response.body, last_response.errors
  end
  
  private
  
  def token_auth(token, options = {})
    values = ["token=#{token.to_s.inspect}"]
    options.each do |key, value|
      values << "#{key}=#{value.to_s.inspect}"
    end
    # 21 = "Authorization: Token ".size
    comma = ",\n#{' ' * 21}"
    "Token #{values * comma}"
  end
  
  def credentials
    { 'HTTP_AUTHORIZATION' => token_auth('xyz') }
  end
  
  def create_app(name='Ninja', token='xyz')
    post("/applications", :name => name, :token => token)
    assert_equal 201, last_response.status, last_response.errors
    assert_equal '', last_response.body, last_response.errors
  end
  
  def load(name, value=nil)
    post('/metrics', { :at => Time.now.utc.to_i, :k => name, :v => (value || 12.to_f) }, credentials)
    assert_equal 201, last_response.status, last_response.errors
    assert_equal '', last_response.body, last_response.errors
  end
end