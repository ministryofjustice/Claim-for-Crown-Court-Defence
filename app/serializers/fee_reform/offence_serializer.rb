module FeeReform
  class OffenceSerializer < ActiveModel::Serializer
    attributes :id, :description, :contrary
    has_one :offence_band, key: :band
    has_one :offence_category, key: :category
  end
end
