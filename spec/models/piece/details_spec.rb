require 'rails_helper'

RSpec.describe Piece::Details do
  it 'is empty when nothing is known about the piece' do
    expect(described_class.empty).to have_attributes(clay: nil, glaze: nil)
  end

  it 'defaults each fact to nil' do
    expect(described_class.new(clay: 'Stoneware')).to have_attributes(clay: 'Stoneware', glaze: nil)
  end

  it 'lists only the facts that are filled in' do
    details = described_class.new(clay: 'Stoneware', glaze: ' ')

    expect(details.filled).to eq(clay: 'Stoneware')
  end

  it 'lists no facts when it is empty' do
    expect(described_class.empty.filled).to eq({})
  end

  it 'is empty when no fact is filled in' do
    expect(described_class.new(clay: ' ')).to be_empty
  end

  it 'is not empty when a fact is filled in' do
    expect(described_class.new(glaze: 'Celadon')).not_to be_empty
  end

  it 'serializes to its facts as JSON' do
    details = described_class.new(clay: 'Stoneware', glaze: 'Celadon')

    expect(details.as_json).to eq('clay' => 'Stoneware', 'glaze' => 'Celadon')
  end

  it 'returns a changed copy and leaves the original alone' do
    original = described_class.new(clay: 'Stoneware')
    changed = original.with(glaze: 'Celadon')

    expect(changed).to have_attributes(clay: 'Stoneware', glaze: 'Celadon')
    expect(original.glaze).to be_nil
  end
end
