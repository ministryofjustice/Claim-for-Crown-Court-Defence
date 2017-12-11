module API::V2
  module CriteriaHelper
    extend Grape::API::Helpers

    params :pagination do
      optional :page, type: Integer, desc: 'OPTIONAL: Current page.'
      optional :limit, type: Integer, default: 10, desc: 'OPTIONAL: Number of elements per page. Default: 10.'
    end

    params :sorting do
      optional :sorting, type: String, default: 'id', desc: 'OPTIONAL: Sort results by this attribute.'
      optional :direction,
               type: String,
               values: %w[asc desc],
               default: 'asc',
               desc: 'OPTIONAL: Direction of the sorting: asc or desc.'
    end

    params :searching do
      optional :search,
               type: String,
               desc: I18n.t('api.v2.criteria_helper.params.search')
    end

    def sort_attribute
      params.sorting.blank? ? :id : params.sorting
    end

    def sort_direction
      params.direction.blank? ? :asc : params.direction
    end

    def sorting
      { sort_attribute => sort_direction.to_sym }
    end
  end
end
