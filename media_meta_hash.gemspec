# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'media_meta_hash/version'

Gem::Specification.new do |spec|
  spec.name          = "media_meta_hash"
  spec.version       = MediaMetaHash::VERSION
  spec.authors       = ["Renaldo Pierre-Louis"]
  spec.email         = ["pirelouisd87@gmail.com"]
  spec.description   = %q{Given the url to a video (youtube, vimeo, foxnews, foxbusiness), this return a hash for opengraph (og) and twitter cards which can be used with meta-tags gem to create the html tags}
  spec.summary       = %q{This gem takes video url (youtube, vimeo, foxnews, foxbusiness) and returns a hash for og and twitter card}
  spec.homepage      = "https://github.com/daltonrenaldo/meta_media_hash"
  spec.license       = "MIT"

  spec.add_dependency('video_info')

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-mocks"
end
