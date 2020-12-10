require 'securerandom'

module NsClient::Slack
  class RequestBuilder
    attr_reader :request

    def self.build
      new
    end

    def initialize
      @request = Protos::Notification::Slack::Request.new
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

    def with_level(level)
      @request.level = level
      self
    end

    def with_webhook_url(url)
      @request.webhook = url
      self
    end

    def with_guid(guid)
      @request.guid = guid
      self
    end

    def with_text(text)
      @request.payload ||= Protos::Notification::Slack::Request::Message.new
      @request.payload.text = text
      self
    end

    def add_attachment(attachment)
      @request.payload ||= Protos::Notification::Slack::Request::Message.new
      @request.payload.attachments ||= Google::Protobuf::RepeatedField.new(Protos::Notification::Slack::Request::Attachment)
      @request.payload.attachments += [attachment]
      self
    end

    def deliver
      validate!
      NsClient.deliver(@request, topic: NsClient::Type::TOPICS[:slack])
    end

    def deliver_async
      validate!
      NsClient.deliver_async(@request, topic: NsClient::Type::TOPICS[:slack])
    end

    private

    def validate!
      missing_fields = []
      missing_fields << :message unless @request.payload.text&.size > 0
      missing_fields << :webhook_url unless @request.webhook&.size > 0

      unless missing_fields.empty?
        raise NsClient::MissingRequiredField, "missing required fields: #{missing_fields.join(', ')}"
      end
    end
  end
end
