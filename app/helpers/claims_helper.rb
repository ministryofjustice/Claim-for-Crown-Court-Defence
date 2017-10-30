module ClaimsHelper
  EXTERNAL_USER_MESSAGING_ALLOWED = %w[
    submitted
    allocated
    part_authorised
    rejected refused
    authorised
    redetermination
    awaiting_written_reasons
  ].freeze

  def includes_state?(claims, states)
    states.gsub(/\s+/, '').split(',').to_a unless states.is_a?(Array)
    claims.map(&:state).uniq.any? { |s| states.include?(s) }
  end

  def claim_allocation_checkbox_helper(claim, case_worker)
    checked = claim.is_allocated_to_case_worker?(case_worker) ? 'checked="checked"' : nil
    %(<input #{checked} id="case_worker_claim_ids_#{claim.id}" name="case_worker[claim_ids][]" type="checkbox" value="#{claim.id}">).html_safe
  end

  def to_slug(string)
    string.downcase.gsub(/ +/, '-').gsub(/[^a-zA-Z0-9-]/, '')
  end

  def show_api_promo_to_user?
    Settings.api_promo_enabled? && current_user.setting?(:api_promo_seen).nil?
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
    (current_user_is_external_user? && !message.claim.redeterminable?) || message.claim_action.present?
  end
end
