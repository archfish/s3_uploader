
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "s3_uploader/version"

Gem::Specification.new do |spec|
  spec.name          = "s3_uploader"
  spec.version       = S3Uploader::VERSION
  spec.authors       = ["archfish"]
  spec.email         = ["weihailang@gmail.com"]

  spec.summary       = %q{页面直传文件到S3}
  spec.description   = %q{通过预签名post URL页面直接上传文件到S3}
  spec.homepage      = 'https://github.com/archfish/s3_uploader'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|examples)/}) }
  end

  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "> 1.17"

  spec.add_dependency 'aws-sdk-s3', "~> 1.47"
  spec.add_dependency 'activemodel', "> 4.2"
  spec.add_dependency 'activerecord', "> 4.2"
  spec.add_dependency 'activesupport', "> 4.2"
end
