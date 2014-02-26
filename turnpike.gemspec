# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'turnpike/version'

Gem::Specification.new do |s|
  s.name        = 'turnpike'
  s.version     = Turnpike::VERSION
  s.authors     = ['Hakan Ensari']
  s.email       = ['hakan.ensari@papercavalier.com']
  s.homepage    = 'http://github.com/hakanensari/turnpike'
  s.description = %q{A Redis-backed FIFO queue}
  s.summary     = %q{A Redis-backed FIFO queue}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_runtime_dependency 'redis', '~> 3.0'
  if RUBY_PLATFORM == "java"
    s.add_runtime_dependency 'msgpack-jruby'
  else
    s.add_runtime_dependency 'msgpack', '~> 0.5.4'
  end
  s.add_development_dependency 'rake'

  s.required_ruby_version = '>= 2.0'
end
