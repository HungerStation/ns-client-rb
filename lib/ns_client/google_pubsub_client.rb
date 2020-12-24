require 'ns_client/type'
require 'ns_client/not_supported_topic'
require 'google/cloud/pubsub'

module NsClient
  class GooglePubsubClient
    include NsClient::Type
    
    attr_reader :config, :logger

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def deliver(value, topic:, version: 1, **options)
      validate_topic(topic)
      topic_client = client.topic versioned_topic(topic, version)
      topic_client.publish encode_message(value, topic)
    end

    def client
      @client ||= begin
        Google::Cloud::PubSub.new(
          project_id: config.project_id,
          credentials: config.credential
        )
      end
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
      return topic + ".#{version}"
    end

    def encode_message(message, topic)
      key = NsClient::Type::TOPICS.select{ |key, value| value == topic }.keys&.first
      proto_class = REQUESTS[key]
      proto_class.encode(message)
    end

  end
end