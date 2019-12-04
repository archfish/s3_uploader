# S3Uploader

## 设计思路

通过预签名URL实现安全的页面文件直传。[参考文档][1]，[Ruby SDK][2]

## 使用方法

  - 安装当前gem

    ```ruby
    # Gemfile
    gem 's3_uploader', git: 'https://github.com/archfish/s3_uploader.git'
    ```

  - 配置S3连接参数

    在`config/initializers`下增加一个配置[ceph_s3.rb](examples/config/initializers/ceph_s3.rb)

  - 配置model

    在model中[mount_s3_uploader](examples/app/models/doc.rb)

  - 配置controller

    增加一个[controller](examples/app/controllers/s3_uploader_controller.rb)并配置相应[路由](examples/config/routes.rb)

  - 配置静态资源

    引用[js文件](examples/app/assets/javascripts/application.js)，引用[css文件](examples/app/assets/stylesheets/application.css)

  - 配置helper

    增加[s3_upload_field辅助方法](examples/app/helpers/application_helper.rb)

  - 配置表单

    在表单中[使用helper绑定事件](examples/app/views/docs/_form.erb)

## 扩展配置

  | 键                   | 候选值                    | 说明                                                       | 默认                                   |
  | -------------------- | ------------------------- | ---------------------------------------------------------- | -------------------------------------- |
  | bucket               | 任意                      | 使用前需要先在服务上创建相应bucket                         | public                                 |
  | acl                  | [private，public_read][3] | 按需求配置                                                 | public_read                            |
  | key                  | 任意                      | 需要保留上传文件名时使用${filename}占位符                  | [store_path]/${filename}               |
  | file_type            | [MIME][4]                 | 具体行为需要看[源码file_type定义](lib/s3_uploader/base.rb) | binary                                 |
  | signature_expiration | 整数                      | 预签名链接有效时间，单位秒                                 | 1800                                   |
  | store_path           | 任意                      | 自定义                                                     | model.class.to_s.underscore/mounted_as |

## 扩展实现

  - model中mount字段时配置（推荐）

    ```ruby
    # 指定bucket名称
    mount_s3_uploader :door_header_url, BaseUploader, bucket: :material
    ```

  - 自定义Uploader同名方法

    ```ruby
    # uploaders/base_uploader.rb
    class BaseUploader < ::S3Uploader::Base
      def bucket
        :material
      end
    end
    ```

[1]: https://docs.aws.amazon.com/zh_cn/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html "Authenticating Requests in Browser-Based Uploads Using POST"
[2]: https://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3/PresignedPost.html "Ruby S3 SDK"
[3]: https://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3/S3Object.html#acl-instance_method "Access Control List"
[4]: https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Basics_of_HTTP/MIME_types "MIME 类型"
