require 'rails_helper'

RSpec.describe Piece::Details do
  subject(:details) { described_class.new(**facts) }

  context 'when nothing is known about the piece' do
    subject { described_class.empty }

    it { is_expected.to be_empty }
    it { is_expected.to have_attributes(clay: nil, glaze: nil) }
  end

  context 'when only the clay is known' do
    let(:facts) { { clay: 'Stoneware' } }

    it { is_expected.not_to be_empty }
    it { is_expected.to have_attributes(clay: 'Stoneware', glaze: nil) }
  end

  context 'when every fact is blank' do
    let(:facts) { { clay: ' ', glaze: '' } }

    it { is_expected.to be_empty }
  end

  context 'when every fact is known' do
    let(:facts) { { clay: 'Stoneware', glaze: 'Celadon' } }

    it 'shares its facts as JSON' do
      expect(details.as_json).to eq('clay' => 'Stoneware', 'glaze' => 'Celadon')
    end

    it 'changes a fact in a copy and leaves the original alone' do
      changed = details.with(glaze: 'Tenmoku')

      expect(changed).to have_attributes(clay: 'Stoneware', glaze: 'Tenmoku')
      expect(details.glaze).to eq('Celadon')
    end
  end
end
