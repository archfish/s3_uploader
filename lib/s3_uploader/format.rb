module S3Uploader
  class Format
    attr_reader :scheme, :bucket, :path

    def initialize(path, default = {})
      @scheme = default[:scheme]
      @bucket = default[:bucket]
      if path.include?('://')
        @scheme, remain = path.split("://", 2)
        @bucket, @path = remain.split('/', 2)
      else
        @path = path
      end
    end

    def to_s
      "#{scheme}://#{bucket}/#{path}"
    end
  end
end
