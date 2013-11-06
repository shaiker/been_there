S3_CONFIG = YAML.load_file("#{Rails.root}/config/s3.yml")[Rails.env]

CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => S3_CONFIG["aws_access_key_id"],
    :aws_secret_access_key  => S3_CONFIG["aws_secret_access_key"],
    :region                 => 'us-east-1'
  }

  config.fog_directory  = S3_CONFIG["bucket"]

  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}

  config.storage = :fog

  # begin
  #   config.fog_host     = S3_CONFIG["asset_host"]
  # rescue
  #   config.asset_host   = S3_CONFIG["asset_host"]
  # end
end

