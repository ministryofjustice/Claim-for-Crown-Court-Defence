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
    return !message.claim.redeterminable? if current_user_is_external_user?
    false
  end

  def fee_shared_headings(claim, scope, fees_calculator_html = nil)
    {
      page_header: t('page_header', scope: scope),
      page_hint: t('page_hint', scope: scope)
    }.tap do |headings|
      if display_unused_materials_notice?(claim)
        headings[:page_notice] = t('unused_materials_fee.notice.short', scope: scope)
      end
      headings[:fees_calculator_html] = fees_calculator_html unless fees_calculator_html.nil?
    end
  end

  def misc_fees_summary_locals(claim, args = {})
    {
      claim: claim, header: t('external_users.claims.misc_fees.summary.header'),
      collection: claim.misc_fees, step: :miscellaneous_fees,
      **args
    }.tap do |locals|
      if display_unused_materials_notice?(claim)
        locals[:unclaimed_fees_notice] = t('external_users.claims.misc_fees.unused_materials_fee.notice.long')
      end
    end
  end

  def display_unused_materials_notice?(claim)
    claim.eligible_misc_fee_types.map(&:unique_code).include?('MIUMU') &&
      claim.fees.select { |f| f.fee_type.unique_code == 'MIUMU' }.empty?
  end
end
