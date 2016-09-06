# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'generics/version'

Gem::Specification.new do |spec|
  spec.name          = "generics"
  spec.version       = Generics::VERSION
  spec.authors       = ["matrinox"]
  spec.email         = ["geoff.lee@lendesk.com"]

  spec.summary       = %q{Generics for Ruby}
  spec.description   = %q{Generics for Ruby, starting with collections}
  spec.homepage      = "https://github.com/matrinox/generics"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"

  # Fun pry tools
  spec.add_development_dependency 'awesome_print', '~> 1.6.1'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'pry-byebug', '~> 3.3.0'
  spec.add_development_dependency 'pry-coolline', '~> 0.2.5'
  spec.add_development_dependency 'pry-rails', '~> 0.3.4'
  spec.add_development_dependency 'pry-toys', '~> 0.0.2'
  spec.add_development_dependency 'pry-macro', '~> 1.0.1'
  spec.add_development_dependency 'pry-state', '~> 0.1.7'
  spec.add_development_dependency 'pry-inline', '~> 1.0.1'
  spec.add_development_dependency 'pry-doc', '~> 0.9.0'
  spec.add_development_dependency 'pry-highlight', '~> 0.1.0'

  spec.add_dependency "hamster", ">= 3.0.0"
end
