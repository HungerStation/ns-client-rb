RSpec.describe NsClient::HttpClient do
  before do
    NsClient.configure do |config|
      config.backup_url = 'http://dummy.com'
    end
  end

  let!(:http_client) { described_class.new(NsClient.config, NsClient.logger) }

  describe '.deliver' do
    context 'given unsuported topic' do
      it 'should raise NsClient::NotSupportedTopic' do
        payload = { FFaker::Lorem.characters => FFaker::Lorem.characters }
        topic = FFaker::Lorem.word

        expect{
          http_client.deliver(payload, topic: topic)
        }.to raise_error(NsClient::NotSupportedTopic)
      end
    end

    context 'given correct topic' do
      let(:topic) { NsClient::Type::TOPICS.values.sample }

      it 'should send the request' do
        payload = { FFaker::Lorem.characters => FFaker::Lorem.characters }
        response_body = { FFaker::Lorem.characters => FFaker::Lorem.characters }
        response = Typhoeus::Response.new(code: 200, body: response_body.to_json)
        allow(Typhoeus::Response).to receive(:new).and_return(response)

        response = http_client.deliver(payload, topic: topic)
        expect(response).to eq response_body
      end

      it 'should send the request with version' do
        payload = { FFaker::Lorem.characters => FFaker::Lorem.characters }
        response_body = { FFaker::Lorem.characters => FFaker::Lorem.characters }
        response = Typhoeus::Response.new(code: 200, body: response_body.to_json)
        version = rand(1..3)
        allow(Typhoeus::Response).to receive(:new).and_return(response)

        response = http_client.deliver(payload, topic: topic, version: version)
        expect(response).to eq response_body
      end

      it 'should raise NsClient::Request Error if status not 200 <= X <=300 ' do
        payload = { FFaker::Lorem.characters => FFaker::Lorem.characters }
        response_body = { FFaker::Lorem.characters => FFaker::Lorem.characters }
        response = Typhoeus::Response.new(code: rand(400..500), body: response_body.to_json)
        allow(Typhoeus::Response).to receive(:new).and_return(response)

        expect{
          http_client.deliver(payload, topic: topic)
        }.to raise_error(NsClient::RequestError)
      end
    end
  end
end