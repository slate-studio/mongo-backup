# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongo_backup/version'

Gem::Specification.new do |spec|
  spec.name          = "mongo-backup"
  spec.version       = MongoBackup::Rails::VERSION
  spec.authors       = ["Slate Studio"]
  spec.email         = ["alex@slatestudio.com"]
  spec.description   = %q{Backup (restore) mongo database and upload backup file to S3}
  spec.summary       = %q{Backup (restore) mongo database and upload backup file to S3}
  spec.homepage      = "http://www.slatestudio.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]
end