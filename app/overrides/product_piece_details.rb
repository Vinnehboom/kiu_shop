module ProductPieceDetails
  def self.prepended(base)
    base.attribute :details, Piece::DetailsType.new
    base.delegate :clay, :glaze, to: :details
    base.delegate :measurements, to: :master
    base.composed_of :safety_claims,
                     class_name: 'Piece::SafetyClaims',
                     mapping: [%w[food_safe food_safe], %w[dishwasher_safe dishwasher_safe]]
  end

  %i[food_safe dishwasher_safe].each do |claim|
    define_method(:"#{claim}=") do |value|
      super(value)
      @aggregation_cache.delete('safety_claims')
    end
  end

  def clay=(value)
    self.details = details.with(clay: value)
  end

  def glaze=(value)
    self.details = details.with(glaze: value)
  end

  Spree::Product.prepend self
end
