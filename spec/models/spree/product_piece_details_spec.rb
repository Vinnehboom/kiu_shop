require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::Product do
  def build_piece(attributes = {})
    build(:product, attributes)
  end

  def create_piece_with_stored_details(json)
    piece = create(:product)
    described_class.connection.exec_update(
      'UPDATE spree_products SET details = $1::jsonb WHERE id = $2', 'SQL', [json, piece.id]
    )
    piece.reload
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

  it 'holds the clay and glaze facts as one Piece::Details value' do
    piece = build_piece(clay: 'Stoneware', glaze: 'Celadon')
    piece.save!
    piece.reload

    expect(piece.details).to eq(Piece::Details.new(clay: 'Stoneware', glaze: 'Celadon'))
  end

  it 'starts with empty details' do
    expect(build_piece.details).to eq(Piece::Details.empty)
  end

  it 'marks details as changed when the clay changes, and saves the change' do
    piece = create(:product, clay: 'Stoneware')
    piece.clay = 'Porcelain'

    expect(piece).to be_details_changed

    piece.save!

    expect(piece.reload.clay).to eq('Porcelain')
  end

  it 'keeps the glaze when only the clay changes' do
    piece = create(:product, clay: 'Stoneware', glaze: 'Celadon')
    piece.update!(clay: 'Porcelain')

    expect(piece.reload.details).to eq(Piece::Details.new(clay: 'Porcelain', glaze: 'Celadon'))
  end

  it 'stores the facts as a JSON object in the details column' do
    piece = create(:product, clay: 'Stoneware', glaze: 'Celadon')

    stored = described_class.where(id: piece.id).pick(Arel.sql('details::text AS raw_details'))

    expect(JSON.parse(stored)).to eq('clay' => 'Stoneware', 'glaze' => 'Celadon')
  end

  it 'loads rows that were stored before the value object existed' do
    piece = create_piece_with_stored_details('{"clay": "Stoneware", "glaze": "Celadon"}')

    expect(piece.details).to eq(Piece::Details.new(clay: 'Stoneware', glaze: 'Celadon'))
  end

  it 'loads rows whose details are empty' do
    expect(create_piece_with_stored_details('{}').details).to eq(Piece::Details.empty)
  end

  it "exposes its master's weight and dimensions as measurements" do
    piece = create(:product, weight: 0.85, height: 12, width: 9, depth: 9)

    expect(piece.reload.measurements).to eq(Piece::Measurements.new(0.85, 12, 9, 9))
  end

  it 'has empty measurements when no size is known' do
    piece = create(:product, weight: nil, height: nil, width: nil, depth: nil)

    expect(piece.reload.measurements).to be_empty
  end

  it 'exposes its safety claims as one value' do
    piece = create(:product, food_safe: true, dishwasher_safe: false)

    expect(piece.reload.safety_claims).to eq(Piece::SafetyClaims.new(true, false))
  end

  it 'reports a withdrawn safety claim on the next read' do
    piece = create(:product, food_safe: true, dishwasher_safe: true)
    expect(piece.safety_claims.claimed).to eq(%i[food_safe dishwasher_safe])

    piece.update!(food_safe: false)
    piece.dishwasher_safe = false

    expect(piece.safety_claims).to be_empty
  end

  it 'reports a changed size on the next read' do
    piece = create(:product, weight: 0.85, height: 12)
    expect(piece.measurements.weight).to eq(0.85)

    piece.update!(weight: 1.5, height: 20)
    piece.width = 8
    piece.depth = 7

    expect(piece.measurements).to eq(Piece::Measurements.new(1.5, 20, 8, 7))
  end

  it 'reports a changed size on the master variant on the next read' do
    variant = create(:product, weight: 1).master
    expect(variant.measurements.weight).to eq(1)

    variant.weight = 2

    expect(variant.measurements.weight).to eq(2)
  end
end
