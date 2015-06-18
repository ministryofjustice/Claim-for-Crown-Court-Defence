class ClaimPresenter < BasePresenter

  presents :claim

  def defendant_names
    claim.defendants.map(&:name).join(', ')
  end

  def submitted_at(options={})
    format = options[:include_time] ? '%d/%m/%Y %H:%M' : '%d/%m/%Y'
    claim.submitted_at.strftime(format) unless claim.submitted_at.nil?
  end

  def paid_at (options={})
    format = options[:include_time] ? '%d/%m/%Y %H:%M' : '%d/%m/%Y'
    claim.paid_at.strftime(format) unless claim.paid_at.nil?
  end

  def total
    number_to_currency(claim.total)
  end

  def amount_assessed
    number_to_currency(claim.amount_assessed)
  end

  def fees_total
    number_to_currency(claim.fees_total)
  end

  def expenses_total
    number_to_currency(claim.expenses_total)
  end

  def status_image (html_options={})
    # class_option = html_options.key?(:class) ? html_options[:class] : 'status-indicator'
    image_tag "#{claim.state.gsub('_','-')}.png", { alt: claim.state.humanize, title: claim.state.humanize }, html_options
  end

  def case_worker_names
    claim.case_workers.map(&:name).join(', ')
  end

  def representation_order_dates
    claim.defendants.map { |d| d.representation_order_date.strftime('%d/%m/%Y') if d.representation_order_date }.join(', ')
  end

  def maat_references
    claim.defendants.map(&:maat_reference).join(', ')
  end

  def case_worker_email_addresses
    claim.case_workers.map(&:email).join(', ')
  end

end