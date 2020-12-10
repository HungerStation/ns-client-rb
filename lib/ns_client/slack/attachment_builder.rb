module NsClient::Slack
  class AttachmentBuilder
    attr_reader :attachment

    def self.build
      new
    end

    def initialize
      @attachment = Protos::Notification::Slack::Request::Attachment.new
    end

    def with_color(color)
      @attachment.color = color
      self
    end

    def with_fallback_text(text)
      @attachment.fallback = text
      self
    end

    def with_title(title)
      @attachment.title = title
      self
    end

    def with_title_link(url)
      @attachment.title_link = url
      self
    end

    def with_pretext(text)
      @attachment.pretext = text
      self
    end

    def with_text(text)
      @attachment.text = text
      self
    end

    def add_field(title, value)
      @attachment.fields ||= Google::Protobuf::RepeatedField.new(Protos::Notification::Slack::Request::Field)
      @attachment.fields += [
        Protos::Notification::Slack::Request::Field.new(title: title, value: value)
      ]
      self
    end
  end
end