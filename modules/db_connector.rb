# frozen_string_literal: true

require 'sqlite3'
# Private: Handles connections to the DB
#
#
class DBConnector
  def initialize
    connect
  end

  def self.connect
    @db ||= SQLite3::Database.new 'db/configuration.db'
    @db
  end

  def self.insert(db, position, value)
    positions = position[0]
    position.shift
    if position.length >= 1
      position.each do |z|
        positions += ', ' + z
      end
    end

    values = '?'
    (value.length - 1).times { |_| values += ', ?' }
    connect.execute("INSERT INTO #{db} (#{positions}) VALUES (#{values})", value[0..value.length])
  end

  def self.remove(db, condition, value)
    connect.execute("DELETE FROM #{db} WHERE #{condition} = '?'", value)
  end
end
