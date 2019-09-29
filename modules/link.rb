# frozen_string_literal: false

# Public: Encodes a string to be used as a link
#
# link - The string to be encoded
#
# Returns a url-encoded string
#
class Link
  def self.encode(link)
    # FIXME: Whitespace should be replaced with %20
    link.gsub('å', '%C3%A5')
    link.gsub('ä', '%C3%A4')
    link.gsub('ö', '%C3%B6')
  end
end
