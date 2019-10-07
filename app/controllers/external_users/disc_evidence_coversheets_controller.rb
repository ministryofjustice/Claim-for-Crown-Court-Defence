class ExternalUsers::DiscEvidenceCoversheetsController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource

  def new
    @disc_evidence_coversheet = DiscEvidenceCoversheet.new(claim_id: params[:claim_id])
    authorize_coversheet!
  end

  def create
    @disc_evidence_coversheet = DiscEvidenceCoversheet.new(disc_evidence_coversheet_params)
    authorize_coversheet!

    respond_to do |format|
      format.html do
        render 'pdfs/templates/disc_evidence_coversheet.html.erb'
      end

      format.pdf do
        render(
          pdf: "disc_evidence_coversheet_#{@disc_evidence_coversheet.case_number}",
          title: 'Disc evidence coversheet',
          margin: { top: 10, bottom: 10, left: 10, right: 10 },
          template: 'pdfs/templates/disc_evidence_coversheet.html.erb',
          disposition: 'inline'
        )
      end
    end
  end

  private

  def disc_evidence_coversheet_params
    params.require(:disc_evidence_coversheet).permit(
      :claim_id,
      date_attributes_for(:current_date),
      :fee_scheme,
      :case_number,
      :court_name,
      date_attributes_for(:claim_submitted_at),
      :defendant_name,
      :maat_reference,
      :provider_account_no,
      :provider_address,
      :data_storage_type
    ).merge(
      claim_id: params[:claim_id]
    )
  end

  def authorize_coversheet!
    authorize! params[:action].to_sym, @disc_evidence_coversheet
  end
end
