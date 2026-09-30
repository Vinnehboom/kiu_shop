Piece::Measurements = Data.define(:weight, :height, :width, :depth) do
  def self.empty
    new(nil, nil, nil, nil)
  end

  def empty?
    !weight? && !dimensions?
  end

  def formatted_weight
    format_number(weight) if weight?
  end

  def formatted_dimensions
    dimensions.map { |dimension| format_number(dimension) }.join(' x ').presence
  end

  private

  def weight?
    weight.present? && weight.positive?
  end

  def dimensions?
    dimensions.any?
  end

  def dimensions
    [height, width, depth].compact
  end

  def format_number(number)
    ActiveSupport::NumberHelper.number_to_rounded(number, precision: 3, strip_insignificant_zeros: true)
  end
end
