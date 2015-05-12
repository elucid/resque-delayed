# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque-delayed/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Justin Giancola"]
  gem.email         = ["justin.giancola@gmail.com"]
  gem.summary       = %q{Delayed job queueing for Resque}
  gem.description   = %q{Enqueue jobs that will only appear for processing after a specified delay or at a particular time in the future}
  gem.homepage      = "https://github.com/elucid/resque-delayed"

  gem.executables   = `git ls-files -- bin/*`.split($/).map { |f| File.basename(f) }
  gem.files         = `git ls-files`.split($/)
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split($/)
  gem.name          = "resque-delayed"
  gem.require_paths = ["lib"]
  gem.version       = Resque::Delayed::VERSION

  gem.add_development_dependency "bundler", ["~> 1.0", ">= 1.0.2"]
  gem.add_development_dependency "rspec", "~> 2.6.0"
  gem.add_development_dependency "rake"

  gem.add_dependency "resque", ["~> 1.0", ">= 1.18.0"]
  gem.add_dependency "uuidtools", ["~> 2.1", ">= 2.1.2"]
end
