# frozen_string_literal: true

require_relative 'modules/db_connector'
require_relative 'modules/public_transport'
require_relative 'modules/weather'
require_relative 'modules/calendar'
Z = DBConnector.connect
Z.results_as_hash = true

# EVERY 1 MINUTE
def update_minute
  p 'update min'
  x = DBConnector.connect.execute('SELECT * FROM current_sessions').first
  x&.each do |id|
    q = Z.execute('SELECT * FROM PublicTransit WHERE user_id = ?', id.last.to_i)
    if q == []
      puts 'Did not update Transit'
    else
      q.each do |s|
        stops = PublicTransport.departures(s['stop_id'])
        Z.execute('DELETE FROM transport WHERE user_id = ?', id.last.to_i)
        stops.each do |stop|
          if stop == 'No data available'
            puts 'Did not update Transit'
          else
            Z.execute('INSERT INTO transport (user_id, line, rtTime, time, '\
              'direction, operator, operatorcode) '\
            'VALUES (?,?,?,?,?,?,?)', id.last.to_i, stop[0], stop[1], stop[2], stop[3], stop[4], stop[5])
            puts 'Updated Transit'
          end
        end
      end

    end
  end
end

# EVERY 20 MINUTES
def update_twenty # rubocop:disable Metrics/MethodLength
  p 'update twenty'
  x = DBConnector.connect.execute('SELECT * FROM current_sessions').first

  x.each do |id|
    begin
      Calendar.fetch(id.last.to_i)
      puts 'Updated calendar'
    rescue StandardError
      puts 'Unable to update calendar'
    end
    begin
      k = Z.execute('SELECT lat, long FROM Location WHERE user_id = ?', id).first
      if !k.nil? && !k['lat'].nil? && !k['long'].nil?
        puts 'Updated weather'
        w = Weather.current(k['lat'], k['long'])
        Z.execute('DELETE FROM weather WHERE user_id = ?', id)
        w.each do |weather|
          Z.execute('INSERT INTO weather (user_id, temp, wind_speed, wind_gust, '\
              'humidity, thunder, symbol, time, pcat)'\
          ' VALUES (?,?,?,?,?,?,?,?,?)', id, weather[:temp], weather[:wind_speed],
                    weather[:wind_gust], weather[:humidity],
                    weather[:thunder], weather[:symbol], weather[:valid_time], weather[:pcat])
        end
      else
        puts 'Did not update weather'
      end
    rescue StandardError
      puts 'Unable to update weather'
    end
  end
end

def run
  running = true
  count = 0
  while running
    p 'starting sleep'
    sleep 30
    p 'sleept'
    update_minute
    count += 1
    if count == 40
      update_twenty
      count = 0
    end
  end
end

run
