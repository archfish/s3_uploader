class Doc < ActiveRecord::Base
  mount_s3_uploader :doc1, BaseUploader
end
