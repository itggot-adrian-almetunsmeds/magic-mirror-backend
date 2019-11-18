# frozen_string_literal: true

# Handles weather
class Weather
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/MethodLength

  # Gets the weather forecast from SMHI
  #
  # lat - Float
  # long - Float
  #
  def self.current(lat, long)
    x = WebHandler.request('https://opendata-download-metfcst.smhi.se/api/category/'\
        "pmp3g/version/2/geotype/point/lon/#{long}/lat/#{lat}/data.json")
    forecast = []
    x['timeSeries'].each do |z|
      valid_time = z['validTime']
      temp = { valid_time: valid_time }
      z['parameters'].each do |q|
        case q['name']
        when 't'
          temperature = q['values'].first.to_s + ' ' + q['unit']
          temp[:temp] = temperature
        when 'ws'
          wind_speed = q['values'].first.to_s + ' ' + q['unit']
          temp[:wind_speed] = wind_speed
        when 'gust'
          wind_gust = q['values'].first.to_s + ' ' + q['unit']
          temp[:wind_gust] = wind_gust
        when 'r'
          relative_humidity = q['values'].first.to_s + ' ' + q['unit']
          temp[:humidity] = relative_humidity
        when 'tstm'
          thunder_prob = q['values'].first.to_s + ' ' + q['unit']
          temp[:thunder] = thunder_prob
        when 'Wsymb2'
          weather_symbol = q['values'].first.to_s
          temp[:symbol] = weather_symbol
        when 'pcat'
          rain_category = q['values'].first.to_s
          temp[:pcat] = rain_category
        end
      end
      forecast << temp
    end
    forecast
  end

  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/CyclomaticComplexity
  # rubocop:enable Metrics/MethodLength

  # Gets the cached weather from the db
  #
  def self.get(id)
    z = DBConnector.connect
    z.results_as_hash = true
    z.execute('SELECT * FROM weather WHERE user_id = ?', id)
  end
end
