require 'rails_helper'

RSpec.describe Piece::Measurements do
  def measurements(weight: nil, height: nil, width: nil, depth: nil)
    described_class.new(weight, height, width, depth)
  end

  describe 'the weight a shopper sees' do
    it 'drops trailing zeros' do
      expect(measurements(weight: BigDecimal('0.850')).formatted_weight).to eq('0.85')
    end

    it 'shows a whole weight without decimals' do
      expect(measurements(weight: BigDecimal('2.0')).formatted_weight).to eq('2')
    end

    it 'is hidden when the seller left the weight at zero' do
      expect(measurements(weight: 0).formatted_weight).to be_nil
    end

    it 'is hidden when the weight is unknown' do
      expect(measurements.formatted_weight).to be_nil
    end
  end

  describe 'the size a shopper sees' do
    it 'reads as height x width x depth' do
      expect(measurements(height: BigDecimal('12.0'), width: BigDecimal('9.50'), depth: 9).formatted_dimensions)
        .to eq('12 x 9.5 x 9')
    end

    it 'shows only the sides the seller measured' do
      expect(measurements(height: 12, depth: 9).formatted_dimensions).to eq('12 x 9')
    end

    it 'is hidden when no side is measured' do
      expect(measurements(weight: 1).formatted_dimensions).to be_nil
    end
  end

  context 'when the piece has no weight and no size' do
    subject { measurements(weight: 0) }

    it { is_expected.to be_empty }
  end

  context 'when the piece has only a weight' do
    subject { measurements(weight: 1) }

    it { is_expected.not_to be_empty }
  end

  context 'when the piece has only a size' do
    subject { measurements(width: 1) }

    it { is_expected.not_to be_empty }
  end

  context 'when nothing is known about the piece' do
    subject { described_class.empty }

    it { is_expected.to be_empty }
  end
end
