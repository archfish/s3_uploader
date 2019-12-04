module ApplicationHelper
  def s3_upload_field(f, attr_, options = {})
    clazz = (f&.object&.class || options.delete(:clazz)).to_s
    css_class = "s3_uploader #{options.delete(:class)}"
    base_data = options.merge(
      target: SecureRandom.urlsafe_base64(10),
      toggle: 'uploader-modal',
      clazz: clazz,
      url: s3_uploader_index_path(field: attr_, clazz: clazz)
    )
    if f.present?
      f.text_field(attr_, class: css_class, data: base_data).html_safe
    else
      text_field_tag(attr_, class: css_class, data: base_data).html_safe
    end
  end
end
