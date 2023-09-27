module Circed
  class UserHandler
    class NicknameUsedError < Exception; end

    class NicknameNoUsedError < Exception; end

    @@clients : Hash(String, Circed::Client) = {} of String => Circed::Client
    @@users : Set(Circed::User) = Set(Circed::User).new

    def self.size
      @@clients.size
    end

    def self.clear
      @@clients.clear
    end

    def self.add_client(client : Client)
      nick = client.nickname.to_s
      @@clients[nick] = client
    end

    def self.add_user(user : User)
      @@users << user
    end

    def self.changed_nickname(old_nickname : String, new_nickname : String)
      client = @@clients[old_nickname]
      raise NicknameNoUsedError.new unless client
      @@clients[new_nickname] = client
      @@clients.delete(old_nickname)
    end

    def self.client_exists?(nickname : Nil)
      false
    end

    def self.client_exists?(nickname : String)
      @@clients.has_key?(nickname)
    end

    def self.nickname_used?(nickname : String)
      client_exists?(nickname)
    end

    def self.nickname_used?(payload : FastIRC::Message)
      payload.prefix.try(&.user) && client_exists?(payload.prefix.try(&.user))
    end

    def self.remove_connection(nickname : String)
      @@clients.delete(nickname)
    end

    def self.get_client(nickname : String)
      @@clients[nickname]?
    end
  end
end
