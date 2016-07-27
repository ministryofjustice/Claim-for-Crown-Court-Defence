module ClaimsHelper

	def includes_state?(claims, states)
		states.gsub(/\s+/,'').split(',').to_a unless states.is_a?(Array)
		claims.map(&:state).uniq.any? { |s| states.include?(s) }
	end

  def claim_allocation_checkbox_helper(claim, case_worker)
    checked = claim.is_allocated_to_case_worker?(case_worker) ? %q(checked="checked") : nil
    %Q(<input #{checked} id="case_worker_claim_ids_#{claim.id}" name="case_worker[claim_ids][]" type="checkbox" value="#{claim.id}">).html_safe
  end

  def to_slug(string)
    string.downcase.gsub(/ +/, "-").gsub(/[^a-zA-Z0-9-]/, "")
  end

  def show_api_promo_to_user?
    Settings.api_promo_enabled? && current_user.setting?(:api_promo_seen).nil?
  end
end
