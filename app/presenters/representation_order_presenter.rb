class RepresentationOrderPresenter < BasePresenter

  presents :ro

  def summary
    "#{ro.document_file_name}&nbsp;&nbsp;&nbsp;MAAT: #{ro.maat_reference} (#{ro.granting_body})&nbsp;&nbsp;&nbsp; #{ro.representation_order_date.strftime('%d/%m/%Y')}".html_safe
  end

end