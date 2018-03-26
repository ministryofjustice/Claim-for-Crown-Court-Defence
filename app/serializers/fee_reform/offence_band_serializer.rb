module FeeReform
  class OffenceBandSerializer < ActiveModel::Serializer
    attributes :id, :number, :description
  end
end
