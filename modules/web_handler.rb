# frozen_string_literal: true

require 'httparty'

# Webhandler contans methods for http related tasks
#
# self.encode(link) - Returns url-encoded string
#
class WebHandler
  def self.request(url)
    HTTParty.get(url)
  rescue StandardError
    raise "Failed to fetch translations. Unable to connect to #{url}"
  end

  # Public: Encodes a string to be used as a link
  #
  # link - The string to be encoded
  #
  # Returns a url-encoded string
  #
  # rubocop:disable Metrics/MethodLength
  def self.encode(link) # rubocop:disable Metrics/AbcSize
    link = link.downcase
    i = 0
    while i < link.length
      if link[i].ord == 32 # ' '
        link[i] = '%20'
      elsif link[i].ord == 228 # 'ä' # rubocop:disable Style/AsciiComments
        link[i] = '%C3%A4'
      elsif link[i].ord == 229 # 'å' # rubocop:disable Style/AsciiComments
        link[i] = '%C3%A5'
      end
      i += 1
    end

    # TODO: Make this process neater.
    # The entire method is questionable in how it operates
    link.gsub('\u00E4', '%C3%A4')
    link.gsub('å', '%C3%A5')
    link.gsub('ä', '%C3%A4')
    link.gsub('ö', '%C3%B6')
  end
  # rubocop:enable Metrics/MethodLength
end