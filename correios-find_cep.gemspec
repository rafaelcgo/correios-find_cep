# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'correios/find_cep/version'

Gem::Specification.new do |spec|
  spec.name          = "correios-find_cep"
  spec.version       = Correios::FindCep::VERSION
  spec.authors       = ["Rafael Oliveira"]
  spec.email         = ["rafael.coelho@gmail.com"]

  spec.summary       = 'Correios::FindCEP gem gets a list of CEP intervals for Cities and UF based on Correios Website using HTML parsers.'
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/rafaelcgo/correios-find_cep"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "rails"
end
