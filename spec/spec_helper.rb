require 'rubygems'
require 'bundler'
require 'spec'
Bundler.require(:default,:test)
Bundler.setup(:default, :test)

$TESTING=true

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'object-masala'
require 'mongo'
require 'redis'

# require 'yaml'
# config = YAML.load_file(File.join(File.dirname(__FILE__), '..', 'config', 'database.yml'))

# require File.join(File.dirname(__FILE__), 'spec_fixtures')
