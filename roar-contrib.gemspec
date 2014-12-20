$:.push File.expand_path('../lib', __FILE__)
require 'roar/contrib/version'

Gem::Specification.new do |spec|
  spec.name          = 'roar-contrib'
  spec.version       = Roar::Contrib::VERSION
  spec.authors       = ['Ari Summer']
  spec.email         = ['aribsummer@gmail.com']
  spec.summary       = %q{Collection of useful Roar extensions.}
  spec.description   = spec.summary
  spec.homepage      = 'https://github.com/sweatshirtio/roar-contrib'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'roar', '>= 0.11.13'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '>= 5.4.2'
end
