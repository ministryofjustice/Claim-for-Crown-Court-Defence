class GeckoboardApi::WidgetsController < GeckoboardApi::ApplicationController
  include DisableViewOnlyActions

  # TODO: needed? not linked in statistic/index
  def claims
    respond_payload_from_class(Stats::ClaimPercentageAuthorisedGenerator)
  end

  # TODO: needed? not linked in statistic/index
  def claim_completion
    respond_payload_from_reporter_class(Stats::ClaimCompletionReporterGenerator)
  end

  def claim_creation_source
    respond_payload_from_class(Stats::ClaimCreationSourceDataGenerator)
  end

  def claim_submissions
    respond_payload_from_class(Stats::ClaimSubmissionsDataGenerator)
  end

  def multi_session_submissions
    respond_payload_from_class(Stats::MultiSessionSubmissionDataGenerator)
  end

  def requests_for_further_info
    respond_payload_from_class(Stats::RequestForFurtherInfoDataGenerator)
  end

  def time_reject_to_auth
    respond_payload_from_class(Stats::TimeFromRejectToAuthDataGenerator)
  end

  def completion_rate
    respond_payload_from_class(Stats::CompletionRateDataGenerator)
  end

  def time_to_completion
    respond_payload_from_class(Stats::TimeToCompletionDataGenerator)
  end

  def redeterminations_average
    respond_payload_from_class(Stats::ClaimRedeterminationsDataGenerator)
  end

  # TODO: needed? not linked in statistic/index
  def money_to_date
    respond_payload_from_class(Stats::MoneyToDateDataGenerator)
  end

  def money_claimed_per_month
    respond_payload_from_class(Stats::MoneyClaimedPerMonthDataGenerator)
  end

  private

  def respond_payload_from_class(klass)
    respond_to do |format|
      @payload = klass.new.run
      format.json do
        render json: @payload.to_json
      end
      format.html
    end
  end

  def respond_payload_from_reporter_class(klass)
    reporter = ClaimReporter.new
    payload = klass.new(reporter)

    respond_to do |format|
      format.json { render json: payload }
    end
  end
end
