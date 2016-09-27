GrapeSwaggerRails.options.app_url  = ENV["GRAPE_SWAGGER_ROOT_URL"] || 'http://localhost:3000'
GrapeSwaggerRails.options.app_name = 'Claim for crown court defence API'
GrapeSwaggerRails.options.doc_expansion = 'list'

GrapeSwaggerRails.options.before_filter do
  GrapeSwaggerRails.options.url = request.params.key?(:v2) ? '/api/v2/swagger_doc' : '/api/v1/external_users/swagger_doc'
end
