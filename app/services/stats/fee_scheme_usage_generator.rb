require 'csv'

module Stats
  class FeeSchemeUsageGenerator
    # Currently i'm querying the database and looping through all of the claims 5 times
    # per month for 30 times in total for each query run.
    # I could reduce this to 6 times in total by condensing the different information
    # gathering methods into one, but this would be much less readable and make rubocop
    # unhappy in terms of complexity and size.

    ORDERED_FEE_SCHEMES =
      # Slightly wordy, but gets the intended ordering of FeeSchemes
      FeeScheme.where(name: 'AGFS')
               .map { |scheme| "#{scheme.name} #{scheme.version}" }
               .sort_by { |x| x[/\d+/].to_i } +
      FeeScheme.where(name: 'LGFS')
               .map { |scheme| "#{scheme.name} #{scheme.version}" }
               .sort_by { |x| x[/\d+/].to_i }
    CLAIM_TYPES =
      # TODO: Low priority, but this (and the headers) could be improved by being made not static
      %w[Claim::AdvocateClaim
         Claim::AdvocateHardshipClaim
         Claim::AdvocateInterimClaim
         Claim::AdvocateSupplementaryClaim
         Claim::InterimClaim
         Claim::LitigatorClaim
         Claim::LitigatorHardshipClaim
         Claim::TransferClaim]


    include StuffLogger

    def self.call(...)
      new(...).call
    end

    def initialize(**kwargs)
      @format = kwargs.fetch(:format, :csv)
    end

    def call
      log_info('Fee Scheme Usage Report generation started...')
      output = generate_new_report
      log_info('Fee Scheme Usage Report generation finished')
      Stats::Result.new(output, @format)
    end



    private

    def case_types
      CaseType.all.map(&:name)
    end

    def generate_new_report
      CSV.generate do |csv|
        csv << headers
        month_array.each do |month|
          generate_month(csv, month[0], month[1])
          csv << []
        end
      end
    rescue StandardError => e
      log_error(e, 'Fee Scheme Usage Report generation error')
    end

    def generate_month(csv, date_start, date_end)
      generate_data(date_start, date_end)
      ORDERED_FEE_SCHEMES.each do |scheme|
        csv << generate_row(date_start.strftime('%B'), scheme)
      end
    end

    def empty_results_hash
      output = {}
      ORDERED_FEE_SCHEMES.each do |scheme|
        output[symbol_key(scheme)] = Hash.new(0)
      end
      output
    end

    def generate_data(date_start, date_end)
      @results = empty_results_hash

      claims.where(last_submitted_at: date_start..date_end).find_each do |claim|
        fee_scheme = symbol_key("#{claim.fee_scheme.name} #{claim.fee_scheme.version}")
        update_total_claims(fee_scheme)
        update_total_value_of_claims(claim, fee_scheme)
        update_most_recent_claim(claim, fee_scheme)
        update_claim_types(claim, fee_scheme)
        update_case_types(claim, fee_scheme)
      end
    end

    def generate_row(month, fee_scheme)
      key_fs = symbol_key(fee_scheme)
      row = [month, fee_scheme,
             @results[key_fs][:total_claims], @results[key_fs][:total_value], @results[key_fs][:latest]]

      CLAIM_TYPES.each do |type|
        row << @results[key_fs][symbol_key(type)]
      end

      case_types.each do |type|
        row << @results[key_fs][symbol_key(type)]
      end

      row
    end

    def month_array
      month_array = []
      6.times do |offset|
        month = Time.current - offset.month # Current month will be -0 months
        dates = [
          month.at_beginning_of_month,
          month.at_end_of_month
        ]
        month_array << dates
      end
      month_array.reverse
    end

    def headers
      Settings.fee_scheme_usage_csv_headers.map { |header| header.to_s.humanize }
    end

    def claims
      @claims ||= Claim::BaseClaim.active.non_draft
    end

    def symbol_key(string)
      string.parameterize.underscore.to_sym
    end

    def update_total_claims(fee_scheme)
      @results[fee_scheme][:total_claims] += 1
    end

    def update_total_value_of_claims(claim, fee_scheme)
      claim_total = (claim.total.to_f + claim.vat_amount.to_f).round(2)
      @results[fee_scheme][:total_value] += claim_total
    end

    def update_most_recent_claim(claim, fee_scheme)
      date_submitted = claim.last_submitted_at
      return unless @results[fee_scheme][:latest] == 0 || @results[fee_scheme][:latest] < date_submitted
      @results[fee_scheme][:latest] = date_submitted.to_time
    end

    def update_claim_types(claim, fee_scheme)
      claim_type = symbol_key(claim.type)
      @results[fee_scheme][claim_type] += 1
    end

    def update_case_types(claim, fee_scheme)
      return if claim.case_type_id.nil?
      case_type = symbol_key(CaseType.find(claim.case_type_id).name)
      @results[fee_scheme][case_type] += 1
    end
  end
end