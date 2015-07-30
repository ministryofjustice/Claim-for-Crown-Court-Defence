module API
  module V1

    class Error < StandardError; end
    class ArgumentError < Error; end

    module Advocates

        # -----------------------
        class Seed < Grape::API

          version 'v1', using: :header, vendor: 'Advocate Defence Payments'
          format :json
          prefix 'api/seeds'
          content_type :json, 'application/json'

          resource :fee_types do

            helpers do
              params :category_filter do
                optional :category, type: String, values: ['all','basic','misc','fixed'], desc: "[optional] category - basic, misc, fixed", default: 'all'
              end

              def args
                { category: params[:category] }
              end
            end

            desc "Return all Fee Types (optional category filter)."

            params do
              use :category_filter
            end

            get do
              if args[:category].blank? || args[:category].downcase == 'all'
                ::FeeType.all
              else
                ::FeeType.__send__(args[:category].downcase)
              end
            end

          end

          resource :offence_classes do
            desc "Return all Offence Class Types."
            get do
              ::OffenceClass.all
            end
          end

          resource :offences do
            desc "Return all Offence Types."
            get do
              ::Offence.all
            end
          end

        end
        # -----------------------

    end
  end
end
