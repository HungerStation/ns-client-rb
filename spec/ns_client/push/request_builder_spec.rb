require 'spec_helper'

RSpec.describe NsClient::Push::RequestBuilder do
  let(:payload) { { uri: 'hungerstation://?c=foo&s=o&id=123' } }
  let(:title) { 'A Title' }
  let(:source) { 'default_source' }
  let(:guid) { SecureRandom.uuid }
  let(:tokens) { ['b9d81bef-c813-4f51-a7c6-be2042093720'] }
  before do
    NsClient.configure do |config|
      config.default_source = source
    end
  end

  subject do
    NsClient::Push::RequestBuilder.build.
      with_payload(payload).
      with_tokens(tokens).
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

  describe '#with_tokens' do
    it 'sets recipient tokens' do
      expect(subject.request.tokens).to eq tokens
    end
  end

  describe '#with_guid' do
    it 'sets guid' do
      expect(subject.request.guid).to eq guid
    end
  end

  describe '#with_payload' do
    it 'sets payload data' do
      expect(subject.request.payload).to eq payload
    end
  end

  describe '#with_message' do
    let(:message) { 'hello' }
    before do
      subject.with_message(message)
    end

    it 'sets message in payload' do
      expect(subject.request.payload['message']).to eq message
    end
  end

  describe '#deliver' do
    before do
      expect(NsClient).to receive(:deliver).with(subject.request, topic: NsClient::Type::TOPICS[:push])
    end

    it 'calls NsClient.deliver with request object' do
      subject.deliver
    end
  end

  describe '#deliver_async' do
    before do
      expect(NsClient).to receive(:deliver_async).with(subject.request, topic: NsClient::Type::TOPICS[:push])
    end

    it 'calls NsClient.deliver with request object' do
      subject.deliver_async
    end
  end

  context 'when tokens is empty' do
    let(:tokens) { [] }

    it 'raises MissingRequiredField error' do
      expect { subject.deliver }.to raise_error NsClient::MissingRequiredField
    end
  end
end
