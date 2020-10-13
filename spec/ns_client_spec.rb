RSpec.describe NsClient do
  after(:each) do
    NsClient.kafka_testing.clear
  end

  before do
    NsClient.kafka_test!
    NsClient.configure do |config|
      config.backup_channel = true
    end
  end

  it "has a version number" do
    expect(NsClient::VERSION).not_to be nil
  end

  describe ".deliver" do
    it "delivers the message using .deliver" do
      creation_time = Time.now
      message = FFaker::Lorem::characters
      topic = NsClient::Type::TOPICS.values.sample
      NsClient.deliver(message, topic: topic, create_time: creation_time)

      messages = NsClient.kafka_testing.messages_for(topic)

      expect(messages.count).to eq 1
      expect(messages[0].value).to eq message
      expect(messages[0].offset).to eq 0
      expect(messages[0].create_time).to eq creation_time
    end

    it "should call http client once when error raise and backup channel enabled" do
      instance = instance_double NsClient::FakeTest

      creation_time = Time.now
      message = FFaker::Lorem::characters
      topic = NsClient::Type::TOPICS.values.sample

      allow(NsClient).to receive(:kafka_client).and_return(instance)
      allow(instance).to receive(:deliver).and_raise(StandardError)
      allow(instance).to receive(:shutdown)

      expect(NsClient.http_client).to receive(:deliver).with(message, topic: topic).exactly(:once)

      NsClient.deliver(message, topic: topic, create_time: creation_time)
      NsClient.shutdown
    end
  end


  describe ".deliver_async" do
    it "delivers the message using .deliver_async with double message" do
      creation_time_first = Time.now
      creation_time_second = Time.now
      message_first = FFaker::Lorem::characters
      message_second = FFaker::Lorem::characters
      topic = NsClient::Type::TOPICS.values.sample

      NsClient.deliver_async(message_first, topic: topic, create_time: creation_time_first)
      NsClient.deliver_async(message_second, topic: topic, create_time: creation_time_second)

      messages = NsClient.kafka_testing.messages_for(topic)

      expect(messages.count).to eq 2

      expect(messages[0].value).to eq message_first
      expect(messages[0].offset).to eq 0
      expect(messages[0].create_time).to eq creation_time_first

      expect(messages[1].value).to eq message_second
      expect(messages[1].offset).to eq 1
      expect(messages[1].create_time).to eq creation_time_second
    end

    it "should call http client once when error raise and backup channel enabled" do
      instance = instance_double NsClient::FakeTest
      http_client = instance_double NsClient::HttpClient

      creation_time = Time.now
      message = FFaker::Lorem::characters
      topic = NsClient::Type::TOPICS.values.sample

      allow(NsClient).to receive(:kafka_client).and_return(instance)
      allow(NsClient).to receive(:http_client).and_return(http_client)
      allow(instance).to receive(:deliver_async).and_raise(Kafka::BufferOverflow)
      allow(instance).to receive(:shutdown)

      expect(http_client).to receive(:deliver).with(message, topic: topic).exactly(:once)
      
      NsClient.deliver_async(message, topic: topic, create_time: creation_time)
      NsClient.shutdown
    end
  end

  describe '.config' do
    it 'should return instance of NSClient::Configuration' do
      expect(NsClient.config.is_a? NsClient::Configuration).to eq true
    end
  end
end
