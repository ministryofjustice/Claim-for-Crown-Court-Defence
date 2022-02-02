class OffenceSerializer < ActiveModel::Serializer
  attributes :id, :description, :contrary
  has_one :offence_band, serializer: FeeReform::OffenceBandSerializer, key: :band
  has_one :offence_category, serializer: FeeReform::OffenceCategorySerializer, key: :category
  has_one :offence_class, serializer: OffenceClassSerializer
end
