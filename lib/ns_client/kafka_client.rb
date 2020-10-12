require 'delivery_boy'

module NsClient
  class KafkaClient
    attr_reader :config, :logger

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def client
      @client ||= DeliveryBoy::Instance.new(config, logger)
    end

    def deliver(value, topic:, **options)
      client.deliver(value, topic: topic, **options)
    end

    def deliver_async(value, topic:, **options)
      client.deliver_async(value, topic: topic, **options)
    rescue Kafka::BufferOverflow
      logger.error "Message for `#{topic}` dropped due to buffer overflow"
    end

    def shutdown
      client.shutdown
    end
  end
end