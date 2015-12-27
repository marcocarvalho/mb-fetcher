if ARGV.count == 0
  puts "use ruby #{__FILE__} SINCE"
  exit 1
end

$LOAD_PATH.unshift(File.expand_path('../../lib', __FILE__))

require 'bundler'
Bundler.setup

if ENV['DOTENV']
  require 'dotenv'
  Dotenv.load
end

require 'json'
require 'bunny'
require 'mercado_bitcoin'

class MbFetcher
  attr_reader :since

  def initialize(since)
    @since = since
  end

  def conn
    return @conn if @conn
    @conn = Bunny.new(
      hostname: ENV['RABBITMQ_HOST'],
      user: ENV['RABBITMQ_USER'],
      pass: ENV['RABBITMQ_PASS'])
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

  def mercado_bitcoin
    @mercado_bitcoin ||= MercadoBitcoin::Trade.new(:bitcoin, since: since)
  end

  def models
    @models ||= mercado_bitcoin.fetch
  end

  def perform
    models.each do |model|
      publish(model.to_json)
    end
  end

  def self.perform(since)
    new(since).perform
  end
end

MbFetcher.perform(ARGV[0])