# frozen_string_literal: true

# Public: Translation related tasks
class Translation
  def self.get(language_id)
    JSON.parse(File.read("translations/#{language_id}.json"))
  end

  def self.get_component(language_id, component)
    get(language_id)[component].to_json
  end
end
