require 'securerandom'

module NsClient::Sms
  class RequestBuilder
    attr_reader :request
    
    def self.build
      new
    end

    def initialize
      @request = Protos::Notification::Sms::Request.new
      @request.guid = SecureRandom.uuid
      @request.source = NsClient.config.default_source
      @request.sms_type = Protos::Notification::Sms::Request::SmsType::DEFAULT
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

    def with_recipient(recipient)
      @request.recipient = recipient
      self
    end

    def with_type(type)
      @request.sms_type = type
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
      NsClient.deliver(@request, topic: NsClient::Type::TOPICS[:sms])
    end

    def deliver_async
      validate!
      NsClient.deliver_async(@request, topic: NsClient::Type::TOPICS[:sms])
    end

    def deliver_pubsub
      validate!
      NsClient.deliver_pubsub(@request, topic: NsClient::Type::TOPICS[:sms])
    end

    private

    def validate!
      missing_fields = []
      missing_fields << :message unless @request.payload['message']&.size > 0
      missing_fields << :recipient unless @request.recipient&.size > 0

      unless missing_fields.empty?
        raise NsClient::MissingRequiredField, "missing required fields: #{missing_fields.join(', ')}"
      end
    end

  end
end
