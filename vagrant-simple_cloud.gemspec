# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-simple_cloud/version'

Gem::Specification.new do |gem|
  gem.name          = "vagrant-simple_cloud"
  gem.version       = VagrantPlugins::SimpleCloud::VERSION
  gem.authors       = ["John Bender","Seth Reeser","Bulat Yusupov"]
  gem.email         = ["usbulat@gmail.com"]
  gem.description   = %q{Enables Vagrant to manage SimpleCloud droplets. Based on https://github.com/devopsgroup-io/vagrant-digitalocean.}
  gem.summary       = gem.description

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "faraday", ">= 0.8.6"
  gem.add_dependency "json"
  gem.add_dependency "log4r"
end
