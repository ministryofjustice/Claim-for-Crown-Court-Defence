class ClaimPresenter < BasePresenter
  presents :claim

  def defendant_names
    claim.defendants.order('id ASC').map(&:name).join(',<br>').html_safe
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

  def retrial
    claim.case_type.name.match(/retrial/i) ? 'Yes' : 'No' rescue ''
  end

  def any_judicial_apportionments
    claim.defendants.map(&:order_for_judicial_apportionment).include?(true) ? 'Yes' : 'No'
  end

  def trial_concluded
    claim.trial_concluded_at.blank? ? 'not specified' : claim.trial_concluded_at.strftime(Settings.date_format)
  end

  def vat_date(format = nil)
    if format == :db
      claim.vat_date.to_s(:db)
    else
      claim.vat_date.strftime(Settings.date_format)
    end
  end

  def vat_amount
    h.number_to_currency(claim.vat_amount)
  end

  def total
    h.number_to_currency(claim.total)
  end

  def total_inc_vat
    h.number_to_currency(claim.total + claim.vat_amount)
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
    claim.defendants.map(&:representation_order_details).flatten.join('<br/>').html_safe
  end

  def assessment_date
    claim.assessment.blank? ? '(not yet assessed)' : claim.assessment.created_at.strftime(Settings.date_format)
  end

  def assessment_fees
    assessment_value(:fees)
  end

  def assessment_expenses
    assessment_value(:expenses)
  end

  def assessment_total
    assessment_value(:total)
  end

  def assessment_value(assessment_attr)
    claim.assessment.new_record? ? h.number_to_currency(0) : h.number_to_currency(claim.assessment.__send__(assessment_attr))
  end
end
