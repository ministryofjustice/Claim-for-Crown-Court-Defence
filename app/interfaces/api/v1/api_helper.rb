module API
  module V1
    module ApiHelper

      require Rails.root.join('app', 'interfaces', 'api','custom_validations','date_format.rb')
      require_relative 'api_response'
      require_relative 'error_response'

      class Hash < ::Hash
        def merge_date_fields!(date_fields, params)
          date_fields.each do |field|
            self.merge!(ApiHelper.to_dd_mm_yyyy_args(field, params))
          end
        end
      end

      class << self

        def authenticate_key!(params)
          provider = Provider.find_by(api_key: params[:api_key])
          if provider.blank? || provider.api_key.blank?
            raise API::V1::ArgumentError, 'Unauthorised'
          end
          provider
        end

        def authenticate_claim!(params)
          provider = authenticate_key!(params)
          creator  = find_advocate_by_email(email: params[:creator_email], relation: 'Creator' )
          advocate = find_advocate_by_email(email: params[:advocate_email], relation: 'Advocate')

          if creator.provider != provider || advocate.provider != provider
            raise API::V1::ArgumentError, 'Creator and advocate must belong to the provider'
          end

          return { provider: provider, creator: creator, advocate: advocate }
        end

        def find_advocate_by_email(options = {})
          user = User.external_users.find_by(email: options[:email])
          if user.blank?
            raise API::V1::ArgumentError, "#{options[:relation]} email is invalid"
          else
            @advocate = user.persona
          end
        end

        def response_params(uuid, params)
          {'id' => uuid }.merge!(params.except(:api_key, :creator_email, :advocate_email))
        end

        def extract_date(unit, param)
          if param.present?
            case unit
            when :day
              param.slice(8..9)
            when :month
              param.slice(5..6)
            when :year
              param.slice(0..3)
            end
          end
        end

        # use to convert any date to expected format in params
        def to_dd_mm_yyyy_args(date_field, params)
          args = {}
         { day: 'dd', month: 'mm', year: 'yyyy'}.each do |k,v|
            args["#{date_field.to_s}_#{v}".to_sym] = extract_date(k,params[date_field])
          end
          args
        end

        # --------------------
        def create_resource(model_klass, params, api_response, arg_builder_proc)
          model_instance = validate_resource(model_klass, params, api_response, arg_builder_proc)

          if api_response.success?(200)
            created_or_updated_status = model_instance.new_record? ? 201 : 200
            model_instance.save!
            api_response.status = created_or_updated_status
            api_response.body = response_params(model_instance.reload.uuid, params)
          end

          model_instance

        # unexpected errors could be raised at point of save as well
        rescue Exception => ex
          pop_error_response(ex, api_response)
        end

        # --------------------
        def validate_resource(model_klass, params, api_response, arg_builder_proc)

          authenticate_key!(params)

          #
          # basic fees (which are instantiated at claim creation)
          # must be updated if they already exist, otherwise created.
          # all other model class instances must be created.
          #
          args = arg_builder_proc.call
          model_klass = get_fee_subclass(args) if model_klass == ::Fee::BaseFee

          if basic_fee_update_required(model_klass, args)
            model_instance = model_klass.where(fee_type_id: args[:fee_type_id], claim_id: args[:claim_id]).first
            model_instance.assign_attributes(args)
          else
            model_instance = model_klass.new(args)
          end

          test_editability(model_instance)

          if model_instance.errors.present?
            pop_error_response(model_instance, api_response)
          elsif model_instance.valid?
            api_response.status = 200
            api_response.body =  { valid: true }
          else
            pop_error_response(model_instance, api_response)
          end

          model_instance

        rescue Exception => ex
          pop_error_response(ex, api_response)
        end

        private

        def get_fee_subclass(args)
          raise "Choose a type for the fee" if args[:fee_type_id].nil?
          fee_type = ::Fee::BaseFeeType.find(args[:fee_type_id])
          fee_type.type.sub(/Type$/, '').constantize
        end

        # prevent creation/basic-fee-update of sub(sub)models for claims not in a draft state
        def test_editability(model_instance)
          if [ Fee::BasicFee, Fee::MiscFee, Fee::FixedFee, Expense, Defendant, RepresentationOrder, DateAttended ].include?(model_instance.class)
            model_instance.errors.add(:base, 'uneditable_state') unless model_instance.claim.editable? rescue true
          end
        end

        def pop_error_response(error_or_model_instance, api_response)
          err_resp = ErrorResponse.new(error_or_model_instance)
          api_response.status = err_resp.status
          api_response.body   = err_resp.body
        end

        def basic_fee_update_required(model_klass, args)
          is_a_fee?(model_klass)  && is_a_basic_fee_type?(args)
        end

        def is_a_fee?(model_klass)
          [ ::Fee::BaseFee, ::Fee::BasicFee, ::Fee::MiscFee, ::Fee::FixedFee ].include?(model_klass)
        end

        def is_a_basic_fee_type?(args)
          Fee::BaseFeeType.find(args[:fee_type_id]).is_a?(::Fee::BasicFeeType)
        end


      end
    end
  end
end
