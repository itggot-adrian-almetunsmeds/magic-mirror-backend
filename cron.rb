# frozen_string_literal: true

require_relative 'modules/db_connector'
require_relative 'modules/public_transport'
require_relative 'modules/weather'
x = DBConnector.connect.execute('SELECT * FROM current_sessions').first
z = DBConnector.connect
z.results_as_hash = true
unless x.nil?
  # EVERY 1 MINUTE DURING SET TIME INTERVAL
  x.each do |id|
    q = z.execute('SELECT * FROM PublicTransit WHERE user_id = ?', id.to_s)
    q.each do |s|
      stops = PublicTransport.departures(s['stop_id'])
      z.execute('DELETE FROM transport WHERE user_id = ?', id)
      stops.each do |stop|
        z.execute('INSERT INTO transport (user_id, line, rtTime, time, '\
          'direction, operator, operatorcode) '\
        'VALUES (?,?,?,?,?,?,?)', id, stop[0], stop[1], stop[2], stop[3], stop[4], stop[5])
      end
    end
  end

  # EVERY 20 MINUTES

  x.each do |id|
    k = z.execute('SELECT lat, long FROM Location WHERE user_id = ?', id).first
    if k != nil && k['lat'] != nil && k['long'] != nil
      puts "Updated weather"
      w = Weather.current(k['lat'], k['long'])
      z.execute('DELETE FROM weather WHERE user_id = ?', id)
      w.each do |weather|
        z.execute('INSERT INTO weather (user_id, temp, wind_speed, wind_gust, '\
            'humidity, thunder, symbol, time, pcat)'\
        ' VALUES (?,?,?,?,?,?,?,?,?)', id, weather[:temp], weather[:wind_speed],
                  weather[:wind_gust], weather[:humidity],
                  weather[:thunder], weather[:symbol], weather[:valid_time], weather[:pcat])
      end
    else
      puts "Did not update weather"
    end
  end
end
