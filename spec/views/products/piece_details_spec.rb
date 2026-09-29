require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'products/_piece_details' do
  def rendered_rows(product)
    render partial: 'products/piece_details', locals: { product: product }
    Capybara.string(rendered).all('tbody tr').map { |row| row.all('td').map(&:text) }
  end

  it 'lists the facts as label and value rows in a fixed order' do
    piece = build(:product, weight: BigDecimal('0.850'), height: 12, width: 9, depth: 9,
                            clay: 'Stoneware', glaze: 'Celadon', food_safe: true, dishwasher_safe: true)

    expect(rendered_rows(piece)).to eq(
      [
        ['Weight', '0.85'],
        ['Dimensions', '12 x 9 x 9'],
        ['Clay', 'Stoneware'],
        ['Glaze', 'Celadon'],
        ['Food safe', 'Yes'],
        ['Dishwasher safe', 'Yes']
      ]
    )
  end

  it 'leaves out the facts that are not set' do
    piece = build(:product, weight: 0, height: nil, width: nil, depth: nil, glaze: 'Celadon', dishwasher_safe: true)

    expect(rendered_rows(piece)).to eq([['Glaze', 'Celadon'], ['Dishwasher safe', 'Yes']])
  end

  it 'renders nothing when no fact is set' do
    piece = build(:product, weight: 0, height: nil, width: nil, depth: nil)

    expect(rendered_rows(piece)).to eq([])
  end
end
