module ProductPieceDetails
  def self.prepended(base)
    base.store_accessor :details, :clay, :glaze
  end

  Spree::Product.prepend self
end
