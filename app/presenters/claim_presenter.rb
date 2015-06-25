class ClaimPresenter < BasePresenter

  presents :claim

  def defendant_names
    claim.defendants.order('id ASC').map(&:name).join(', ')
  end

  def submitted_at(options={})
    options.assert_valid_keys(:include_time)
    format = options[:include_time] ? Settings.date_time_format : Settings.date_format
    claim.submitted_at.strftime(format) unless claim.submitted_at.nil?
  end

  def paid_at (options={})
    options.assert_valid_keys(:include_time)
    format = options[:include_time] ? Settings.date_time_format : Settings.date_format
    claim.paid_at.strftime(format) unless claim.paid_at.nil?
  end

  def total
    h.number_to_currency(claim.total)
  end

  def amount_assessed
    h.number_to_currency(claim.amount_assessed)
  end

  def fees_total
    h.number_to_currency(claim.fees_total)
  end

  def expenses_total
    h.number_to_currency(claim.expenses_total)
  end

  def status_image
    "#{claim.state.gsub('_','-')}.png"
  end

  def status_image_tag (options={})
    options.merge(alt: claim.state.humanize, title: claim.state.humanize) { |k,v1,v2| v1 }
    h.image_tag status_image, options
  end

  def case_worker_names
    claim.case_workers.map(&:name).join(', ')
  end

  def case_worker_email_addresses
    claim.case_workers.map(&:email).join(', ')
  end

  def caseworker_claim_id
    "claim_ids_#{claim.id}"
  end

  def representation_order_details
    claim.representation_order_details.join('<br/>').html_safe
  end

end
