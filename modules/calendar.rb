# frozen_string_literal: true

require_relative 'db_connector.rb'
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
      authorize_2(nil)
    end
  end

  # Retrives and completes authentication.
  def authorize_2(code) # rubocop:disable Metrics/MethodLength
    if !code.nil?
      begin
        @credentials = @authorizer.get_and_store_credentials_from_code(
          user_id: @user_id, code: code, base_url: OOB_URI
        )
      rescue StandardError
        raise 'Authorization failed.'
      end
    else
      @credentials
    end
  end

  # Initializes Google calendar api
  def initialize
    @credentials = nil
    @url = nil
    # Initialize the API
    @service = Google::Apis::CalendarV3::CalendarService.new
    @service.client_options.application_name = APPLICATION_NAME
    @service.authorization = authorize
  end

  # Fetches the next events
  def next(amount = 10, cal_id = 'primary')
    amount = 1 if amount.zero?
    calendar_id = cal_id
    response = @service.list_events(calendar_id,
                                    max_results: amount,
                                    single_events: true,
                                    order_by: 'startTime',
                                    time_min: DateTime.now.rfc3339)
    return 'No upcoming events found' if response.items.empty?

    response.items
  end

  def unauthenticate
    File.delete(TOKEN_PATH) if File.exist?(TOKEN_PATH)
  end

  def self.fetch
    x = new
    x.next
  end
end
