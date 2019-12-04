module S3Uploader
  class Base
    SCHEME = 's3'.freeze
    attr_reader :model, :mounted_as, :s3_object

    def initialize(model, mounted_as, options = {})
      @model = model
      @mounted_as = mounted_as
      @s3_object = nil
      @options = options.dup
    end

    def to_s
      s3_object&.key.to_s
    end

    def bucket
      @options.fetch(__method__) {
        'public'
      }
    end

    # 'public-read' : 'private'
    def acl
      @options.fetch(__method__) {
        'public-read'
      }
    end

    def key
      @options.fetch(__method__) {
        "#{store_path}/${filename}"
      }
    end

    # text image audio video
    # binary
    # pdf docx xlsx etc
    # nil 不限制
    def file_type
      @options.fetch(__method__) {
        :binary
      }
    end

    def signature_expiration
      @options.fetch(__method__) {
        30.minute.to_i
      }
    end

    def external_url
      url_ = case acl
      when 'public-read'
        s = model&.updated_at || model&.created_at
        s = "?t=#{s.tv_sec}" if s.present?

        s3_object.public_url + s.to_s
      else
        s3_object.presigned_url(:get, {expires_in: signature_expiration})
      end

      URI.encode(url_)
    end

    def persistence_path(filename)
      return nil if filename.blank?
      return filename if filename.start_with?(SCHEME)

      "#{SCHEME}://#{bucket}/#{key}".sub('${filename}', filename)
    end

    def retrieve_from_s3!(path)
      uri = S3Uploader::Format.new(path, scheme: SCHEME, bucket: bucket)
      return if uri.scheme != SCHEME
      @s3_object = S3Uploader.config.bucket(uri.bucket).object(uri.path)
    end

    private
    def store_path
      @options.fetch(__method__) {
        "#{model.class.to_s.underscore}/#{mounted_as}"
      }
    end
  end
end
