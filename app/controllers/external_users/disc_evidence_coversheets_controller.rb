class ExternalUsers::DiscEvidenceCoversheetsController < ExternalUsers::ApplicationController
  skip_load_and_authorize_resource

  before_action :set_and_authorize_claim, only: %i[new create]

  def new
    @disc_evidence_coversheet = ::DiscEvidenceCoversheet.new(@claim)
  end

  def create
    @disc_evidence_coversheet = DiscEvidenceCoversheet.new(@claim, disc_evidence_coversheet_params)

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

  def set_and_authorize_claim
    @claim = Claim::BaseClaim.active.find(params[:claim_id])
    authorize! params[:action].to_sym, @claim
  end

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
    )
  end
end
