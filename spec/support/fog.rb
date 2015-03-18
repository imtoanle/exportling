# Don't let our specs upload any files to external storage
Fog.mock!

RSpec.configure do |config|
  config.before :all do
    connection = Fog::Storage.new({
        provider: 'AWS',
        aws_access_key_id: 'xxx',
        aws_secret_access_key: 'yyy',
        host: ''
      })

    # As we are mocking fog, we don't have access to any existing buckets,
    # so we need to create our test bucket here.
    connection.directories.create(
      key: 'exportling_spec_directory',
      public: false
    )
  end
end
