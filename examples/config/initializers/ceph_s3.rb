class CephS3
  def initialize
    @config = {
                bucket: 'reocar',
                access_key: "QQQQZZZZZZAAAAAQQQQQ",
                secret_key: "TbGENCxXjSP4ebl3o4vCzlGREQf76CMOZnXNPTow",
                bucket_prefix: '',
                endpoint: 'http://nginx.ceph.lan',
                cdn_endpoint: 'http://nginx.ceph.lan',
                rgw: 'http://rgw.ceph.lan:7480',
                region: 'us-east-1'
              }
  end

  def aws_attributes
    {
      expires_in: 30.minute.to_i
    }
  end

  def aws_credentials
    {
      access_key_id:     @config['access_key'],
      secret_access_key: @config['secret_key'],
      force_path_style:  true,
      endpoint:          @config['rgw'],
      region:            @config['region'], # Required
      stub_responses:    Rails.env.test? # Optional, avoid hitting S3 actual during tests
    }.freeze
  end

  def endpoint(for_cdn = false)
    for_cdn ? @config['cdn_endpoint'] : @config['endpoint']
  end

  def bucket_prefix
    ENV.fetch('MY_BUCKET_PREFIX'){@config['bucket_prefix'].to_s}
  end

  def default_bucket
    @config['bucket']
  end

  def default_acl
    'public-read'
  end

  def bucket(name, cdn = false)
    Aws::S3::Bucket.new(name.to_s, aws_credentials.merge(endpoint: endpoint(cdn)))
  end
end

require 's3_uploader'

S3Uploader.config = CephS3.new
