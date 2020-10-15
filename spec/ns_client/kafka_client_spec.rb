require 'spec_helper'

RSpec.describe NsClient::KafkaClient do

  let(:kafka_client) { described_class.new(NsClient.config, NsClient.logger) }

  describe '.client' do
    it 'should return deivery client' do
      expect(kafka_client.client.is_a? DeliveryBoy::Instance).to eq true
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

      instance_client = instance_double NsClient::FakeTest
      allow(kafka_client).to receive(:client).and_return(instance_client)
      expect(instance_client).to receive(:deliver).with(proto_class.encode(message), topic: topic + ".1").exactly(:once)
      kafka_client.deliver(message, topic: topic)
    end

    it 'should raise NsClient::NotSupportedTopic when given wrong topic' do
      message = FFaker::Lorem::characters
      topic = FFaker::Lorem.word
      instance_client = instance_double NsClient::FakeTest
      allow(kafka_client).to receive(:client).and_return(instance_client)
      expect{
        kafka_client.deliver(message, topic: topic)
      }.to raise_error(NsClient::NotSupportedTopic)
    end
  end

  describe '.deliver_async' do
    it 'should deliver async message once' do
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

      instance_client = instance_double NsClient::FakeTest
      allow(kafka_client).to receive(:client).and_return(instance_client)
      expect(instance_client).to receive(:deliver_async).with(proto_class.encode(message), topic: topic + ".1").exactly(:once)
      kafka_client.deliver_async(message, topic: topic)
    end

    it 'should raise Kafka::BufferOverflow' do
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

      instance_client = instance_double NsClient::FakeTest
      allow(kafka_client).to receive(:client).and_return(instance_client)
      allow(instance_client).to receive(:deliver_async).with(proto_class.encode(message), topic: topic + ".1").and_raise(Kafka::BufferOverflow)
      allow(instance_client).to receive(:shutdown)
      expect{
        kafka_client.deliver_async(message, topic: topic)
      }.to raise_error(Kafka::BufferOverflow)
      kafka_client.shutdown
    end

    it 'should raise NsClient::NotSupportedTopic when given wrong topic' do
      message = FFaker::Lorem::characters
      topic = FFaker::Lorem.word
      instance_client = instance_double NsClient::FakeTest
      allow(kafka_client).to receive(:client).and_return(instance_client)
      expect{
        kafka_client.deliver_async(message, topic: topic)
      }.to raise_error(NsClient::NotSupportedTopic)
    end
  end
end