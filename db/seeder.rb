# frozen_string_literal: true

require 'sqlite3'

# Creates a database and populates it with data.
class Seeder
  # Seeds the database
  #
  # Brings the database to excistance and removes the old db if there is one
  #
  def self.seed!
    db = connect
    drop_tables(db)
    puts 'Deleted old tables'
    create_tables(db)
    puts 'Created new tables'
    populate_tables(db)
    puts 'Populated tables'
  end

  # Connects to the db
  #
  # Returns a database object
  #
  def self.connect
    SQLite3::Database.new 'db/configuration.db'
  end

  # Drops all tables if they exists
  def self.drop_tables(db)
    db.execute('DROP TABLE IF EXISTS ApiKeys;')
    db.execute('DROP TABLE IF EXISTS Location;')
    db.execute('DROP TABLE IF EXISTS PublicTransit;')
    db.execute('DROP TABLE IF EXISTS Users;')
    db.execute('DROP TABLE IF EXISTS current_sessions;')
    db.execute('DROP TABLE IF EXISTS transport;')
    db.execute('DROP TABLE IF EXISTS weather;')
  end

  # Creates all tables for the db
  def self.create_tables(db) # rubocop:disable Metrics/MethodLength
    db.execute <<-SQL
            CREATE TABLE "ApiKeys" (
                "reseplanerare"  TEXT,
                "stolptidstabeller" TEXT
            );
    SQL

    db.execute <<-SQL
            CREATE TABLE "location" (
                "county"	         TEXT,
                "lat"            TEXT NOT NULL,
                "long"           TEXT NOT NULL,
                "user_id"        INTEGER NOT NULL
            );
    SQL

    db.execute <<-SQL
            CREATE TABLE "PublicTransit" (
                "Name"             TEXT NOT NULL,
                "stop_id"          INTEGER NOT NULL,
                "user_id"          INTEGER NOT NULL UNIQUE
            );
    SQL

    db.execute <<-SQL
            CREATE TABLE "Users" (
                "id"                INTEGER PRIMARY KEY AUTOINCREMENT,
                "name"              TEXT NOT NULL,
                "password"          TEXT NOT NULL,
                "lang"              TEXT,
                "type"              Text
            );
    SQL

    db.execute <<-SQL
            CREATE TABLE "current_sessions" (
                "user_id"               INTEGER
                );
    SQL

    db.execute <<-SQL
            CREATE TABLE "transport" (
                "user_id"	      INTEGER NOT NULL,
                "line"	        TEXT NOT NULL,
                "rtTime"	      TEXT,
                "time"	        TEXT NOT NULL,
                "direction"	    TEXT NOT NULL,
                "operator"	    TEXT,
                "operatorcode"	TEXT
            );

    SQL

    db.execute <<-SQL
            CREATE TABLE "weather" (
                "user_id"	    INTEGER NOT NULL,
                "temp"	        TEXT NOT NULL,
                "wind_speed"    TEXT NOT NULL,
                "wind_gust"	    TEXT,
                "humidity"	    TEXT,
                "thunder"	    TEXT,
                "symbol"	    INTEGER NOT NULL,
                "time"	        TEXT NOT NULL,
                "pcat"	        TEXT NOT NULL
            );
    SQL
  end

  # Populates the tables with data
  def self.populate_tables(db)
    users = [
      { name: 'admin', password: 'admin', lang: 'en', type: 'admin' }
    ]

    users.each do |d|
      db.execute('INSERT INTO Users (name, password, lang, type) VALUES (?,?,?,?)',
                 d[:name], d[:password], d[:lang], d[:type])
    end
  end
end
