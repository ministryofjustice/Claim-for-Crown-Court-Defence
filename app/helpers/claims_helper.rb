module ClaimsHelper

	def includes_state?(claims, states)
		states.gsub(/\s+/,'').split(',').to_a unless states.is_a?(Array)
		claims.map(&:state).uniq.any? { |s| states.include?(s) }
	end

  def number_with_precision_or_blank(number, options = {})
    if options.has_key?(:precision)
      number == 0 ? '' : number_with_precision(number, options)
    else
      number == 0 ? '' : number.to_s
    end
  end

  def claim_allocation_checkbox_helper(claim, case_worker)
    checked = claim.is_allocated_to_case_worker?(case_worker) ? %q(checked="checked") : nil
    %Q(<input #{checked} id="case_worker_claim_ids_#{claim.id}" name="case_worker[claim_ids][]" type="checkbox" value="#{claim.id}">).html_safe
  end

  def caseworker_claim_id_helper(claim)
    "claim_ids_#{claim.id}"
  end

end
