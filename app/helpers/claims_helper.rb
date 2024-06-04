module ClaimsHelper
  EXTERNAL_USER_MESSAGING_ALLOWED = %w[
    submitted
    allocated
    part_authorised
    refused
    authorised
    redetermination
    awaiting_written_reasons
  ].freeze

  SIGNPOST_FEES = %w[MIUMU MIAPF].freeze

  def claim_allocation_checkbox_helper(claim, case_worker)
    checked = claim.allocated_to_case_worker?(case_worker) ? 'checked="checked"' : nil
    element_id = "id=\"case_worker_claim_ids_#{claim.id}\""
    %(<input #{checked} #{element_id} name="case_worker[claim_ids][]" type="checkbox" value="#{claim.id}">).html_safe
  end

  def to_slug(string)
    string.downcase.gsub(/ +/, '-').gsub(/[^a-zA-Z0-9-]/, '')
  end

  def show_api_promo_to_user?
    current_user.setting?(:api_promo_seen).nil?
  end

  def show_claim_list_scheme_filters?(available_schemes)
    Settings.scheme_filters_enabled? && available_schemes.size > 1
  end

  def show_message_controls?(claim)
    return EXTERNAL_USER_MESSAGING_ALLOWED.include?(claim.state) if current_user_is_external_user?
    return claim.state != 'draft' if current_user_is_caseworker?
    false
  end

  def messaging_permitted?(message)
    return true if message.claim_action.present?
    if current_user_is_external_user?
      return Claims::StateMachine::VALID_STATES_FOR_REDETERMINATION.exclude?(message.claim.state)
    end
    false
  end

  def fee_shared_headings(claim, scope, fees_calculator_html = nil)
    {
      page_header: t('page_header', scope:),
      page_hint: t('page_hint', scope:),
      unclaimed_fees: unclaimed_fees_list(claim)
    }.tap do |headings|
      headings[:fees_calculator_html] = fees_calculator_html unless fees_calculator_html.nil?
    end
  end

  def misc_fees_summary_locals(claim, args = {})
    {
      claim:, header: t('external_users.claims.misc_fees.summary.header'),
      collection: claim.misc_fees, step: :miscellaneous_fees,
      unclaimed_fees: unclaimed_fees_list(claim),
      **args
    }
  end

  def unclaimed_fees_list(claim)
    unclaimed_fees = (claim.eligible_misc_fee_types - claim.misc_fees.map(&:fee_type))
                     .select { |ft| SIGNPOST_FEES.include?(ft.unique_code) }
    return if unclaimed_fees.blank?

    unclaimed_fees.map { |fee_type| "'#{fee_type.description}'" }.to_sentence
  end

  def display_elected_not_proceeded_signpost?(claim)
    # This applies to both AGFS fee scheme 13 and LGFS fee scheme 10 but the dates are the same
    claim.final? && Time.zone.today >= Settings.agfs_scheme_13_clair_release_date.beginning_of_day
  end

  def filename_display(attachment)
    "#{attachment.filename} (#{number_to_human_size(attachment.byte_size)})"
  end
end
