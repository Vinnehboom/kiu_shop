require 'rails_helper'
require 'active_storage/service/s3_service'

RSpec.describe ActiveStorage::Service::S3Service do
  def r2_variables
    {
      'R2_ACCOUNT_ID' => 'acct123',
      'R2_ACCESS_KEY_ID' => 'key-id-abc',
      'R2_SECRET_ACCESS_KEY' => 'secret-xyz',
      'R2_BUCKET' => 'pottery-photos'
    }
  end

  def parse_storage_config
    YAML.safe_load(ERB.new(Rails.root.join('config/storage.yml').read).result, aliases: true)
  end

  def with_r2_variables(values)
    saved = r2_variables.keys.index_with { |name| ENV.fetch(name, nil) }
    values.each { |name, value| ENV[name] = value }
    yield
  ensure
    saved.each { |name, value| ENV[name] = value }
  end

  it 'builds a service for the configured bucket' do
    with_r2_variables(r2_variables) do
      service = ActiveStorage::Service.configure(:cloudflare_r2, parse_storage_config.deep_symbolize_keys)

      expect(service.bucket.name).to eq('pottery-photos')
    end
  end

  it 'reads the Cloudflare R2 settings from the environment' do
    with_r2_variables(r2_variables) do
      r2 = parse_storage_config.fetch('cloudflare_r2')

      expect(r2).to include(
        'service' => 'S3',
        'endpoint' => 'https://acct123.r2.cloudflarestorage.com',
        'access_key_id' => 'key-id-abc',
        'secret_access_key' => 'secret-xyz',
        'bucket' => 'pottery-photos',
        'region' => 'auto'
      )
    end
  end

  it 'asks the SDK for checksums only when the operation requires them' do
    with_r2_variables(r2_variables) do
      r2 = parse_storage_config.fetch('cloudflare_r2')

      expect(r2).to include(
        'request_checksum_calculation' => 'when_required',
        'response_checksum_validation' => 'when_required'
      )
    end
  end

  it 'parses when the R2 variables are not set' do
    with_r2_variables(r2_variables.transform_values { nil }) do
      expect(parse_storage_config).to include('cloudflare_r2', 'test', 'local')
    end
  end

  it 'holds no literal secret' do
    expect(Rails.root.join('config/storage.yml').read).not_to match(/secret_access_key:\s*[^<\s]/)
  end
end
