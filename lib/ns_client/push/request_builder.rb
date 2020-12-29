module NsClient::Push
  class RequestBuilder
    attr_reader :request

    def self.build
      new
    end

    def initialize
      @request = Protos::Notification::Push::Request.new
      @request.guid = SecureRandom.uuid
      @request.source = NsClient.config.default_source
      @request.event_timestamp = Time.now
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

    def with_payload(payload)
      @request.payload ||= Google::Protobuf::Map.new(:string, :string)
      payload.each do |key, val|
        @request.payload[key] = val
      end
      self
    end

    def with_guid(guid)
      @request.guid = guid
      self
    end

    def with_message(msg)
      @request.payload ||= Google::Protobuf::Map.new(:string, :string)
      @request.payload['message'] = msg
      self
    end

    def deliver
      validate!
      NsClient.deliver(@request, topic: NsClient::Type::TOPICS[:push])
    end

    def deliver_async
      validate!
      NsClient.deliver_async(@request, topic: NsClient::Type::TOPICS[:push])
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
