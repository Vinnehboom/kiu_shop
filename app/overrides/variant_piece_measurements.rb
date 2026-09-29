module VariantPieceMeasurements
  def self.prepended(base)
    base.composed_of :measurements,
                     class_name: 'Piece::Measurements',
                     mapping: [%w[weight weight], %w[height height], %w[width width], %w[depth depth]]
  end

  %i[weight height width depth].each do |attribute|
    define_method(:"#{attribute}=") do |value|
      super(value)
      @aggregation_cache.delete('measurements')
    end
  end

  Spree::Variant.prepend self
end
