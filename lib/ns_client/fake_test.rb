require 'delivery_boy'
module NsClient
  class FakeTest < DeliveryBoy::Fake
    alias deliver_async deliver
  end
end