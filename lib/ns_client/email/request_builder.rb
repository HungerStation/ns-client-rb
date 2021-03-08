require 'securerandom'

module NsClient::Email
  class RequestBuilder
    attr_reader :request

    def self.build
      new
    end

    def initialize
      @request = Protos::Notification::Email::Request.new
      @request.guid = SecureRandom.uuid
      @request.source = NsClient.config.default_source
      @request.service_token = NsClient.config.service_token
      @request.event_timestamp = Time.now
      @request.content = Protos::Notification::Email::Request::Content.new
      @request.from = Protos::Notification::Email::Request::Address.new
      @request.replyTo = Protos::Notification::Email::Request::Address.new
    end

    def with_source(source)
      @request.source = source
      self
    end

    def with_guid(guid)
      @request.guid = guid
      self
    end

    def with_subject(subject)
      @request.subject = subject
      self
    end

    def with_content_message(message)
      @request.content.message = message
      self
    end

    def with_content_headers(headers)
      @request.content.headers ||= Google::Protobuf::Map.new(:string, :string)
      headers.each do |key, val|
        @request.content.headers[key] = val
      end
      self
    end

    def with_from_name(name)
      @request.from.name = name
      self
    end

    def with_from_email(email)
      @request.from.email = email
      self
    end

    def add_to(name, email)
      @request.to ||= Google::Protobuf::RepeatedField.new(Protos::Notification::Email::Request::Address)
      @request.to += [
        Protos::Notification::Email::Request::Address.new(name: name, email: email)
      ]
      self
    end

    def with_reply_to_name(name)
      @request.replyTo.name = name
      self
    end

    def with_reply_to_email(email)
      @request.replyTo.email = email
      self
    end

    def deliver
      validate!
      NsClient.deliver(@request, topic: NsClient::Type::TOPICS[:email])
    end
      
    def deliver_async
      validate!
      NsClient.deliver_async(@request, topic: NsClient::Type::TOPICS[:email])
    end
      
    def deliver_pubsub
      validate!
      NsClient.deliver_pubsub(@request, topic: NsClient::Type::TOPICS[:email])
    end

    private

    def validate!
      missing_fields = []
      missing_fields << :message unless @request.content.message&.size > 0
      missing_fields << :from_email unless @request.from&.email.size > 0
      missing_fields << :to_email unless @request.to[0]&.email.size > 0
      unless missing_fields.empty?
        raise NsClient::MissingRequiredField, "missing required fields: #{missing_fields.join(', ')}"
      end
    end

  end
end
