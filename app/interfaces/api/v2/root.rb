module API
  module V2
    class Root < API::Helpers::GrapeApiHelper
      version 'v2', using: :accept_version_header, cascade: false
      format :json
      content_type :json, 'application/json'

      group do
        before_validation do
          authenticate_user_is?('CaseWorker')
        end

        namespace :api, desc: 'Retrieval, creation and validation operations' do
          mount API::V2::CaseWorker
          mount API::V2::CaseWorkers::Claim
          mount API::V2::CaseWorkers::Allocate
          mount API::V2::Claim
          mount API::V2::Search
          mount API::V2::MI::AGFSSchemeTenClaims

          namespace :ccr, desc: 'CCR injection specific claim format' do
            mount API::V2::CCRClaim
          end

          namespace :cclf, desc: 'CCLF injection specific claim format' do
            mount API::V2::CCLFClaim
          end
        end
      end

      add_swagger_documentation(
        info: { title: 'Claim for crown court defence API - v2' },
        api_version: 'v2',
        doc_version: 'v2',
        hide_documentation_path: true,
        mount_path: '/api/v2/swagger_doc',
        hide_format: true
      )
    end
  end
end
