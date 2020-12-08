require 'spec_helper'

RSpec.describe NsClient::Slack::RequestBuilder do
  let(:message) { 'hello' }
  let(:level) { :INFO }
  let(:webhook_url) { 'http://example.slack.com' }
  let(:title) { 'A Title' }
  let(:source) { 'default_source' }
  before do
    NsClient.configure do |config|
      config.default_source = source
    end
  end

  subject do
    NsClient::Slack::RequestBuilder.build.
      with_webhook_url(webhook_url).
      with_message(message).
      with_level(level).
      with_title(title)
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

  describe '#with_level' do
    it 'sets severity level' do
      expect(subject.request.level).to eq level
    end
  end

  describe '#with_message' do
    it 'sets message in payload' do
      expect(subject.request.payload['message']).to eq message
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
