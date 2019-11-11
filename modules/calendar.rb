# frozen_string_literal: true

# require 'google-auth'
# require 'signet'

# Handles all calendar related tasks
class Calendar
    def self.redirect(_)
      client = Signet::OAuth2::Client.new(
        client_id: ENV('GOOGLE_API_CLIENT_ID'),
        client_secret: ENV('GOOGLE_API_CLIENT_SECRET'),
        authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
        scope: Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY,
        redirect_uri: 'http://localhost:9292/google/auth'
      )
      redirect client.authorization_uri.to_s
    end
  end
  