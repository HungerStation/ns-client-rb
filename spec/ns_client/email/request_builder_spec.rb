require 'spec_helper'

RSpec.describe NsClient::Email::RequestBuilder do
  let(:guid) { SecureRandom.uuid }
  let(:source) { 'default_source' }
  let(:mail_subject) { 'Order Confirmed' }
  let(:content_message) {'Your order number 45638 was just confirm ! Yee haa !'}
  let(:content_headers){ { SomeHeaders: 'BlaBlaBlaBla' } }
  let(:from_name) {'John Doe'}
  let(:from_email) {'jd@hs.com'}
  let(:to_name) {'Brad Pitt'}
  let(:to_email) {'bp@hs.com'}
  let(:reply_to_name) {'Matt Damon'}
  let(:reply_to_email) {'md@hs.com'}
  let(:service_token) { FFaker::Lorem.characters }
  before do
    NsClient.configure do |config|
      config.default_source = source
      config.service_token = service_token
    end
  end

  subject do
    NsClient::Email::RequestBuilder.build.
      with_subject(mail_subject).
      with_content_message(content_message).
      with_content_headers(content_headers).
      with_from(from_name, from_email).
      add_to(to_name, to_email).
      with_reply_to(reply_to_name, reply_to_email).
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

    it 'sets service token with generated token' do
      expect(subject.request.service_token).to eq service_token
    end
  end

  describe '#with_subject' do
    it 'sets subject' do
      expect(subject.request.subject).to eq mail_subject
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

  describe '#with_guid' do
    it 'sets guid' do
      expect(subject.request.guid).to eq guid
    end
  end

  describe '#with_content_message' do
    it 'sets content message' do
      expect(subject.request.content.message).to eq content_message
    end
  end

  describe '#with_content_headers' do
    it 'sets content headers' do
      expect(subject.request.content.headers).to eq content_headers
    end
  end

  describe '#add_to' do
    it 'sets to to correctly' do
      expect(subject.request.to[0].name).to eq to_name
      expect(subject.request.to[0].email).to eq to_email
    end

    it 'appends new field' do
      expect {
        subject.add_to('Russ Cox', 'russ@google.com')
      }.to change { subject.request.to.size }.by 1
    end
  end

  describe '#with_from' do
    it 'sets sender name' do
      expect(subject.request.from.name).to eq from_name
    end
    it 'sets sender email' do
      expect(subject.request.from.email).to eq from_email
    end
  end

  describe '#with_reply_to' do
    it 'sets reply to person name' do
      expect(subject.request.replyTo.name).to eq reply_to_name
    end
    it 'sets reply to person email' do
      expect(subject.request.replyTo.email).to eq reply_to_email
    end
  end

  describe '#deliver' do
    before do
      expect(NsClient).to receive(:deliver).with(subject.request, topic: NsClient::Type::TOPICS[:email])
    end

    it 'calls NsClient.deliver with request object' do
      subject.deliver
    end
  end

  describe '#deliver_async' do
    before do
      expect(NsClient).to receive(:deliver_async).with(subject.request, topic: NsClient::Type::TOPICS[:email])
    end

    it 'calls NsClient.deliver with request object' do
      subject.deliver_async
    end
  end

  describe '#deliver_pubsub' do
    before do
      expect(NsClient).to receive(:deliver_pubsub).with(subject.request, topic: NsClient::Type::TOPICS[:email])
    end

    it 'calls NsClient.deliver_pubsub with request object' do
      subject.deliver_pubsub
    end
  end

  context 'when message is not set' do
    let(:content_message) { '' }

    it 'deliver raises MissingRequiredField error' do
      expect { subject.deliver }.to raise_error NsClient::MissingRequiredField
    end
  end

  context 'when message is not set' do
    let(:content_message) { '' }

    it 'deliver async raises MissingRequiredField error' do
      expect { subject.deliver_async }.to raise_error NsClient::MissingRequiredField
    end
  end

  context 'when message is not set' do
    let(:content_message) { '' }

    it 'deliver pubsub raises MissingRequiredField error' do
      expect { subject.deliver_pubsub }.to raise_error NsClient::MissingRequiredField
    end
  end
end
