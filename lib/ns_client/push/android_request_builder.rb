module NsClient::Push
  class AndroidRequestBuilder
    attr_reader :request

    def self.build
      new
    end

    def initialize
      @request = Protos::Notification::Push::Android::Request.new
      @request.guid = SecureRandom.uuid
      @request.source = NsClient.config.default_source
      @request.event_timestamp = Time.now
      @request.payload = Protos::Notification::Push::Android::Request::Message.new
      @request.payload.priority = Protos::Notification::Push::Android::Request::Priority::NORMAL
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

    def with_collapse_key(key)
      @request.payload.collapse_key = key
      self
    end

    def with_priority(priority)
      @request.payload.priority = priority
      self
    end

    def with_data(data)
      @request.payload.data ||= Google::Protobuf::Map.new(:string, :string)
      data.each do |key, val|
        @request.payload.data[key] = val
      end
      self
    end

    def with_guid(guid)
      @request.guid = guid
      self
    end

    def with_message(msg)
      @request.payload.data ||= Google::Protobuf::Map.new(:string, :string)
      @request.payload.data['message'] = msg
      self
    end

    def deliver
      validate!
      NsClient.deliver(@request, topic: NsClient::Type::TOPICS[:push_android])
    end

    def deliver_async
      validate!
      NsClient.deliver_async(@request, topic: NsClient::Type::TOPICS[:push_android])
    end

    def deliver_pubsub
      validate!
      NsClient.deliver_pubsub(@request, topic: NsClient::Type::TOPICS[:push_android])
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
