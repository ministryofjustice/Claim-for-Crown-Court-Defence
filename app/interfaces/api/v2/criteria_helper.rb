module API::V2
  module CriteriaHelper
    extend Grape::API::Helpers

    params :pagination do
      optional :page, type: Integer, desc: 'OPTIONAL: Current page.'
      optional :limit, type: Integer, default: 10, desc: 'OPTIONAL: Number of elements per page. Default: 10.'
    end

    params :sorting do
      optional :sorting, type: String, default: 'last_submitted_at', desc: 'OPTIONAL: Sort results by this attribute.'
      optional :direction, type: String, values: %w(asc desc), default: 'asc', desc: 'OPTIONAL: Direction of the sorting: asc or desc.'
    end

    params :searching do
      optional :search, type: String, desc: 'OPTIONAL: Search terms, for example case number, MAAT reference, defendant name, case worker name or email.'
    end
  end
end
