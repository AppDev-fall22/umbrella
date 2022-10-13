require "open-uri"
require "json"
require "ascii_charts"

gmaps_api_endpoint_prefix = "https://maps.googleapis.com/maps/api/geocode/json?address="
gmaps_api_endpoint_suffix = "&key=AIzaSyAgRzRHJZf-uoevSnYDTf08or8QFS_fb3U"

p "Where are you located?"

user_location = gets.chomp
p user_location

user_location = user_location.gsub(" ", "%20")

gmaps_api_endpoint = gmaps_api_endpoint_prefix + user_location + gmaps_api_endpoint_suffix

raw_data = URI.open(gmaps_api_endpoint).read

parsed_data = JSON.parse(raw_data)
results_array = parsed_data.fetch("results")

first_result = results_array.first
geo = first_result.fetch("geometry")
loc = geo.fetch("location")

latitude = loc.fetch("lat")
longitude = loc.fetch("lng")

#Weather portion
dark_sky_api_endpoint = "https://api.darksky.net/forecast/26f63e92c5006b5c493906e7953da893/#{latitude},#{longitude}"
raw_data_weather = URI.open(dark_sky_api_endpoint).read
parsed_weather_data = JSON.parse(raw_data_weather)

current_weather = parsed_weather_data.fetch("currently")
current_summary = current_weather.fetch("summary")
current_temp = current_weather.fetch("temperature")

p "It is currently " + current_summary.downcase + ". The temperature is #{current_temp}"

hourly_weather = parsed_weather_data.fetch("hourly").fetch("data")

umbrella = 0
chart_data = []

12.times do |counter|
  rain_prob = hourly_weather[counter].fetch("precipProbability")
  chart_data.put([counter, rain_prob * 100])

  if rain_prob > 0.1
    p "In #{counter+1} hours, the probabiliy of rain is #{rain_prob * 100}%"
    umbrella = 1
  end
end

if umbrella == 1
  p "You should probably bring an umbrella"
else
  p "You probably won't need an umbrella today."
end

#ASCII chart
puts AsciiCharts::Cartesian.new(chart_data).draw
