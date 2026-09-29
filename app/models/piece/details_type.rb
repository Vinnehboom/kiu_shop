module Piece
  class DetailsType < ActiveRecord::Type::Json
    def cast(value)
      Details.new(**value.to_h.symbolize_keys.slice(*Details.members))
    end

    def deserialize(value)
      cast(super)
    end

    def serialize(value)
      super(cast(value).to_h)
    end
  end
end
