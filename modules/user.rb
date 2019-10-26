# frozen_string_literal: true

# Public: Used to handle Users
#
class User
  def self.login(username, password)
    p username
    p password
    @user = DBConnector.connect.execute('SELECT * FROM Users WHERE'\
            ' name=? AND password=?', username, password)
    p @user
    if @user == [] || @user.nil?
      "Unable to sign in #{username}"
    else
      @user[0][0]
    end
  end

  def self.remove(where, equals)
    DBConnector.remove('Users', where, equals)
  end

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

  def self.new(name, pass, lang, admin)
    DBConnector.insert('users', %w[name password lang type], [name, pass, lang, admin])
  end
end
