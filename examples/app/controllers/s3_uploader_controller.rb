class S3UploaderController < ApplicationController
  # https://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Bucket.html#presigned_post-instance_method
  def index
    selected_field = params[:field]
    clazz = params[:clazz].camelize.constantize

    show_name = clazz.human_attribute_name(selected_field)

    presigned_url, presigned_fields, ex_opts = clazz.new.send("#{selected_field}_presigned")

    result = [
      view_context.label_tag(:file, show_name),
      view_context.file_field_tag(:file, data: {
            s3endpoint: presigned_url,
            fields: presigned_fields.to_json
          }.merged(ex_opts))
    ]

    render text: result.join("\n"), layout: nil
  end
end
