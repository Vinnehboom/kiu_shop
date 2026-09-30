Piece::Details = Data.define(:clay, :glaze) do
  def self.empty
    new
  end

  def initialize(clay: nil, glaze: nil)
    super
  end

  def empty?
    to_h.values.all?(&:blank?)
  end

  def as_json(*)
    to_h.as_json
  end
end
