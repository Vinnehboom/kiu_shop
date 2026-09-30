require 'solidus_starter_frontend_spec_helper'

RSpec.describe ShopSetup::DefaultPermissionSets do
  def setup_permission_sets
    described_class.new.call
  end

  def load_permission_set_without_privilege
    Spree::PermissionSets.const_get(:PromotionManagement)
  end

  it 'creates the Solidus core permission sets' do
    setup_permission_sets

    expect(Spree::PermissionSet.find_by(set: 'Spree::PermissionSets::SuperUser')).to have_attributes(
      name: 'SuperUser',
      privilege: 'other',
      category: 'super_user'
    )
  end

  it 'creates each permission set once when it runs twice' do
    setup_permission_sets
    setup_permission_sets

    expect(Spree::PermissionSet.group(:set).having('count(*) > 1').count).to be_empty
  end

  it 'skips permission sets from other gems that define no privilege' do
    load_permission_set_without_privilege

    setup_permission_sets

    expect(Spree::PermissionSet.where(set: 'Spree::PermissionSets::PromotionManagement')).to be_empty
  end
end
