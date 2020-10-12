require 'pry'
require 'json'
require 'ns_client/version'
require 'ns_client/kafka_client'
require 'ns_client/configuration'
require 'ns_client/fake_test'

module NsClient
  class << self

    ## for kafka transaction
    def deliver(value, topic:, **options)
      kafka_client.deliver(value, topic: topic, **options)
    rescue StandardError => e
      logger.error(details: "Error brooooo")
      http_client.deliver(value, topic: topic) if config.backup_channel
    end

    def deliver_async(value, topic:, **options)
      kafka_client.deliver_async(value, topic: topic, **options)
    rescue Kafka::BufferOverflow
      logger.error(details: "Message for `#{topic}` dropped due to buffer overflow" )
      http_client.deliver(value, topic: topic) if config.backup_channel
    end

    def shutdown
      kafka_client.shutdown
    end


    ## setting up logger
    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
        if config.log_level
          logger.level = Object.const_get("Logger::#{config.log_level.upcase}")
        else
          logger.level = 'INFO'
        end

        logger.formatter = proc do |severity, datetime, _progname, msg|
          format = { level: severity, event_time: datetime.to_s, default_info: msg }
          if msg.is_a? Hash
            format = format.merge!(msg).reject { |k, v| [:default_info, :severity].include? k }
          end
          JSON.generate(format) + $/
        end
      end
    end

    attr_writer :logger

    def config
      @config ||= NsClient::Configuration.new(env: ENV)
    rescue KingKonf::ConfigError => e
      raise ConfigError, e.message
    end

    def configure
      yield config
    end

    def kafka_test!
      @kafka_client = kafka_testing
    end

    def kafka_testing
      @kafka_testing ||= NsClient::FakeTest.new
    end

    private

    def kafka_client
      @kafka_client ||= NsClient::KafkaClient.new(config, logger)
    end

    def http_client
      @http_client ||= NsClient::HttpClient(client, logger)
    end
  end
end
