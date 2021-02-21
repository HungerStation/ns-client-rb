require 'spec_helper'

RSpec.describe NsClient::Sms::RequestBuilder do
  let(:message) { 'hello' }
  let(:type) { Protos::Notification::Sms::Request::SmsType::DEFAULT }
  let(:recipient) { '+966789789789' }
  let(:title) { 'A Title' }
  let(:source) { 'default_source' }
  let(:guid) { SecureRandom.uuid }
  before do
    NsClient.configure do |config|
      config.default_source = source
      config.service_token = FFaker::Lorem.characters
    end
  end

  subject do
    NsClient::Sms::RequestBuilder.build.
      with_recipient(recipient).
      with_message(message).
      with_type(type).
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

  describe '#with_recipient' do
    it 'sets recipeint' do
      expect(subject.request.recipient).to eq recipient
    end
  end

  describe '#with_guid' do
    it 'sets guid' do
      expect(subject.request.guid).to eq guid
    end
  end

  describe '#with_type' do
    it 'sets sms type' do
      expect(subject.request.sms_type).to eq :DEFAULT
    end
  end

  describe '#with_message' do
    it 'sets message in payload' do
      expect(subject.request.payload['message']).to eq message
    end
  end

  describe '#deliver' do
    before do
      expect(NsClient).to receive(:deliver).with(subject.request, topic: NsClient::Type::TOPICS[:sms])
    end

    it 'calls NsClient.deliver with request object' do
      subject.deliver
    end
  end

  describe '#deliver_async' do
    before do
      expect(NsClient).to receive(:deliver_async).with(subject.request, topic: NsClient::Type::TOPICS[:sms])
    end

    it 'calls NsClient.deliver_async with request object' do
      subject.deliver_async
    end
  end

  describe '#deliver_pubsub' do
    before do
      expect(NsClient).to receive(:deliver_pubsub).with(subject.request, topic: NsClient::Type::TOPICS[:sms])
    end

    it 'calls NsClient.deliver_pubsub with request object' do
      subject.deliver_pubsub
    end
  end

  context 'when recipient does not present' do
    let(:recipient) { '' }

    it 'raises MissingRequiredField error' do
      expect { subject.deliver }.to raise_error NsClient::MissingRequiredField
    end
  end
end
