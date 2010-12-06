$LOAD_PATH << (File.dirname(__FILE__) + '/lib')

require 'chrono'
require 'chrono/server'
require 'rack/coffee'

use Rack::Coffee, {
  :root => 'public'
}
run Chrono::Server