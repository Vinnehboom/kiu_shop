Piece::SafetyClaims = Data.define(:food_safe, :dishwasher_safe) do
  def claimed
    to_h.select { |_claim, value| value }.keys
  end

  def empty?
    claimed.none?
  end
end
