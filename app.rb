Bundler.require(:default, ENV['RACK_ENV'])
require 'active_support/cache'
require 'action_view'

Dotenv.load if defined?(Dotenv)

CITY = ENV['CITY']
STATE = ENV['STATE']
API_KEY = ENV['WUNDERGROUND_API_KEY']
ENDPOINT = 'http://api.wunderground.com/api/%s/conditions/q/%s/%s.json' % [
             API_KEY,
             URI.escape(STATE),
             URI.escape(CITY)
           ]

Connection = Faraday.new(url: ENDPOINT) do |conn|
  conn.response :caching do
    ActiveSupport::Cache::MemoryStore.new(expires_in: 300)
  end

  conn.response :json
  conn.response :logger

  conn.adapter Faraday.default_adapter
end

class CurrentWeather < Struct.new(:response)
  SNOW_INDICATOR = "snow".freeze

  def self.update(conn)
    new(conn.get.body)
  end

  def snowing?
    weather.downcase.include?(SNOW_INDICATOR)
  end

  def last_updated 
    Time.at(response['current_observation']['local_epoch'].to_i)
  end

  def icon_url
    response['current_observation']['icon_url']
  end

  def weather
    response['current_observation']['weather']
  end
end

helpers do
  include ActionView::Helpers::DateHelper
end

get '/' do
  @weather = CurrentWeather.update(Connection)
  erb :index
end
