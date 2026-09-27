require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::Product do
  def build_piece(attributes = {})
    build(:product, attributes)
  end

  it 'defaults food_safe and dishwasher_safe to false' do
    piece = build_piece
    piece.save!

    expect(piece.food_safe).to be(false)
    expect(piece.dishwasher_safe).to be(false)
  end

  it 'reads back the material and safety facts that were written' do
    piece = build_piece(clay: 'Stoneware', glaze: 'Celadon', food_safe: true, dishwasher_safe: true)
    piece.save!
    piece.reload

    expect(piece.clay).to eq('Stoneware')
    expect(piece.glaze).to eq('Celadon')
    expect(piece.food_safe).to be(true)
    expect(piece.dishwasher_safe).to be(true)
  end

  it 'stores the clay and glaze facts inside the details column' do
    piece = build_piece(clay: 'Stoneware', glaze: 'Celadon')
    piece.save!

    expect(piece.details).to eq('clay' => 'Stoneware', 'glaze' => 'Celadon')
  end
end
