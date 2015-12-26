$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'json'
require 'bundler'
Bundler.setup
require 'bunny'

class MbFetcher
  def conn
    return @conn if @conn
    @conn = Bunny.new(
      :hostname => ENV['RABBITMQ_HOST'])
    @conn.start
  end

  def channel
    @channel ||= conn.create_channel
  end

  def queue
    @queue ||= channel.queue(ENV['TRADES_QUEUE'] || 'trades')
  end

  def publish msg
    channel.default_exchange.publish(msg, routing_key: queue.name)
  end
end

mb = MbFetcher.new

mb.publish({a: 1, b: 2}.to_json)
