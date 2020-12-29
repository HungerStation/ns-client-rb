require 'spec_helper'

RSpec.describe NsClient::Slack::RequestBuilder do
  let(:text) { 'hello' }
  let(:channel) { '#random' }
  let(:username) { 'hungerstationbot' }
  let(:icon_emoji) { '⚠️' }
  let(:icon_url) { 'http://example.com/icon.png' }
  let(:attachment_title) { 'Attachment Title' }
  let(:attachment) { Protos::Notification::Slack::Request::Attachment.new(title: attachment_title) }
  let(:level) { :INFO }
  let(:webhook_url) { 'http://example.slack.com' }
  let(:title) { 'A Title' }
  let(:source) { 'default_source' }
  let(:guid) { SecureRandom.uuid }
  before do
    NsClient.configure do |config|
      config.default_source = source
    end
  end

  subject do
    NsClient::Slack::RequestBuilder.build.
      with_webhook_url(webhook_url).
      with_text(text).
      with_channel(channel).
      with_username(username).
      with_icon_emoji(icon_emoji).
      with_icon_url(icon_url).
      add_attachment(attachment).
      with_level(level).
      with_title(title).
      with_guid(guid)
  end

  describe '.build' do
    it 'sets GUID' do
      expect(subject.request.guid).not_to be_nil
    end

    it 'sets event_timestamp' do
      expect(subject.request.event_timestamp).not_to be_nil
    end

    it 'sets source with default_source' do
      expect(subject.request.source).to eq source
    end
  end

  describe '#with_title' do
    it 'sets title' do
      expect(subject.request.title).to eq title
    end
  end

  describe '#with_source' do
    let(:new_source) { 'new_source' }
    before do
      subject.with_source(new_source)
    end

    it 'overrides source value' do
      expect(subject.request.source).to eq new_source
    end
  end

  describe '#with_webhook_url' do
    it 'sets webhook URL' do
      expect(subject.request.webhook).to eq webhook_url
    end
  end

  describe '#with_guid' do
    it 'sets guid' do
      expect(subject.request.guid).to eq guid
    end
  end

  describe '#with_level' do
    it 'sets severity level' do
      expect(subject.request.level).to eq level
    end
  end

  describe '#with_text' do
    it 'sets text in payload' do
      expect(subject.request.payload.text).to eq text
    end
  end

  describe '#with_channel' do
    it 'sets channel in payload' do
      expect(subject.request.payload.channel).to eq channel
    end
  end

  describe '#with_username' do
    it 'sets username in payload' do
      expect(subject.request.payload.username).to eq username
    end
  end

  describe '#with_icon_emoji' do
    it 'sets icon emoji in payload' do
      expect(subject.request.payload.icon_emoji).to eq icon_emoji
    end
  end

  describe '#with_icon_url' do
    it 'sets icon URL in payload' do
      expect(subject.request.payload.icon_url).to eq icon_url
    end
  end

  describe '#add_attachment' do
    it 'sets attachment fields correctly' do
      expect(subject.request.payload.attachments[0].title).to eq attachment_title
    end

    it 'appends new attachment' do
      expect {
        subject.add_attachment(attachment)
      }.to change { subject.request.payload.attachments.size }.by 1
    end
  end

  describe '#deliver' do
    before do
      expect(NsClient).to receive(:deliver).with(subject.request, topic: NsClient::Type::TOPICS[:slack])
    end

    it 'calls NsClient.deliver with request object' do
      subject.deliver
    end
  end

  describe '#deliver_async' do
    before do
      expect(NsClient).to receive(:deliver_async).with(subject.request, topic: NsClient::Type::TOPICS[:slack])
    end

    it 'calls NsClient.deliver with request object' do
      subject.deliver_async
    end
  end

  context 'when webhook_url does not present' do
    let(:webhook_url) { '' }

    it 'raises MissingRequiredField error' do
      expect { subject.deliver }.to raise_error NsClient::MissingRequiredField
    end
  end
end
