class PieceDetailRowComponent < ViewComponent::Base
  def initialize(label:, value:)
    super()
    @label = label
    @value = value
  end

  def render?
    value.present?
  end

  private

  attr_reader :label, :value
end
