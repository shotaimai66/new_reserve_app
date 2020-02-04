class LinePush
  require 'line/bot'

  attr_reader :client, :delivery_message, :calendar

  CHANNEL_SECRET = ENV['CHANNEL_SECRET'].freeze
  CHANNEL_TOKEN = ENV['CHANNEL_TOKEN'].freeze
  def initialize(delivery_message)
    @client = Line::Bot::Client.new { |config|
      config.channel_secret = CHANNEL_SECRET
      config.channel_token = CHANNEL_TOKEN
     }
    @delivery_message = delivery_message
    @calendar = delivery_message.calendar
  end

  def new(delivery_message)

  end

  def push
    calendar.store_members.only_line_sync.each do |member|
      message = {
        type: 'text',
        text: delivery_message.message
       }
       user_id = member.line_user_id
       response = client.push_message(user_id, message)
    end
  end



end