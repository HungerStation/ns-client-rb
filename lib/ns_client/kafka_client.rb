require 'delivery_boy'
require 'ns_client/type'
require 'ns_client/not_supported_topic'

module NsClient
  class KafkaClient
    include NsClient::Type

    attr_reader :config, :logger

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    # Construct client instance for sending message
    # @return [Object], client instance
    def client
      @client ||= DeliveryBoy::Instance.new(config, logger)
    end

    # Deliver message synchronously
    # @param value [Object] message
    # @param topic [String], target topic
    def deliver(value, topic:, version: 1, **options)
      validate_topic(topic)

      client.deliver(value.encode, topic: versioned_topic(topic, version), **options)
    end

    # Deliver message Asynchronously
    # @param value [Object] message
    # @param topic [String], target topic
    def deliver_async(value, topic:, version: 1, **options)
      validate_topic(topic)
      client.deliver_async(value.encode, topic: versioned_topic(topic, version), **options)
    rescue Kafka::BufferOverflow
      raise Kafka::BufferOverflow
    end

    # Close connection
    def shutdown
      client.shutdown
    end

    private

    # validate topic 
    # @param topic [String]
    def validate_topic(topic)
      raise NsClient::NotSupportedTopic, "topic #{topic} is not supported" unless TOPICS.values.include? topic.to_s
    end

    # Construct topic version
    # @param topic [String], base topic
    # @version [Integer], version number
    # @return [String] versioned topic
    def versioned_topic(topic, version)
      topic.concat(".#{version}")
    end
  end
end