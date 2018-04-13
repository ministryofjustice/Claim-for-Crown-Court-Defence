GrapeSwaggerRails.options.app_url  = ENV["GRAPE_SWAGGER_ROOT_URL"] || 'http://localhost:3000'
GrapeSwaggerRails.options.app_name = 'Claim for crown court defence API'
GrapeSwaggerRails.options.doc_expansion = 'list'

GrapeSwaggerRails.options.before_action do
  version = request.params.fetch(:v, '1').to_i
  GrapeSwaggerRails.options.url = "/api/v#{version}/swagger_doc"
end
