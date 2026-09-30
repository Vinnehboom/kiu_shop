require 'solidus_starter_frontend_spec_helper'

RSpec.describe ShopSetup::DefaultStore do
  def setup_default_store(name: 'Kiu Pottery', url: 'kiu.example.com', mail_from: 'hello@kiu.example.com')
    described_class.new(name: name, url: url, mail_from: mail_from).call
  end

  it 'creates one store from the given values' do
    setup_default_store

    expect(Spree::Store.count).to eq(1)
    expect(Spree::Store.first).to have_attributes(
      name: 'Kiu Pottery',
      code: 'kiu-pottery',
      url: 'kiu.example.com',
      mail_from_address: 'hello@kiu.example.com'
    )
  end

  it 'does nothing when a store exists' do
    create(:store, name: 'Existing', code: 'existing')

    setup_default_store

    expect(Spree::Store.pluck(:code)).to eq(['existing'])
  end

  it 'raises when the name is blank' do
    expect { setup_default_store(name: nil) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
