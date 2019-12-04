module S3Uploader
  class Mounter
    attr_reader :record, :column, :options
    def initialize(record, column, options = {})
      @record = record
      @column = column
      @options = record.class.s3_uploader_options[column]
    end

    def uploader
      record.class.s3_uploaders[column]
    end

    def blank_uploader
      uploader.new(record, column, options)
    end

    def read_identifiers
      [record.read_attribute(column)].flatten.reject(&:blank?)
    end

    def uploaders
      @uploader ||= read_identifiers.map do |identifier|
        uploader = blank_uploader
        uploader.retrieve_from_s3!(identifier) if identifier.present?
        uploader
      end
    end
  end
end
