require 'solidus_starter_frontend_spec_helper'

RSpec.describe PieceDetailRowComponent, type: :component do
  def rendered_row(value)
    render_inline(described_class.new(label: 'Clay', value: value))
    page.all('tr').map { |row| row.all('td').map(&:text) }
  end

  it 'shows a fact as a label and a value' do
    expect(rendered_row('Stoneware')).to eq([%w[Clay Stoneware]])
  end

  it 'shows nothing when the fact is blank' do
    expect(rendered_row(' ')).to eq([])
  end

  it 'shows nothing when the fact is unknown' do
    expect(rendered_row(nil)).to eq([])
  end
end
