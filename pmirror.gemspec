# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pmirror/version'

Gem::Specification.new do |spec|
  spec.name          = "pmirror"
  spec.version       = Pmirror::VERSION
  spec.authors       = ["Aaron Nichols"]
  spec.email         = ["anichols@trumped.org"]
  spec.description   = %q{Mirror files from remote http server by pattern}
  spec.summary       = %q{Mirror files from remote http server by pattern}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency('rdoc')
  spec.add_development_dependency('aruba')
  spec.add_development_dependency('rake', '~> 0.9.2')
  spec.add_dependency('methadone', '~> 1.3.1')
  spec.add_dependency('nokogiri')
  spec.add_dependency('progressbar')
  spec.add_development_dependency('rspec')
end
