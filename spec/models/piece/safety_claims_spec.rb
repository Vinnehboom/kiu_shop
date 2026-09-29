require 'rails_helper'

RSpec.describe Piece::SafetyClaims do
  describe '#claimed' do
    it 'lists the claims that are true, in order' do
      expect(described_class.new(true, true).claimed).to eq(%i[food_safe dishwasher_safe])
    end

    it 'leaves out a claim that is false' do
      expect(described_class.new(false, true).claimed).to eq(%i[dishwasher_safe])
    end

    it 'leaves out a claim that is unknown' do
      expect(described_class.new(nil, nil).claimed).to eq([])
    end
  end

  describe '#empty?' do
    it 'is true when nothing is claimed' do
      expect(described_class.new(false, false)).to be_empty
    end

    it 'is false when something is claimed' do
      expect(described_class.new(true, false)).not_to be_empty
    end
  end
end
