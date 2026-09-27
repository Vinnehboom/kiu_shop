module PieceDetailsHelper
  def piece_facts(product)
    [
      weight_fact(product),
      dimensions_fact(product),
      text_fact(product, :clay),
      text_fact(product, :glaze),
      claim_fact(product, :food_safe),
      claim_fact(product, :dishwasher_safe)
    ].compact
  end

  private

  def weight_fact(product)
    return unless product.weight.present? && product.weight.positive?

    [Spree::Product.human_attribute_name(:weight), format_piece_number(product.weight)]
  end

  def dimensions_fact(product)
    dimensions = [product.height, product.width, product.depth].compact
    return if dimensions.empty?

    [t('.dimensions'), dimensions.map { |dimension| format_piece_number(dimension) }.join(' x ')]
  end

  def text_fact(product, attribute)
    value = product.public_send(attribute)
    return if value.blank?

    [Spree::Product.human_attribute_name(attribute), value]
  end

  def claim_fact(product, attribute)
    return unless product.public_send(attribute)

    [Spree::Product.human_attribute_name(attribute), t('spree.say_yes')]
  end

  def format_piece_number(number)
    number_with_precision(number, strip_insignificant_zeros: true)
  end
end
