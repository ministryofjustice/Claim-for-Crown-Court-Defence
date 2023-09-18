require 'csv'

module Stats
  class FeeSchemeUsageGenerator
    ORDERED_FEE_SCHEMES =
      # Slightly wordy, but gets the intended ordering of FeeSchemes
      FeeScheme.where(name: 'AGFS')
               .map { |scheme| "#{scheme.name} #{scheme.version}" }
               .sort_by { |x| x[/\d+/].to_i } +
      FeeScheme.where(name: 'LGFS')
               .map { |scheme| "#{scheme.name} #{scheme.version}" }
               .sort_by { |x| x[/\d+/].to_i }
    CLAIM_AND_CASE_TYPES = CaseType.all.map(&:name) +
                           ['Claim::Advocate',
                            'Claim::AdvocateHardship',
                            'Claim::AdvocateInterim',
                            'Claim::AdvocateSupplementary',
                            'Claim::InterimClaim',
                            'Claim::LitigatorClaim',
                            'Claim::LitigatorHardship Claim',
                            'Claim::TransferClaim'].freeze

    include StuffLogger

    def self.call(...)
      new(...).call
    end

    def initialize(**kwargs)
      @format = kwargs.fetch(:format, :csv)
    end

    def call
      output = generate_new_report
      Stats::Result.new(output, @format)
    end

    def generate_new_report
      log_info('Fee Scheme Usage Report generation started...')
      content = CSV.generate do |csv|
        csv << headers
        time_array.each do |month|
          generate_month(csv, month[0], month[1])
          csv << []
        end
      end
      log_info('MI Report generation finished')
      content
    end

    def generate_month(csv, date_start, date_end)
      raw_data = generate_data(date_start, date_end)
      ORDERED_FEE_SCHEMES.each do |scheme|
        csv << generate_row(date_start.strftime('%B'), scheme, raw_data)
      end
    end

    def generate_data(date_start, date_end)
      results = []

      results << total_claims(date_start, date_end)
      results << total_value_of_claims(date_start, date_end)
      results << most_recent_claim(date_start, date_end)
      results << claim_and_case_types(date_start, date_end)
      # results << case_types(date_start, date_end)

      results
    end

    def generate_row(month, fee_scheme, raw_data)
      key_fs = symbol_key(fee_scheme)
      row = [month, fee_scheme]

      raw_data.each do |item|
        if item.class == Hash
          CLAIM_AND_CASE_TYPES.each do |type|
            row << item[key_fs][symbol_key(type)]
          end
        else
          row << item[key_fs]
        end
      end
      row
    end

    def time_array
      time_array = []
      6.times do |offset|
        month = Time.current - offset.month # Current month will be -0 months
        month_array = [
          month.at_beginning_of_month,
          month.at_end_of_month
        ]
        time_array << month_array
      end
      time_array.reverse
    end

    def headers
      Settings.fee_scheme_usage_csv_headers.map { |header| header.to_s.humanize }
    end

    def claims
      @claims ||= Claim::BaseClaim.active.non_draft
    end

    def empty_results_hash
      output = {}
      ORDERED_FEE_SCHEMES.each do |scheme|
        output[symbol_key(scheme)] = Hash.new(0)
      end
      output
    end

    def symbol_key(string)
      string.parameterize.underscore.to_sym
    end

    def total_claims(date_start, date_end)
      results = Hash.new(0)
      results.default = 0

      claims.where(last_submitted_at: date_start..date_end).find_each do |claim|
        fee_scheme = symbol_key("#{claim.fee_scheme.name} #{claim.fee_scheme.version}")
        results[fee_scheme] += 1
      end

      results
    end

    def total_value_of_claims(date_start, date_end)
      results = Hash.new(0)

      claims.where(last_submitted_at: date_start..date_end).find_each do |claim|
        claim_total = (claim.total.to_f + claim.vat_amount.to_f).round(2)
        fee_scheme = symbol_key("#{claim.fee_scheme.name} #{claim.fee_scheme.version}")
        results[fee_scheme] += claim_total
      end
      results
    end

    def most_recent_claim(date_start, date_end)
      results = Hash.new(nil)

      claims.where(last_submitted_at: date_start..date_end).find_each do |claim|
        fee_scheme = symbol_key("#{claim.fee_scheme.name} #{claim.fee_scheme.version}")
        date_submitted = claim.last_submitted_at

        results[fee_scheme] = date_submitted.to_time if results[fee_scheme].nil? || results[fee_scheme] < date_submitted
      end
      results
    end

    def claim_and_case_types(date_start, date_end)
      results = empty_results_hash

      claims.where(last_submitted_at: date_start..date_end).find_each do |claim|
        fee_scheme = symbol_key("#{claim.fee_scheme.name} #{claim.fee_scheme.version}")
        claim_type = symbol_key(claim.type)
        case_type = symbol_key(CaseType.find(claim.case_type_id).name)
        results[fee_scheme][claim_type] += 1
        results[fee_scheme][case_type] += 1
      end
      results
    end

    # def case_types(date_start, date_end)
    #   results = empty_results_hash
    #
    #   claims.where(last_submitted_at: date_start..date_end).find_each do |claim|
    #     fee_scheme = symbol_key("#{claim.fee_scheme.name} #{claim.fee_scheme.version}")
    #
    #     results[fee_scheme][case_type] += 1
    #   end
    #   results
    # end
  end
end
