require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'foursquare-client'

class Test::Unit::TestCase
  # Turns a fixture file name into a full path
  def fixture_file(filename)
    return '' if filename == ''
    File.expand_path('test/fixtures/' + filename)
  end

  def foursquare
    return @foursquare if @foursquare

    @foursquare ||= Foursquare::Client.new(@foursquare_access_token)
  end
end
