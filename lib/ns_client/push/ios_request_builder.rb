module NsClient::Push
  class IosRequestBuilder
    attr_reader :request

    def self.build
      new
    end

    def initialize
      @request = Protos::Notification::Push::Ios::Request.new
      @request.guid = SecureRandom.uuid
      @request.source = NsClient.config.default_source
      @request.event_timestamp = Time.now
      @request.payload = Protos::Notification::Push::Ios::Request::Message.new
      @request.payload.priority = Protos::Notification::Push::Ios::Request::Priority::LOW
    end

    def with_title(title)
      @request.title = title
      self
    end

    def with_source(source)
      @request.source = source
      self
    end

    def with_tokens(tokens)
      @request.tokens ||= Google::Protobuf::RepeatedField.new(:string)
      @request.tokens += tokens
      self
    end

    def with_topic(topic)
      @request.payload.topic = topic
      self
    end

    def with_collapse_id(id)
      @request.payload.collapse_id = id
      self
    end

    def with_priority(priority)
      @request.payload.priority = priority
      self
    end

    def with_custom_data(data)
      @request.payload.custom ||= Google::Protobuf::Map.new(:string, :string)
      data.each do |key, val|
        @request.payload.custom[key] = val
      end
      self
    end

    def with_guid(guid)
      @request.guid = guid
      self
    end

    def with_message(msg)
      @request.payload.custom ||= Google::Protobuf::Map.new(:string, :string)
      @request.payload.custom['message'] = msg
      self
    end

    def deliver
      validate!
      NsClient.deliver(@request, topic: NsClient::Type::TOPICS[:push_ios])
    end

    def deliver_async
      validate!
      NsClient.deliver_async(@request, topic: NsClient::Type::TOPICS[:push_ios])
    end

    def deliver_pubsub
      validate!
      NsClient.deliver_pubsub(@request, topic: NsClient::Type::TOPICS[:push_ios])
    end

    private

    def validate!
      missing_fields = []
      missing_fields << :tokens unless @request.tokens&.size > 0

      unless missing_fields.empty?
        raise NsClient::MissingRequiredField, "missing required fields: #{missing_fields.join(', ')}"
      end
    end
  end
end
