require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'A sold one-off piece', type: :system do
  def seed_default_stock_location
    Spree::StockLocation.create!(name: 'default', backorderable_default: true)
    PotteryShop::StockLocationDefaults.enforce!
  end

  def create_single_piece
    seed_default_stock_location
    piece = create(:product)
    piece.master.stock_items.first.set_count_on_hand(1)
    piece
  end

  def default_store
    Spree::Store.first || create(:store)
  end

  def create_shippable_country
    country = Spree::Country.find_by(iso: 'US') || create(:country)
    zone = create(:zone)
    zone.members << Spree::ZoneMember.create(zoneable: country)

    shipping_method = create(:shipping_method, zones: [zone])
    shipping_method.calculator.update(preferred_amount: 10, preferred_currency: Spree::Config[:currency])

    country
  end

  def build_order_to_confirm(variant, email:)
    country = create_shippable_country
    state = create(:state, country: country)

    order = Spree::Order.create!(email: email, store: default_store)
    order.contents.add(variant)
    order.next!

    order.bill_address = create(:address, country: country, state: state)
    order.ship_address = create(:address, country: country, state: state)
    order.next!
    order.next!

    credit_card = create(:credit_card)
    order.payments.create!(payment_method: credit_card.payment_method, amount: order.total, source: credit_card)
    order.next!
    order
  end

  def complete_order(order)
    order.payment_state = 'paid'
    order.complete!
  end

  def complete_purchase(variant)
    order = build_order_to_confirm(variant, email: 'buyer@example.com')
    complete_order(order)
    order
  end

  it 'leaves the storefront showing it as out of stock' do
    piece = create_single_piece
    complete_purchase(piece.master)

    visit product_path(piece)

    expect(page).to have_content('Out of Stock')
  end

  it 'refuses to sell it to a second buyer who starts after the sale' do
    piece = create_single_piece
    complete_purchase(piece.master)

    expect do
      build_order_to_confirm(piece.master, email: 'second-buyer@example.com')
    end.to raise_error(Spree::Order::InsufficientStock)
  end

  it 'refuses to sell it to a second buyer who was already checking out' do
    piece = create_single_piece
    first_order = build_order_to_confirm(piece.master, email: 'first-buyer@example.com')
    second_order = build_order_to_confirm(piece.master, email: 'second-buyer@example.com')

    complete_order(first_order)

    expect { complete_order(second_order) }.to raise_error(ActiveRecord::RecordInvalid)
  end
end
