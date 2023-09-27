module Circed
  class Actions::Kick
    extend Circed::ActionHelper

    def self.call(sender, message)
      Log.debug { "kick: #{message}" }

      channel_name = message.first
      return send_error(sender, Numerics::ERR_BADCHANMASK, channel_name, "Wrong channel format") unless channel_name.starts_with?("#")

      channel_obj = ChannelHandler.get_channel(channel_name)
      return send_error(sender, Numerics::ERR_NOSUCHCHANNEL, channel_name, "No such channel") unless channel_obj

      # Ensure the sender is in the channel
      return send_error(sender, Numerics::ERR_NOTONCHANNEL, channel_name, "You're not on that channel") unless channel_obj.user_in_channel?(sender)

      # Ensure the sender is an operator
      channel_user = channel_obj.find_user(sender).not_nil!
      return send_error(sender, Numerics::ERR_CHANOPRIVSNEEDED, channel_name, "You're not an operator") unless channel_user.is_operator?

      # Ensure the kicked user is in the channel
      kicked_user = channel_obj.find_user_by_nickname(message[1])
      return send_error(sender, Numerics::ERR_NOSUCHNICK, channel_name, "No such nick/channel") unless kicked_user

      # Execute kick
      send_to_channel(channel_obj) do |receiver, io|
        parse(sender, [channel_name, kicked_user.nickname.to_s, message[2..-1].join], io) if io
      end
      channel_obj.delete(kicked_user)
    end
  end
end