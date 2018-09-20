# Used to conditionally show or hide
# case conclusion field based on forms
# current transfer details

class CaseConclusionsController < ApplicationController
  skip_load_and_authorize_resource only: [:index]

  def index
    @transfer_stage_label_text = transfer_stage_label_text
    @transfer_date_label_text = transfer_date_label_text
    @transfer_detail = Claim::TransferDetail.new(litigator_type: params[:litigator_type],
                                                 elected_case: elected_case?,
                                                 transfer_stage_id: params[:transfer_stage_id])
  end

  private

  def elected_case?
    # default to true to hide in most cases
    elected_case = %w[true false].include?(params[:elected_case]) ? params[:elected_case] : 'true'
    elected_case
  end

  def transfer_stage_label_text
    replace_start_stop_label('transfer_stage', replace: 'stop/start', with: { start: 'start', stop: 'stop' })
  end

  def transfer_date_label_text
    replace_start_stop_label('transfer_date', replace: 'stopped/started', with: { start: 'started', stop: 'stopped' })
  end

  def replace_start_stop_label(translation, options = { replace: 'stop/start', with: { start: 'start', stop: 'stop' } })
    label_text = I18n.t("external_users.claims.transfer_fee.detail_fields.#{translation}_default_label_text")
    case params[:litigator_type]
    when 'new'
      label_text.gsub!(options[:replace], options[:with][:start])
    when 'original'
      label_text.gsub!(options[:replace], options[:with][:stop])
    end
    label_text
  end
end
