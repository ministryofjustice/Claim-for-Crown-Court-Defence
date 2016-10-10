module API
  module V1
    class DropdownData < API::Helpers::GrapeApiHelper
      params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
      end

      helpers do
        params :role_filter do
          optional :role, type: String, desc: 'OPTIONAL: The role to filter the results. If not provided, all results are returned.', values: %w(agfs lgfs)
        end

        def role
          params.role.try(:downcase).try(:to_sym) || :all
        end
      end

      after do
        header 'Cache-Control', 'max-age=3600'
      end

      group do
        resource :case_types do
          desc "Return all Case Types"
          params do
            use :role_filter
          end
          get do
            present CaseType.__send__(role), with: API::Entities::CaseType
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
          desc "Return all Offence Class Types, with the matching offence_id for LGFS claims."
          get do
            present OffenceClass.all, with: API::Entities::OffenceClass
          end
        end

        resource :offences do
          desc "Return all Offence-ids to be used in advocate claims (see OffenceClasses for Litigator claims)."
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

        resource :fee_types do
          helpers do
            def category
              params.category.try(:downcase)
            end
          end

          params do
            use :role_filter
            optional :category, type: String, values: %w(all basic misc fixed graduated interim transfer warrant), default: 'all',
                     desc: "[optional] category - #{%w(all basic misc fixed graduated interim transfer warrant).to_sentence}. Default: all"
          end

          desc "Return all AGFS Fee Types (optional category filter)."
          get do
            fee_types = if category.blank? || category == 'all'
                          Fee::BaseFeeType.__send__(role)
                        else
                          Fee::BaseFeeType.__send__(category).__send__(role)
                        end

            present fee_types, with: API::Entities::BaseFeeType
          end
        end

        resource :expense_types do
          desc "Return all Expense Types."
          params do
            use :role_filter
          end
          get do
            present ExpenseType.__send__(role), with: API::Entities::ExpenseType
          end
        end

        resource :expense_reasons do
          desc "Return all Expense Reasons by reason set."
          get do
            present ExpenseType.reason_sets, with: API::Entities::ExpenseReasonSet
          end
        end

        resource :disbursement_types do
          desc "Return all Disbursement Types."
          get do
            present DisbursementType.active, with: API::Entities::DisbursementType
          end
        end

        resource :transfer_stages do
          desc "Return all Transfer Stages"
          get do
            present ::Claim::TransferBrain::TRANSFER_STAGES.to_a, with: API::Entities::SimpleKeyValueList
          end
        end

        resource :transfer_case_conclusions do
          desc "Return all Transfer Case Conclusions"
          get do
            present ::Claim::TransferBrain::CASE_CONCLUSIONS.to_a, with: API::Entities::SimpleKeyValueList
          end
        end
      end

    end
  end
end
