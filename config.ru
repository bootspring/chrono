$LOAD_PATH << (File.dirname(__FILE__) + '/lib')

require 'timekeeper'
require 'timekeeper/server'

run Chrono::Server