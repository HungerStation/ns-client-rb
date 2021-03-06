require 'json'
require 'ns_client/version'
require 'ns_client/kafka_client'
require 'ns_client/google_pubsub_client'
require 'ns_client/http_client'
require 'ns_client/configuration'
require 'ns_client/fake_test'
require 'ns_client/type'
require 'ns_client/not_supported_topic'
require 'ns_client/missing_required_field'
require 'ns_client/slack/request_builder'
require 'ns_client/slack/attachment_builder'
require 'ns_client/sms/request_builder'
require 'ns_client/email/request_builder'
require 'ns_client/push/android_request_builder'
require 'ns_client/push/ios_request_builder'

## proto schema
require 'protos/notification/sms/sms_pb'
require 'protos/notification/email/email_pb'
require 'protos/notification/push/android/android_pb'
require 'protos/notification/push/ios/ios_pb'
require 'protos/notification/slack/slack_pb'

module NsClient
  class << self

    ## for kafka transaction
    def deliver(value, topic:, **options)
      kafka_client.deliver(value, topic: topic, **options)
    rescue StandardError => e
      logger.error(details: "Message for #{topic} dropped due to #{e.message}")
      http_client.deliver(value, topic: topic) if config.backup_channel
    end

    def deliver_async(value, topic:, **options)
      kafka_client.deliver_async(value, topic: topic, **options)
    rescue Kafka::BufferOverflow, NsClient::NotSupportedTopic => e
      logger.error(details: "Message for `#{topic}` dropped due to #{e.message}" )
      http_client.deliver(value, topic: topic) if config.backup_channel
    end

    ## for google pubsub transaction
    def deliver_pubsub(value, topic:, **options)
      pubsub_client.deliver(value, topic: topic, **options)
      logger.info(topic: topic, source: value.source, transport: 'pubsub'.freeze, guid: value.guid)
    rescue StandardError => e
      logger.error(details: "Message for #{topic} dropped due to #{e.message}")
      http_client.deliver(value, topic: topic) if config.backup_channel
    end

    def shutdown
      kafka_client.shutdown
    end


    ## setting up logger
    def logger
      @logger ||= Logger.new($stdout).tap do |logger|
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

    def kafka_client
      @kafka_client ||= NsClient::KafkaClient.new(config, logger)
    end

    def http_client
      @http_client ||= NsClient::HttpClient.new(config, logger)
    end

    def pubsub_client
      @pubsub_client ||= NsClient::GooglePubsubClient.new(config, logger)
    end
  end
end
