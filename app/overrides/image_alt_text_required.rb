module ImageAltTextRequired
  def self.prepended(base)
    base.validates :alt, presence: true
  end

  Spree::Image.prepend self
end
