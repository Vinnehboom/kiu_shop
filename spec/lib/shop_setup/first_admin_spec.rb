require 'solidus_starter_frontend_spec_helper'

RSpec.describe ShopSetup::FirstAdmin do
  def setup_first_admin(email: 'owner@example.com', password: 'a-long-secret')
    described_class.new(email: email, password: password).call
  end

  def capture_streams
    stdout = StringIO.new
    stderr = StringIO.new
    original = [$stdout, $stderr]
    $stdout = stdout
    $stderr = stderr
    yield
    [stdout.string, stderr.string]
  ensure
    $stdout, $stderr = original
  end

  it 'creates an admin who can sign in with the password' do
    setup_first_admin

    admin = Spree::User.find_by!(email: 'owner@example.com')
    expect(admin.has_spree_role?('admin')).to be(true)
    expect(admin.valid_password?('a-long-secret')).to be(true)
  end

  it 'does nothing when an admin exists' do
    existing = create(:admin_user)

    setup_first_admin

    expect(Spree::User.admin).to contain_exactly(existing)
  end

  it 'does nothing and warns when the email is blank' do
    _out, err = capture_streams { setup_first_admin(email: '') }

    expect(Spree::User.admin).to be_empty
    expect(err).to include('ADMIN_EMAIL and ADMIN_PASSWORD')
  end

  it 'does nothing and warns when the password is blank' do
    _out, err = capture_streams { setup_first_admin(password: nil) }

    expect(Spree::User.admin).to be_empty
    expect(err).to include('ADMIN_EMAIL and ADMIN_PASSWORD')
  end

  it 'does not promote a user who has the same email' do
    customer = create(:user, email: 'owner@example.com')

    _out, err = capture_streams { setup_first_admin }

    expect(customer.reload.has_spree_role?('admin')).to be(false)
    expect(err).to include('ADMIN_EMAIL exists')
    expect(err).not_to include('owner@example.com')
  end

  it 'matches an existing user whatever the case of the email' do
    customer = create(:user, email: 'owner@example.com')

    capture_streams { setup_first_admin(email: 'Owner@Example.com') }

    expect(customer.reload.has_spree_role?('admin')).to be(false)
    expect(Spree::User.count).to eq(1)
  end

  it 'warns without the password and creates nothing when the admin is invalid' do
    _out, err = capture_streams { setup_first_admin(password: 'abc') }

    expect(Spree::User.admin).to be_empty
    expect(err).to include('Password')
    expect(err).not_to include('abc ')
  end

  it 'never writes the password to the output' do
    out, err = capture_streams { setup_first_admin }

    expect(out + err).not_to include('a-long-secret')
  end
end
