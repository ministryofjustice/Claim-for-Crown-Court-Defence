module API
  module V1
    # -----------------------
    class DropdownData < GrapeApiHelper
      version 'v1', using: :header, vendor: 'Advocate Defence Payments'
      format :json
      prefix 'api'
      content_type :json, 'application/json'

      helpers do
        params :api_key_params do
          optional :api_key, type: String, desc: "REQUIRED: The API authentication key of the provider"
        end

        def authenticate!(params)
          ApiHelper.authenticate_key!(params)
        rescue API::V1::ArgumentError
          error!('Unauthorised', 401)
        end
      end

      before do
        authenticate!(params)
      end

      resource :case_types do
        desc "Return all Case Types"
        params { use :api_key_params }
        get do
          CaseType.agfs
        end
      end

      resource :courts do
        desc "Return all Courts"
        params { use :api_key_params }
        get do
          Court.all
        end
      end

      resource :advocate_categories do
        desc "Return all Advocate Categories"
        params { use :api_key_params }
        get do
          Settings.advocate_categories
        end
      end

      resource :trial_cracked_at_thirds do
        desc "Return all Trial Cracked at Third values (i.e. first, second, final)"
        params { use :api_key_params }
        get do
          Settings.trial_cracked_at_third
        end
      end

      resource :offence_classes do
        desc "Return all Offence Class Types."
        params { use :api_key_params }
        get do
          ::OffenceClass.all
        end
      end

      resource :offences do
        desc "Return all Offence Types."

        params do
          use :api_key_params
          optional :offence_description, type:  String, desc: "Offences matching description"
        end

        get do
          if params[:offence_description].present?
            ::Offence.where(description: params[:offence_description])
          else
            ::Offence.all
          end
        end
      end

      resource :fee_types do
        helpers do
          params :category_filter do
            use :api_key_params
            optional :category, type: String, values: ['all','basic','misc','fixed'], desc: "[optional] category - basic, misc, fixed", default: 'all'
          end

          def args
            { category: params[:category] }
          end
        end

        desc "Return all AGFS Fee Types (optional category filter)."
        params { use :category_filter }
        get do
          if args[:category].blank? || args[:category].downcase == 'all'
            ::Fee::BaseFeeType.agfs
          else
            ::Fee::BaseFeeType.__send__(args[:category].downcase).agfs
          end
        end
      end

      resource :expense_types do
        desc "Return all Expense Types."
        params { use :api_key_params }
        get do
          ::ExpenseType.agfs.all_with_reasons
        end
      end
    end
  end
end
