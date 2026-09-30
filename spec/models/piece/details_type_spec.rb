require 'rails_helper'

RSpec.describe Piece::DetailsType do
  subject(:type) { described_class.new }

  let(:details) { Piece::Details.new(clay: 'Stoneware', glaze: 'Celadon') }

  describe 'taking facts from the admin form or from code' do
    it 'keeps facts that are already in shape' do
      expect(type.cast(details)).to eq(details)
    end

    it 'accepts facts named by string' do
      expect(type.cast('clay' => 'Stoneware', 'glaze' => 'Celadon')).to eq(details)
    end

    it 'accepts facts named by symbol' do
      expect(type.cast(clay: 'Stoneware', glaze: 'Celadon')).to eq(details)
    end

    it 'ignores a fact the shop does not keep' do
      expect(type.cast('clay' => 'Stoneware', 'kiln' => 'Electric')).to eq(Piece::Details.new(clay: 'Stoneware'))
    end

    it 'treats no input as no facts' do
      expect(type.cast(nil)).to be_empty
    end
  end

  describe 'saving to the database' do
    it 'stores the facts as a JSON object' do
      expect(JSON.parse(type.serialize(details))).to eq('clay' => 'Stoneware', 'glaze' => 'Celadon')
    end

    it 'stores a fact that was not given as null' do
      expect(JSON.parse(type.serialize('clay' => 'Stoneware'))).to eq('clay' => 'Stoneware', 'glaze' => nil)
    end
  end

  describe 'loading from the database' do
    it 'loads the stored facts' do
      expect(type.deserialize('{"clay":"Stoneware","glaze":"Celadon"}')).to eq(details)
    end

    it 'loads a row that was saved before a fact existed' do
      expect(type.deserialize('{"clay":"Stoneware"}')).to eq(Piece::Details.new(clay: 'Stoneware'))
    end

    it 'loads a new row as no facts' do
      expect(type.deserialize('{}')).to be_empty
    end

    it 'loads a missing value as no facts' do
      expect(type.deserialize(nil)).to be_empty
    end

    it 'loads exactly what it saved' do
      expect(type.deserialize(type.serialize(details))).to eq(details)
    end
  end
end
