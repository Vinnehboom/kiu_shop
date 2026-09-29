require 'rails_helper'

RSpec.describe Piece::Measurements do
  def measurements(weight: nil, height: nil, width: nil, depth: nil)
    described_class.new(weight, height, width, depth)
  end

  describe '#weight?' do
    it 'is true for a positive weight' do
      expect(measurements(weight: 0.85)).to be_weight
    end

    it 'is false for a zero weight' do
      expect(measurements(weight: 0)).not_to be_weight
    end

    it 'is false when the weight is unknown' do
      expect(measurements).not_to be_weight
    end
  end

  describe '#formatted_weight' do
    it 'drops zeros that carry no meaning' do
      expect(measurements(weight: BigDecimal('0.850')).formatted_weight).to eq('0.85')
    end

    it 'shows a whole weight without decimals' do
      expect(measurements(weight: BigDecimal('2.0')).formatted_weight).to eq('2')
    end
  end

  describe '#dimensions?' do
    it 'is true when one dimension is known' do
      expect(measurements(height: 12)).to be_dimensions
    end

    it 'is false when no dimension is known' do
      expect(measurements(weight: 1)).not_to be_dimensions
    end
  end

  describe '#formatted_dimensions' do
    it 'joins the dimensions that are known' do
      expect(measurements(height: BigDecimal('12.0'), width: BigDecimal('9.50'), depth: 9).formatted_dimensions)
        .to eq('12 x 9.5 x 9')
    end

    it 'skips a dimension that is unknown' do
      expect(measurements(height: 12, depth: 9).formatted_dimensions).to eq('12 x 9')
    end
  end

  describe '#empty?' do
    it 'is true when there is no weight and no dimension' do
      expect(measurements(weight: 0)).to be_empty
    end

    it 'is false when there is a weight' do
      expect(measurements(weight: 1)).not_to be_empty
    end

    it 'is false when there is a dimension' do
      expect(measurements(width: 1)).not_to be_empty
    end
  end

  it 'is empty when built with .empty' do
    expect(described_class.empty).to be_empty
  end
end
