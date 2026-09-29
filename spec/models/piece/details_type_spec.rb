require 'rails_helper'

RSpec.describe Piece::DetailsType do
  subject(:type) { described_class.new }

  let(:details) { Piece::Details.new(clay: 'Stoneware', glaze: 'Celadon') }

  describe '#cast' do
    it 'keeps a Piece::Details as it is' do
      expect(type.cast(details)).to eq(details)
    end

    it 'builds a Piece::Details from a hash with string keys' do
      expect(type.cast('clay' => 'Stoneware', 'glaze' => 'Celadon')).to eq(details)
    end

    it 'builds a Piece::Details from a hash with symbol keys' do
      expect(type.cast(clay: 'Stoneware', glaze: 'Celadon')).to eq(details)
    end

    it 'drops keys it does not know' do
      expect(type.cast('clay' => 'Stoneware', 'kiln' => 'Electric')).to eq(Piece::Details.new(clay: 'Stoneware'))
    end

    it 'turns nil into empty details' do
      expect(type.cast(nil)).to eq(Piece::Details.empty)
    end
  end

  describe '#serialize' do
    it 'writes the facts as a JSON object' do
      expect(JSON.parse(type.serialize(details))).to eq('clay' => 'Stoneware', 'glaze' => 'Celadon')
    end

    it 'writes a hash the same way' do
      expect(JSON.parse(type.serialize('clay' => 'Stoneware'))).to eq('clay' => 'Stoneware', 'glaze' => nil)
    end
  end

  describe '#deserialize' do
    it 'reads a stored JSON object' do
      expect(type.deserialize('{"clay":"Stoneware","glaze":"Celadon"}')).to eq(details)
    end

    it 'reads a stored object that lacks a key' do
      expect(type.deserialize('{"clay":"Stoneware"}')).to eq(Piece::Details.new(clay: 'Stoneware'))
    end

    it 'reads the empty default of the column' do
      expect(type.deserialize('{}')).to eq(Piece::Details.empty)
    end

    it 'reads a missing value as empty details' do
      expect(type.deserialize(nil)).to eq(Piece::Details.empty)
    end

    it 'round-trips through serialize' do
      expect(type.deserialize(type.serialize(details))).to eq(details)
    end
  end
end
