module Circed
  class ChannelHandler
    @@channels : Hash(String, Channel) = {} of String => Channel

    def self.channels
      @@channels
    end

    def self.clear
      @@channels.clear
    end

    def self.add_user_to_channel(channel : String, client : Client, password : String? = nil)
      channel_obj = add_channel(channel)

      channel_obj.add_client(client, password)
    end

    def self.add_channel(channel : String) : Channel
      @@channels[channel] ||= Channel.new(channel)
    end

    def self.add_channel(channel : Channel) : Channel
      @@channels[channel.name] ||= channel
    end

    def self.remove_user_from_channel(channel : String, client : Client)
      if channel_obj = @@channels[channel]?
        channel_obj.remove_client(client)
        @@channels.delete(channel) if channel_obj.channel_empty?
      end
    end

    def self.remove_user_from_all_channels(client : Client)
      @@channels.each do |channel_name, channel_obj|
        channel_obj.remove_client(client)
        @@channels.delete(channel_name) if channel_obj.channel_empty?
      end
    end

    def self.send_to_all_channels(client : Client, *args)
      @@channels.each_value do |channel_obj|
        channel_obj.send_raw(client, *args)
      end
    end

    def self.get_channel(channel : String)
      @@channels[channel]?
    end

    def self.channel_is_full?(channel : String)
      if @@channels[channel]? != nil
        return @@channels[channel].channel_full?
      end
      false
    end

    def self.user_channels(client : Client)
      @@channels.select { |_channel, channel_obj| channel_obj.user_in_channel?(client) }.values
    end

    def self.channel_empty?(channel : String)
      if @@channels[channel]? != nil
        @@channels[channel].channel_empty?
      else
        true
      end
    end

    def self.channel_exists?(channel : String)
      @@channels.has_key?(channel)
    end

    def self.size
      @@channels.size
    end

    def self.channel_list
      @@channels.keys
    end

    def self.channel_is_invite_only?(channel : String) : Bool
      channel_obj = @@channels[channel]?
      channel_obj ? channel_obj.invite_only? : false
    end

    def self.user_has_invite?(channel : String, client : Client) : Bool
      channel_obj = @@channels[channel]?
      channel_obj ? channel_obj.invited?(client) : false
    end

    def self.channel_is_private?(channel : String) : Bool
      channel_obj = @@channels[channel]?
      channel_obj ? channel_obj.private? : false
    end

    def self.channel_has_password?(channel : String) : Bool
      channel_obj = @@channels[channel]?
      return false unless channel_obj
      !channel_obj.channel_password.nil?
    end

    def self.channel_password(channel : String) : String?
      @@channels[channel]?.try(&.channel_password)
    end

    def self.change_mode(channel : String, mode : String, client : Client)
      @@channels[channel]?.try(&.change_mode(mode, client))
    end

    def self.user_in_channel?(channel : String, client : Client)
      @@channels[channel]?.try(&.user_in_channel?(client)) || false
    end
  end
end
