module API
  module V1
    class DropdownData < API::Helpers::GrapeAPIHelper
      params do
        optional :api_key, type: String, desc: 'REQUIRED: The API authentication key of the provider'
      end

      helpers do
        params :role_filter do
          optional :role, type: String, desc: I18n.t('api.v1.dropdown_data.params.role_filter'), values: %w[agfs lgfs]
        end

        params :scheme_role_filter do
          optional :role,
                   type: String,
                   desc: I18n.t('api.v1.dropdown_data.params.role_filter'),
                   values: %w[
                     agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12
                     agfs_scheme_13 agfs_scheme_14 agfs_scheme_15 agfs_scheme_16
                     lgfs lgfs_scheme_9 lgfs_scheme_10 lgfs_scheme_11
                   ]
        end

        def role
          params[:role]&.pluralize&.downcase&.to_sym || :all
        end

        def scheme_role
          chosen_role = params[:role].eql?('agfs') ? 'agfs_scheme_9' : params[:role]
          chosen_role&.pluralize&.downcase&.to_sym || :all
        end

        def category
          params[:category]&.downcase
        end

        def unique_code
          params[:unique_code]&.upcase
        end
      end

      after do
        header 'Cache-Control', 'max-age=3600'
      end

      group do
        resource :case_types do
          desc 'Return all case types'
          params { use :role_filter }
          get { present CaseType.__send__(role), with: API::Entities::CaseType }
        end

        resource :courts do
          desc 'Return all Courts'
          get { present Court.all, with: API::Entities::Court }
        end

        resource :advocate_categories do
          desc 'Return all advocate categories'
          params { use :scheme_role_filter }
          get do
            case scheme_role
            when :lgfs, :lgfs_scheme_9s, :lgfs_scheme_10s
              []
            when :agfs_scheme_10s, :agfs_scheme_12s, :agfs_scheme_13s, :agfs_scheme_14s, :agfs_scheme_15s
              Settings.agfs_reform_advocate_categories
            else
              Settings.advocate_categories
            end
          end
        end

        resource :trial_cracked_at_thirds do
          desc 'Return all trial cracked at third values (i.e. first, second, final)'
          get { Settings.trial_cracked_at_third }
        end

        resource :offence_classes do
          desc 'Return all offence class types, with the matching offence_id for LGFS claims.'
          get { present OffenceClass.all, with: API::Entities::OffenceClass }
        end

        resource :offences do
          desc 'Return all offence-ids to be used in advocate claims (see OffenceClasses for Litigator claims).'
          params do
            optional :offence_description,
                     type: String,
                     desc: I18n.t('api.v1.dropdown_data.offences.params.description')
            optional :rep_order_date,
                     type: String,
                     default: '2016-04-01',
                     desc: I18n.t('api.v1.dropdown_data.offences.params.rep_order_date'),
                     standard_json_format: true
            optional :main_hearing_date,
                     type: String,
                     desc: I18n.t('api.v1.dropdown_data.offences.params.main_hearing_date'),
                     standard_json_format: true
            optional :unique_code,
                     type: String,
                     desc: I18n.t('api.v1.dropdown_data.offences.params.unique_code')
          end
          get do
            scheme_date = Date.parse(params[:rep_order_date])
            description = params[:offence_description]
            unique_code = params[:unique_code]
            offences = FeeSchemeFactory::AGFS.call(
              representation_order_date: scheme_date,
              main_hearing_date: params[:main_hearing_date]
            ).offences.includes(:fee_schemes, :offence_band, :offence_class)
            offences = offences.where(description:) if description.present?
            offences = offences.where(unique_code:) if unique_code.present?

            present offences, with: API::Entities::Offence
          end
        end

        resource :fee_types do
          params do
            category_types = %w[all basic misc fixed graduated interim transfer warrant]
            use :scheme_role_filter
            optional :category,
                     type: String,
                     default: 'all',
                     values: category_types,
                     desc: "OPTIONAL: The fee category to filter the results. Can be: #{category_types.to_sentence}. Default: all"
            optional :unique_code,
                     type: String,
                     desc: 'OPTIONAL: The unique identifier of the fee type'
          end

          desc 'Return all AGFS fee types (optional category and unique_code filter).'
          get do
            fee_types = Fee::BaseFeeType
            fee_types = fee_types.send(category) unless category.blank? || category.eql?('all')
            fee_types = fee_types.send(role)
            fee_types = fee_types.where(unique_code:) if unique_code.present?
            present fee_types, with: API::Entities::BaseFeeType
          end
        end

        resource :expense_types do
          desc 'Return all expense types.'
          params { use :role_filter }
          get { present ExpenseType.__send__(role), with: API::Entities::ExpenseType }
        end

        resource :expense_reasons do
          desc 'Return all expense reasons by reason set.'
          get { present ExpenseType.reason_sets, with: API::Entities::ExpenseReasonSet }
        end

        resource :disbursement_types do
          desc 'Return all disbursement types.'
          get { present DisbursementType.active, with: API::Entities::DisbursementType }
        end

        resource :transfer_stages do
          desc 'Return all transfer stages'
          get { present ::Claim::TransferBrain::TRANSFER_STAGES.to_a, with: API::Entities::SimpleKeyValueList }
        end

        resource :transfer_case_conclusions do
          desc 'Return all transfer case conclusions'
          get { present ::Claim::TransferBrain::CASE_CONCLUSIONS.to_a, with: API::Entities::SimpleKeyValueList }
        end

        resource :case_stages do
          desc 'Return all case stages'
          params { use :role_filter }
          get { present CaseStage.active.__send__(role), with: API::Entities::CaseStage }
        end
      end
    end
  end
end
