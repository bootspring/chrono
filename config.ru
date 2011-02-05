$LOAD_PATH << (File.dirname(__FILE__) + '/lib')

require 'chrono'
require 'chrono/server'

Chrono::Server.run!