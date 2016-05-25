class Claim::BaseClaimPresenter < BasePresenter

  presents :claim

  # returns a hash of state as a symbol, and state as a human readable name suitable for use in drop down
  #
  def valid_transitions(options = {include_submitted: true} )
    states = claim.state_transitions.map(&:to_name) - [:archived_pending_delete, :deallocated]
    if options[:include_submitted] == false
      states = states - [:submitted]
    end
    states.map { |state| [ state, state.to_s.humanize ] }.to_h
  end

  def valid_transitions_for_detail_form
    if claim.state == "allocated"
      valid_transitions(include_submitted: false)
    else
      nil
    end
  end

  def case_type_name
    if claim.opened_for_redetermination?
      claim.case_type.name + ' (redetermination)'
    elsif claim.written_reasons_outstanding?
      claim.case_type.name + ' (awaiting written reasons)'
    else
      claim.case_type.name
    end
  end

  def defendant_names
    defendant_names = claim.defendants.order('id ASC').map(&:name)

    h.capture do
      defendant_names.each do |name|
        h.concat(name)
        unless name == defendant_names.last
          h.concat(',')
          h.concat(h.tag :br)
        end
      end
    end
  end

  def submitted_at(options={})
    claim.last_submitted_at.strftime(date_format(options)) unless claim.last_submitted_at.nil?
  end

  def authorised_at (options={})
    claim.authorised_at.strftime(date_format(options)) unless claim.authorised_at.nil?
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

  def case_concluded_at
    format_date(claim.case_concluded_at)
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

  def amount_assessed
    if claim.assessment.present?
      h.number_to_currency(claim.amount_assessed)
    else
      '-'
    end
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

  def disbursements_total
    h.number_to_currency(claim.disbursements_total)
  end

  def status_image
    "#{claim.state.gsub('_','-')}.png"
  end

  def status_image_tag (options={})
    options.merge(alt: claim.state.humanize, title: claim.state.humanize) { |k,v1,v2| v1 }
    h.image_tag status_image, options
  end

  def case_worker_names
    claim.case_workers.map(&:name).sort.join(', ')
  end

  def case_worker_email_addresses
    claim.case_workers.map(&:email).sort.join(', ')
  end

  def caseworker_claim_id
    "claim_ids_#{claim.id}"
  end

  def representation_order_details
    rep_order_details = claim.defendants.map(&:representation_order_details).flatten

    h.capture do
      rep_order_details.each do |details|
        h.concat(details)
        h.concat(h.tag :br) unless details == rep_order_details.last
      end
    end
  end

  def external_user_description
    case claim
      when Claim::AdvocateClaim
        'advocate'
      else
        'litigator'
    end
  end

  def scheme
    case claim
      when Claim::AdvocateClaim
        'AGFS'
      else
        'LGFS'
    end
  end

  # Override in subclasses if necessary
  def can_have_expenses?; true; end
  def can_have_disbursements?; true; end

  def assessment_date
    claim.assessment.blank? ? '(not yet assessed)' : claim.assessment.created_at.strftime(Settings.date_format)
  end

  def assessment_fees
    assessment_value(:fees)
  end

  def assessment_expenses
    assessment_value(:expenses)
  end

  def assessment_disbursements
    assessment_value(:disbursements)
  end

  def assessment_total
    assessment_value(:total)
  end

  def assessment_value(assessment_attr)
    claim.assessment.new_record? ? h.number_to_currency(0) : h.number_to_currency(claim.assessment.__send__(assessment_attr))
  end
end
