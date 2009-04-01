require 'rubygems'
require 'rfeedparser'

$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
 
require File.dirname(__FILE__) + '/aggir/feed' unless defined?(Aggir::Feed)
require File.dirname(__FILE__) + '/aggir/entry' unless defined?(Aggir::Entry)
require File.dirname(__FILE__) + '/aggir/link' unless defined?(Aggir::Link)
require File.dirname(__FILE__) + '/aggir/solr' unless defined?(Aggir::Solr)
require File.dirname(__FILE__) + '/aggir/redis_storage' unless defined?(Aggir::RedisStorage)
require File.dirname(__FILE__) + '/aggir/delicious' unless defined?(Aggir::Delicious)

module Aggir
  VERSION = '0.0.1'
end
