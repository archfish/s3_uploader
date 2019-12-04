require 'active_support/core_ext/object/blank'
require "s3_uploader/version"
require "s3_uploader/format"
require "s3_uploader/base"
require "s3_uploader/mount"
require "s3_uploader/mounter"

module S3Uploader
  class Error < StandardError; end

  if Object.const_defined? '::Rails::Engine'
    class Engine < ::Rails::Engine
    end
  end

  def self.config=(obj)
    raise 'Must implement 「bucket」 interface!' unless obj.respond_to?(:bucket)
    @config = obj
  end

  def self.config
    @config
  end
end

ActiveRecord::Base.extend S3Uploader::Mount
