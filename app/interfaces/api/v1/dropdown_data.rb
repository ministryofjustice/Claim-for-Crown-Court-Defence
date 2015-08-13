module API
  module V1

    class Error < StandardError; end
    class ArgumentError < Error; end

    # -----------------------
    class DropdownData < Grape::API

      version 'v1', using: :header, vendor: 'Advocate Defence Payments'
      format :json
      prefix 'api'
      content_type :json, 'application/json'

      resource :case_types do
        desc "Return all Case Types"
        get do
          Settings.case_types
        end
      end

      resource :courts do
        desc "Return all Courts"
        get do
          Court.all
        end
      end

      resource :advocate_categories do
        desc "Return all Advocate Categories"
        get do
          Settings.advocate_categories
        end
      end

      resource :prosecuting_authorities do
        desc "Return all Prosecuting Auhtorities"
        get do
          Settings.prosecuting_authorities
        end
      end

      resource :trial_cracked_at_thirds do
        desc "Return all Trial Cracked at Third values (i.e. first, second, final)"
        get do
          Settings.trial_cracked_at_third
        end
      end

      resource :granting_body_types do
        desc "Return all granting body types (as used to specify which court issued a defendants Rep. Order)"
        get do
          Settings.court_types
        end
      end

      resource :offence_classes do
        desc "Return all Offence Class Types."
        get do
          ::OffenceClass.all
        end
      end

      params do
        optional :offence_description, type:  String, desc: "Offences matching description"
      end

      resource :offences do
        desc "Return all Offence Types."
        get do
          if params[:offence_description].present?
            ::Offence.where(description: params[:offence_description])
          else
            ::Offence.all
          end
        end
      end

      resource :fee_categories do
        desc "Return all Fee Categories"
        get do
          FeeCategory.all
        end
      end

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

      resource :expense_types do
        desc "Return all Expense Types."
        get do
          ::ExpenseType.all
        end
      end

    end
    # -----------------------

end

end
