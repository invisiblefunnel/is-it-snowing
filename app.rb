require 'active_support/cache'
require 'action_view'
require 'connection_pool'
require 'dotenv'
require 'faraday'
require 'faraday_middleware'
require 'memoizable'
require 'sinatra'

Dotenv.load

CITY = ENV['CITY']
STATE = ENV['STATE']
API_KEY = ENV['WUNDERGROUND_API_KEY']
ENDPOINT = 'http://api.wunderground.com/api/%s/conditions/q/%s/%s.json' % [
             API_KEY,
             URI.escape(STATE),
             URI.escape(CITY)
           ]

ThreadSafeCache = ActiveSupport::Cache::MemoryStore.new(expires_in: 300)

Connections = ConnectionPool.new(size: 5) do
  Faraday.new(url: ENDPOINT) do |faraday|
    faraday.response(:caching) { ThreadSafeCache }
    faraday.response(:json)
    faraday.response(:logger)
    faraday.adapter(Faraday.default_adapter)
  end
end

class CurrentWeather < Struct.new(:response)
  include Memoizable
  SNOW_INDICATOR = "snow".freeze

  def self.update(conn)
    new(conn.get.body)
  end

  def snowing?
    weather.downcase.include?(SNOW_INDICATOR)
  end
  memoize :snowing?

  def last_updated 
    Time.at(response['current_observation']['local_epoch'].to_i)
  end
  memoize :last_updated

  def weather
    response['current_observation']['weather']
  end
  memoize :weather
end

configure do
  set :server, :puma
end

helpers do
  include ActionView::Helpers::DateHelper
end

get '/' do
  @weather = Connections.with { |conn| CurrentWeather.update(conn) }
  erb :index
end
