require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Database seeds', type: :task do
  def with_env(values)
    saved = values.keys.index_with { |key| ENV.fetch(key, nil) }
    values.each { |key, value| ENV[key] = value }
    yield
  ensure
    saved.each { |key, value| ENV[key] = value }
  end

  def seed_database
    with_env('ADMIN_EMAIL' => 'owner@example.com', 'ADMIN_PASSWORD' => 'a-long-secret') do
      load Rails.root.join('db/seeds.rb')
    end
  end

  def duplicate_permission_sets
    Spree::PermissionSet.group(:set).having('count(*) > 1').count
  end

  it 'creates the store and the first admin' do
    seed_database

    expect(Spree::Store.pluck(:name)).to eq([Rails.configuration.x.shop.name])
    expect(Spree::Store.where(code: 'sample-store')).to be_empty
    expect(Spree::User.admin.pluck(:email)).to eq(['owner@example.com'])
  end

  it 'is safe to run twice' do
    seed_database
    permission_sets = Spree::PermissionSet.count
    seed_database

    expect(permission_sets).to be_positive
    expect(Spree::PermissionSet.count).to eq(permission_sets)
    expect(duplicate_permission_sets).to be_empty
    expect(Spree::Store.count).to eq(1)
    expect(Spree::User.admin.count).to eq(1)
    expect(Spree::StockLocation.count).to eq(1)
  end

  it 'creates the admin on a later run when the variables are set after the first run' do
    with_env('ADMIN_EMAIL' => nil, 'ADMIN_PASSWORD' => nil) do
      capture_warnings { load Rails.root.join('db/seeds.rb') }
    end
    seed_database

    expect(Spree::User.admin.pluck(:email)).to eq(['owner@example.com'])
  end

  def capture_warnings
    original = $stderr
    $stderr = StringIO.new
    yield
  ensure
    $stderr = original
  end
end
