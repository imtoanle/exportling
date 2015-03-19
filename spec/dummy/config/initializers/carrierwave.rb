CarrierWave.configure do |config|
  config.storage = :fog

  # Can't use Fog.mock! (see spec/support/fog.rb for usage) for local provider,
  # so need to use AWS
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: 'xxx',
    aws_secret_access_key: 'yyy',
    aws_signature_version: 2,
    host: ''
  }
end
