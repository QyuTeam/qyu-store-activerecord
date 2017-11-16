
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "qyu/store/activerecord/version"

Gem::Specification.new do |spec|
  spec.name          = "qyu-store-activerecord"
  spec.version       = Qyu::Store::ActiveRecord::VERSION
  spec.authors       = ["Andrew Kumanyaev"]
  spec.email         = ["me@zzet.org"]

  spec.summary       = %q{ActiveRecord state store for Qyu https://rubygems.org/gems/qyu}
  spec.description   = %q{ActiveRecord state store for Qyu https://rubygems.org/gems/qyu}
  spec.homepage      = "https://github.com/FindHotel/qyu-store-activerecord"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency 'shoulda-matchers', '~> 3.1'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'pg'

  spec.add_runtime_dependency 'activerecord', '~> 5.1'
end
