# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'opengraph_parser'
  s.version = '0.2.3'

  s.authors = ['Huy Ha', 'Duc Trinh']
  s.date = '2013-05-23'
  s.description = 'A simple Ruby library for parsing Open Graph Protocol information from a website. It also includes a fallback solution when the website has no Open Graph information.'
  s.email = 'hhuy424@gmail.com'
  s.extra_rdoc_files = [
    'LICENSE.txt',
    'README.rdoc'
  ]
  s.files = [
    'lib/open_graph.rb',
    'lib/opengraph_parser.rb',
    'lib/redirect_follower.rb',
    'exe/opengraph'
  ]
  s.homepage = 'http://github.com/huyha85/opengraph_parser'
  s.licenses = ['MIT']
  s.require_paths = ['lib']
  s.bindir = 'exe'
  s.executables = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.summary = 'A simple Ruby library for parsing Open Graph Protocol information from a website.'

  s.add_dependency('nokogiri')
  s.add_dependency('addressable')

  s.add_development_dependency 'bundler', '~> 1.9'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec", "~> 3.2'
  s.add_development_dependency('rdoc')
  s.add_development_dependency('bundler')
end
