class BaseUploader < ::S3Uploader::Base
  def bucket
    :material
  end

  def file_type
    :image
  end
end
