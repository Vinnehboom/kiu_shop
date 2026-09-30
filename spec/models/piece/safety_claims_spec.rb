require 'rails_helper'

RSpec.describe Piece::SafetyClaims do
  context 'when the seller claims both' do
    subject { described_class.new(true, true) }

    it { is_expected.not_to be_empty }
    it { is_expected.to have_attributes(claimed: %i[food_safe dishwasher_safe]) }
  end

  context 'when the seller claims only one' do
    subject { described_class.new(false, true) }

    it { is_expected.not_to be_empty }
    it { is_expected.to have_attributes(claimed: %i[dishwasher_safe]) }
  end

  context 'when the seller claims nothing' do
    subject { described_class.new(false, false) }

    it { is_expected.to be_empty }
    it { is_expected.to have_attributes(claimed: []) }
  end

  context 'when nothing is known' do
    subject { described_class.new(nil, nil) }

    it { is_expected.to have_attributes(claimed: []) }
  end
end
