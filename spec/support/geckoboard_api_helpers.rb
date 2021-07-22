# frozen_string_literal: true

module GeckoboardApiHelpers
  extend ActiveSupport::Concern

  class_methods do
    def widgets
      {
        claims: { endpoint: '/geckoboard_api/widgets/claims',
                  generator: Stats::ClaimPercentageAuthorisedGenerator,
                  template: nil },
        claim_completion: { endpoint: '/geckoboard_api/widgets/claim_completion',
                            generator: Stats::ClaimCompletionReporterGenerator,
                            template: :nil },
        claim_creation_source: { endpoint: '/geckoboard_api/widgets/claim_creation_source',
                                 generator: Stats::ClaimCreationSourceDataGenerator,
                                 template: :claim_creation_source },
        claim_submissions: { endpoint: '/geckoboard_api/widgets/claim_submissions',
                             generator: Stats::ClaimSubmissionsDataGenerator,
                             template: :claim_submissions },
        multi_session_submissions: { endpoint: '/geckoboard_api/widgets/multi_session_submissions',
                                     generator: Stats::MultiSessionSubmissionDataGenerator,
                                     template: :multi_session_submissions },
        requests_for_further_info: { endpoint: '/geckoboard_api/widgets/requests_for_further_info',
                                     generator: Stats::RequestForFurtherInfoDataGenerator,
                                     template: :requests_for_further_info },
        time_reject_to_auth: { endpoint: '/geckoboard_api/widgets/time_reject_to_auth',
                               generator: Stats::TimeFromRejectToAuthDataGenerator,
                               template: :time_reject_to_auth },
        completion_rate: { endpoint: '/geckoboard_api/widgets/completion_rate',
                           generator: Stats::CompletionRateDataGenerator,
                           template: :completion_rate },
        time_to_completion: { endpoint: '/geckoboard_api/widgets/time_to_completion',
                              generator: Stats::TimeToCompletionDataGenerator,
                              template: :time_to_completion },
        redeterminations_average: { endpoint: '/geckoboard_api/widgets/redeterminations_average',
                                    generator: Stats::ClaimRedeterminationsDataGenerator,
                                    template: :redeterminations_average },
        money_to_date: { endpoint: '/geckoboard_api/widgets/money_to_date',
                         generator: Stats::MoneyToDateDataGenerator,
                         template: nil },
        money_claimed_per_month: { endpoint: '/geckoboard_api/widgets/money_claimed_per_month',
                                   generator: Stats::MoneyClaimedPerMonthDataGenerator,
                                   template: :money_claimed_per_month }
      }
    end
  end
end
