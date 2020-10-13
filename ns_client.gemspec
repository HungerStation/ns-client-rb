
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ns_client/version"

Gem::Specification.new do |spec|
  spec.name          = "ns_client"
  spec.version       = NsClient::VERSION
  spec.authors       = ["Ahmad K"]
  spec.email         = ["ahmed.k@hungerstation.com"]

  spec.authors       = ['HS Platform Team']
  spec.email         = ['ahmed.k@hungerstation.com']

  spec.summary       = 'Notification service client for Ruby'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "ffaker"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-console"

  spec.add_runtime_dependency "delivery_boy", ">= 1.0.1"
  spec.add_runtime_dependency "king_konf", "~> 0.3"
  spec.add_runtime_dependency "google-protobuf"
end
