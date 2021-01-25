require 'spec_helper'

RSpec.describe NsClient::GooglePubsubClient do
  let(:pubsub_client) { described_class.new(NsClient.config, NsClient.logger) }

  describe '.client' do
    it 'should return pubsub project client' do
      credential = instance_double Google::Auth::Credentials
      allow(Google::Cloud::PubSub).to receive(:default_credentials).and_return(credential)
      allow(Google::Cloud::PubSub::Credentials).to receive(:new).and_return(credential)
      allow(NsClient.config).to receive(:project_id).and_return(FFaker::Lorem.characters)
      expect(pubsub_client.client.is_a? Google::Cloud::PubSub::Project).to eq true
    end
  end
  
  describe '.deliver' do
    it 'should deliver message once' do
      key = :slack
      topic = NsClient::Type::TOPICS[key]
      payload = Google::Protobuf::Map.new(:string, :string)
      payload[FFaker::Lorem.word] = FFaker::Lorem.characters
      proto_class = NsClient::Type::REQUESTS[key]
      message = proto_class.new
      message.guid = FFaker::Lorem.word
      message.title = FFaker::Lorem.characters
      message.source = FFaker::Lorem.word
      message.webhook = FFaker::Lorem.word

      instance_client = instance_double Google::Cloud::PubSub::Project
      allow(pubsub_client).to receive(:client).and_return(instance_client)
      topic_client = instance_double Google::Cloud::PubSub::Topic
      allow(instance_client).to receive(:topic).and_return(topic_client)
      expect(topic_client).to receive(:publish).with(proto_class.encode(message)).exactly(:once)

      pubsub_client.deliver(message, topic: topic)
    end

    it 'should raise NsClient::NotSupportedTopic when given wrong topic' do
      message = FFaker::Lorem::characters
      topic = FFaker::Lorem.word
      instance_client = instance_double Google::Cloud::PubSub::Project
      allow(pubsub_client).to receive(:client).and_return(instance_client)
      expect{
        pubsub_client.deliver(message, topic: topic)
      }.to raise_error(NsClient::NotSupportedTopic)
    end
  end
end