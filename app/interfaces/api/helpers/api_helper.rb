module API
  module Helpers
    module ApiHelper
      require Rails.root.join('app', 'interfaces', 'api', 'custom_validations', 'date_format.rb')
      require_relative '../api_response'
      require_relative '../error_response'

      class << self
        def response_params(uuid, params)
          params.merge(id: uuid)
        end

        def create_resource(model_klass, params, api_response, arg_builder_proc)
          model_instance = validate_resource(model_klass, api_response, arg_builder_proc)

          if api_response.success?(200)
            created_or_updated_status = model_instance.new_record? ? 201 : 200
            model_instance.save!
            api_response.status = created_or_updated_status
            api_response.body = response_params(model_instance.reload.uuid, params)
          end

          model_instance

        # unexpected errors could be raised at point of save as well
        rescue StandardError => ex
          pop_error_response(ex, api_response)
        end

        # --------------------
        def validate_resource(model_klass, api_response, arg_builder_proc)
          #
          # basic fees (which are instantiated at claim creation)
          # must be updated if they already exist.
          # all other model class instances must be created.
          #
          args = arg_builder_proc.call
          model_klass = get_fee_subclass(args) if model_klass == ::Fee::BaseFee

          if basic_fee_update_required(model_klass, args)
            model_instance = find_basic_fee(args[:claim_id], args[:fee_type_id])
            model_instance.assign_attributes(args)
          else
            model_instance = model_klass.new(args)
          end

          test_editability(model_instance)
          if model_instance.errors.present?
            pop_error_response(model_instance, api_response)
          elsif model_instance.valid?
            api_response.status = 200
            api_response.body = { valid: true }
          else
            pop_error_response(model_instance, api_response)
          end

          model_instance
        rescue StandardError => ex
          pop_error_response(ex, api_response)
        end

        private

        def find_basic_fee(claim_id, fee_type_id)
          basic_fee = ::Claim::BaseClaim.find(claim_id)
                                        .basic_fees
                                        .detect { |bf| bf.fee_type_id == fee_type_id }
          raise "basic fee of type with id #{fee_type_id} not found on claim" if basic_fee.nil?
          basic_fee
        end

        def get_fee_subclass(args)
          id_or_code = args.delete(:fee_type_id) || args.delete(:fee_type_unique_code)
          err_msg = 'Type of fee not found by ID or Unique Code'
          fee_type = ::Fee::BaseFeeType.find_by_id_or_unique_code(id_or_code) || (raise err_msg)
          args[:fee_type_id] = fee_type.id
          fee_type.type.sub(/Type$/, '').constantize
        end

        # prevent creation/basic-fee-update of sub(sub)models for claims not in a draft state
        def test_editability(model_instance)
          return unless fee_classes.include?(model_instance.class)
          model_instance.errors.add(:base, 'uneditable_state') unless model_instance.claim.editable?
        rescue StandardError
          true
        end

        def fee_classes
          (Fee::BaseFee.subclasses + [Expense, Disbursement, Defendant, RepresentationOrder, DateAttended])
        end

        def pop_error_response(error_or_model_instance, api_response)
          err_resp = API::ErrorResponse.new(error_or_model_instance)
          api_response.status = err_resp.status
          api_response.body   = err_resp.body
        end

        def basic_fee_update_required(model_klass, args)
          is_a_fee?(model_klass) && is_a_basic_fee_type?(args)
        end

        def is_a_fee?(model_klass)
          Fee::BaseFee.subclasses.include?(model_klass)
        end

        def is_a_basic_fee_type?(args)
          Fee::BaseFeeType.find(args[:fee_type_id]).is_a?(::Fee::BasicFeeType)
        end
      end
    end
  end
end
