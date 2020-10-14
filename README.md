# NsClient
This clients provides a dead easy way to start publish message to notification services.

## Features
1. Send message asynchronously backed by kafka
2. Send message synchronously using HTTP request as backup channel
3. Using protobuf for fast serialization and transport

## Installation
Add this line to Gemfile

```
gem 'ns_client', git: 'https://github.com/hungerstation/ns-client-rb.git', submodules: true
```
And then execute:

    $ bundle update --source ns_client

Or install it yourself as:

    $ gem install ns_redis
    
## Usage
### Configuration
Create `ns_client.rb` config in initializer folder

```
NsClient.configure do |config|
	brokers = ["kafka_broker_1","kafka_broker_2", "kafka_broker_3"]
	required_acks = -1 # leader and all replicas should aknowledge the message
	max_retries = 2 # The number of retries when attempting to deliver messages
	retry_backoff = 1 # The number of seconds to wait after a failed attempt to send messages to a Kafka broker before retrying
end
```

### Deliver Message
For delivering message is straight forward, 

Construct the message using one of the following models :

```
Protos::Notification::Sms.Request
(<Protos::Notification::Sms::Request: guid: "", title: "", source: "", recipient: "", sms_type: :DEFAULT, payload: {}, event_timestamp: nil>)

Protos::Notification::Email.Request

Protos::Notification::Push.Request
(<Protos::Notification::Push::Request: guid: "", title: "", source: "", tokens: [], payload: {}, event_timestamp: nil> )

Protos::Notification::Slack.Request
(<Protos::Notification::Slack::Request: guid: "", title: "", source: "", webhook: "", level: :INFO, payload: {}, event_timestamp: nil>)
```

Then define the topic using one the following topic

```
NsClient::Type::TOPICS[:sms] ## for SMS
NsClient::Type::TOPICS[:push] ## for push notificatio
NsClient::Type::TOPICS[:email] ## for email
NsClient::Type::TOPICS[:slack] ## for slack
```

Complete example :

```
message = Protos::Notification::Sms::Request.new
message.guid = "GENERATED ID"
message.title = "notification.sms.registration"
message.source = "platform.otp"
message.recipient = "+96645670982"
message.sms_type = :DEFAULT
payload = { message: "This is for testing purpose" }
event_timestamp = Time.now

## to deliver synchronously
NsClient.deliver(message, topic: NsClient::Type::TOPICS[:sms])

## to deliver Asynchronously
NsClient.deliver_async(message, topic: NsClient::Type::TOPICS[:sms])

```

## Development

### Setup
This only for unix machine (mac OS or GNU/Linux)
run `./bin/setup`

Always update submodule from hs_protos project

```
Change directory: $ cd lib/protos

Pull the latest proto files: $ git checkout master && git pull

Back to project's root directory: $ cd -

Commit changes: $ git add lib/protos && git commit
```

### Coverage
- for coverage using simplecov, with minimum coverage 100 %, report will generated during running test

### running test
```rspec spec```
will produce test result with coverage statistic


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hungerstation/ns-client-rb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
