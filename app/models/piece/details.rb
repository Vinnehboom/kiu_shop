Piece::Details = Data.define(:clay, :glaze) do
  def self.empty
    new
  end

  def initialize(clay: nil, glaze: nil)
    super
  end

  def filled
    to_h.compact_blank
  end

  def empty?
    filled.none?
  end

  def as_json(*)
    to_h.as_json
  end
end
