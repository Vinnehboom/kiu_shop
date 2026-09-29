module ProductPieceDetails
  def self.prepended(base)
    base.attribute :details, Piece::DetailsType.new
    base.delegate :clay, :glaze, to: :details
  end

  def clay=(value)
    self.details = details.with(clay: value)
  end

  def glaze=(value)
    self.details = details.with(glaze: value)
  end

  Spree::Product.prepend self
end
