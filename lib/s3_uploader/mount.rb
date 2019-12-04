require 'active_record'

module S3Uploader
  module Mount
    # Hash
    #   column => S3Uploader
    def s3_uploaders
      @s3_uploaders ||= superclass.respond_to?(__method__) ? superclass.public_send(__method__).dup : {}
    end

    def s3_uploader_options
      @s3_uploader_options ||= superclass.respond_to?(__method__) ? superclass.public_send(__method__).dup : {}
    end

    def s3_uploader_option(column, option)
      if s3_uploader_options[column].has_key?(option)
        s3_uploader_options[column][option]
      else
        s3_uploaders[column].send(option)
      end
    end

    def mount_s3_uploader(column, uploader=nil, options={}, &block)
      mount_s3_base(column, uploader, options, &block)
      mod = Module.new
      include mod
      mod.class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{column}_presigned
          uploader = s3_mounter(:#{column}).blank_uploader

          ex_opts = {}
          ft = uploader.file_type.to_s
          case ft
          when 'text', 'image', 'audio', 'video'
            ex_opts[:content_type_starts_with] = "\#{ft}/"
          when 'binary' # 不希望被浏览器识别的文件，比如危险js文件
            ex_opts[:content_type] = 'binary/octet-stream'
          else # pdf docx xlsx etc
            ex_opts[:content_type_starts_with] = 'application/'
          end

          x = S3Uploader.config.bucket(uploader.bucket).presigned_post(
            ex_opts.merge(
              key: uploader.key,
              acl: uploader.acl,
              success_action_status: '201',
              signature_expiration: Time.current.since(uploader.signature_expiration.seconds)
            )
          )

          [x.url, x.fields]
        end

        def #{column}
          s3_mounter(:#{column}).uploaders[0] ||= s3_mounter(:#{column}).blank_uploader
        end

        def #{column}=(f)
          orig_v = read_attribute(:#{column})
          uploader = s3_mounter(:#{column}).blank_uploader
          v = uploader.persistence_path(f)
          if orig_v != v
            super(v)
            __send__(:"#{column}_will_change!")
          end
        end
      RUBY
    end

    def mount_s3_uploaders(column, uploader=nil, options={}, &block)
      mount_s3_base(column, uploader, options, &block)
    end

    private
    def mount_s3_base(column, uploader=nil, options={}, &block)
      include S3Uploader::Mount::Extension

      uploader = build_s3_uploader(uploader, &block)
      s3_uploaders[column.to_sym] = uploader
      s3_uploader_options[column.to_sym] = options.with_indifferent_access

      # Make sure to write over accessors directly defined on the class.
      # Simply super to the included module below.
      class_eval <<-RUBY, __FILE__, __LINE__+1
        def #{column}; super; end
        def #{column}=(new_file); super; end
      RUBY

      mod = Module.new
      include mod

      mod.class_eval <<-RUBY, __FILE__, __LINE__+1

      RUBY
    end

    def build_s3_uploader(uploader, &block)
      return uploader if uploader && !block_given?

      uploader = Class.new(uploader || S3Uploader::Base)
      const_set("S3Uploader#{uploader.object_id}".tr('-', '_'), uploader)

      if block_given?
        uploader.class_eval(&block)
        uploader.recursively_apply_block_to_versions(&block)
      end

      uploader
    end

    module Extension
      def s3_mounter(column)
        return ::S3Uploader::Mounter.new(self, column) if frozen?
        @_s3_mounters ||= {}
        @_s3_mounters[column] ||= ::S3Uploader::Mounter.new(self, column)
      end
    end
  end
end
