# frozen_string_literal: true

# Google related
require 'google/apis/calendar_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'date'
require 'fileutils'

# Handles calendar methods
class Calendar
  attr_reader :url

  # Setup of Google API
  # Credentials.json must excist containing the credentials of the user as
  # collected from https://developers.google.com/calendar/quickstart/ruby
  # under Step 1, where it says "ENABLE THE GOOGLE CALENDAR"
  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'Google Calendar API Ruby Quickstart'
  CREDENTIALS_PATH = 'credentials.json'
  # The file token.yaml stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  TOKEN_PATH = 'token.yaml'
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR

  # Ensure valid credentials, either by restoring from the saved credentials
  # files or intitiating an OAuth2 authorization. If authorization is required,
  # the user's default browser will be launched to approve the request.
  #
  # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
  def authorize
    client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
    token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
    @authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
    @user_id = 'default'
    @credentials = @authorizer.get_credentials(@user_id)
    if @credentials.nil?
      @url = @authorizer.get_authorization_url(base_url: OOB_URI)
    else
      authorize_2
    end
  end

  # Retrives and completes authentication.
  def authorize_2(code)
    @credentials = @authorizer.get_and_store_credentials_from_code(
      user_id: @user_id, code: code, base_url: OOB_URI
    )
    @credentials
  end

  # Initializes google calendar api
  def initialize
    @credentials = nil
    @url = nil
    # Initialize the API
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
  end

  # Retrives the next events
  def next(amount = 10, cal_id = 'primary')
    amount = 1 if amount.zero?
    # Fetch the next 10 events for the user
    calendar_id = cal_id
    response = @service.list_events(calendar_id,
                                    max_results: amount,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: DateTime.now.rfc3339)
    puts 'Upcoming events:'
    puts 'No upcoming events found' if response.items.empty?
    response.items.each do |event|
      start = event.start.date || event.start.date_time
      puts "- #{event.summary} (#{start})"
    end
  end
end

x = Calendar.new
unless x.url.nil?
  p x.url
  x.authorize_2(gets)
end
x.next 0, 'primary'
