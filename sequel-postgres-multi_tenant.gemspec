# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sequel/postgres/multi_tenant/version'

Gem::Specification.new do |spec|
  spec.name          = 'sequel-multi_tenant'
  spec.version       = Sequel::Postgres::MultiTenant::VERSION
  spec.authors       = ['Gabriel Naiman']
  spec.email         = ['gabynaiman@gmail.com']

  spec.summary       = 'Postgres multi tenant implementation using Sequel and PG schemas'
  spec.description   = 'Postgres multi tenant implementation using Sequel and PG schemas'
  spec.homepage      = 'https://github.com/gabynaiman/sequel-postgres-multi_tenant'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'sequel', '~> 4.37'
  spec.add_runtime_dependency 'pg', '~> 0.18'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'minitest-colorin', '~> 0.1'
  spec.add_development_dependency 'pry-nav', '~> 0.2'
  spec.add_development_dependency 'simplecov', '~> 0.12'
  spec.add_development_dependency 'coveralls', '~> 0.8'
end
