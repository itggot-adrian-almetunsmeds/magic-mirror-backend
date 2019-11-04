# frozen_string_literal: true

# Public: Used to handle Users
#
class User
  # Checks if the login details are correct and then return the users id
  # If unable to sign in a error message is returned
  def self.login(username, password)
    @user = DBConnector.connect.execute('SELECT * FROM Users WHERE'\
            ' name=? AND password=?', username, password)
    if @user == [] || @user.nil?
      "Unable to sign in #{username}"
    else
      @user[0][0]
    end
  end

  # Removes a user from the Users db
  #
  # where - String indicating where = ?
  # equals - String indicating ? = equals
  def self.remove(where, equals)
    DBConnector.remove('Users', where, equals)
  end

  # Checks if there is a user in the db
  def self.excists?
    if all.nil?
      false
    else
      true
    end
  end

  # Retrieves the users from the db
  def self.all
    DBConnector.connect.execute('SELECT * FROM Users')
  end

  # Adds a new user to the db
  def self.new(name, pass, lang, admin)
    DBConnector.insert('users', %w[name password lang type], [name, pass, lang, admin])
  end
end
