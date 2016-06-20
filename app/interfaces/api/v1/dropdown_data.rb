module API
  module V1
    class DropdownData < GrapeApiHelper

      version 'v1', using: :header, vendor: 'Advocate Defence Payments'
      format :json
      prefix 'api'
      content_type :json, 'application/json'

      params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
      end

      group do
        resource :case_types do
          desc "Return all Case Types"
          get do
            present CaseType.agfs, with: API::Entities::CaseType
          end
        end

        resource :courts do
          desc "Return all Courts"
          get do
            present Court.all, with: API::Entities::Court
          end
        end

        resource :advocate_categories do
          desc "Return all Advocate Categories"
          get do
            Settings.advocate_categories
          end
        end

        resource :trial_cracked_at_thirds do
          desc "Return all Trial Cracked at Third values (i.e. first, second, final)"
          get do
            Settings.trial_cracked_at_third
          end
        end

        resource :offence_classes do
          desc "Return all Offence Class Types."
          get do
            present OffenceClass.all, with: API::Entities::OffenceClass
          end
        end

        resource :offences do
          desc "Return all Offence Types."
          params do
            optional :offence_description, type: String, desc: "Offences matching description"
          end
          get do
            offences = if params[:offence_description].present?
                         Offence.where(description: params[:offence_description])
                       else
                         Offence.all
                       end

            present offences, with: API::Entities::Offence
          end
        end

        # TODO: allow 'graduated, interim and transfer' categories once we open the API to litigator claims
        resource :fee_types do
          helpers do
            def category
              params.category.try(:downcase)
            end
          end

          params do
            optional :category, type: String, values: %w(all basic misc fixed ), default: 'all',
                     desc: "[optional] category - #{%w(all basic misc fixed).to_sentence}. Default: all"
          end

          desc "Return all AGFS Fee Types (optional category filter)."
          get do
            fee_types = if category.blank? || category == 'all'
                          Fee::BaseFeeType.agfs
                        else
                          Fee::BaseFeeType.__send__(category).agfs
                        end

            present fee_types, with: API::Entities::BaseFeeType
          end
        end

        resource :expense_types do
          desc "Return all Expense Types."
          get do
            present ExpenseType.agfs, with: API::Entities::ExpenseType
          end
        end

        resource :disbursement_types do
          desc "Return all Disbursement Types."
          get do
            present DisbursementType.all, with: API::Entities::DisbursementType
          end
        end
      end

    end
  end
end
