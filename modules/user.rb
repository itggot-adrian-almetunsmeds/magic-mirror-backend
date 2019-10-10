# frozen_string_literal: true

# Public: Used to handle Users
#
class User
  def self.excists?
    if all.nil?
      false
    else
      true
    end
  end

  def self.all
    DBConnector.connect.execute('SELECT * FROM Users')
  end

  def self.new(name)
    DBConnector.insert('users', ['name'], [name])
  end
end
