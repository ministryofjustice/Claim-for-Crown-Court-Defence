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

  def claim_allocation_checkbox_helper(claim, case_worker)
    checked = claim.is_allocated_to_case_worker?(case_worker) ? 'checked="checked"' : nil
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

  def miscellaneous_fees_notice(claim)
    'page_notice' if (claim.final? || claim.transfer?) && claim.post_clar? &&
                     ['Trial', 'Cracked Trial'].include?(claim.case_type.name)
  end
end
