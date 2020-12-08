module NsClient::Sms
    class RequestBuilder
    attr_reader :request
    
    def self.build(message:,recipient:)
        new(message,recipient)
    end

    def initialize(message:,recipient:)
      @request = Protos::Notification::Sms::Request.new
      @request.recipient = recipient
      @request.sms_type = :DEFAULT
      @request.payload = { message: message }
    end
  
    def with_type(type)
        @request.sms_type = type
    end
  
    def with_source(source)
        @request.source = source
    end
    
    def with_guid(guid)
        @request.guid = guid
    end

    def with_source(source)
        @request.source = source
    end

    def deliver
        NsClient.deliver(@request, topic: NsClient::Type::TOPICS[:sms])
    end

    def deliver_async
        NsClient.deliver_async(message, topic: NsClient::Type::TOPICS[:sms])
    end
  end
end
