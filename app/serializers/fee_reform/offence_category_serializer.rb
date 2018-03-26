module FeeReform
  class OffenceCategorySerializer < ActiveModel::Serializer
    attributes :id, :number, :description
  end
end
