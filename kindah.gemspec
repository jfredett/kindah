# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kindah/version'

Gem::Specification.new do |spec|
  spec.name          = "kindah"
  spec.version       = Kindah::VERSION
  spec.authors       = ["Joe Fredette"]
  spec.email         = ["jfredett@gmail.com"]
  spec.description   = %q{Kindah is an implementation of Parameterized Classes for Ruby.}
  spec.summary       = %q{Kindah is an implementation of Parameterized Classes for Ruby.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "katuv"
end
