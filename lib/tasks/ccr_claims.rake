namespace :ccr_claims do

  # retrieve claims for use as fixtures in CCR testing
  desc 'extract CCR structured JSON for CCCD claims: args[sample_size: 10, filename: nil/STDOUT]'
  task :sample_json, [:sample_size, :filename] => :environment do |_task, args|
    @args = args

    redirect_output args[:filename] do
      claims_json = sample_claims('part_authorised', 'authorised').each_with_object([]) do |claim, memo|
        uri = ccr_claim_api uuid: claim.uuid, api_key: admin_api_key
        begin
          response = RestClient.get(uri)
          memo << JSON.parse(response)
        rescue => e
          warn "Error: #{e} for claim #{claim.uuid} on ap #{uri}"
        end
      end
      puts JSON.pretty_generate(claims_json)
    end
  end

  def defaults
    @defaults ||= @args.with_defaults(sample_size: 10, filename: nil)
  end

  def sample_size
    @sample_size ||= defaults[:sample_size].to_i
  end

  def ccr_claim_api uuid:, api_key:
    "#{Settings.remote_api_url}/ccr/claims/#{uuid}?api_key=#{api_key}"
  end

  def redirect_output base_filename
    if base_filename.present?
      std_out = STDOUT.clone
      $stdout.reopen(base_filename + '.out.json','w')
      std_err = STDERR.clone
      $stderr.reopen(base_filename + '.err.txt','w')
    end

    yield

    if base_filename.present?
      message = "Check #{base_filename}.out.json and #{base_filename}.err.txt for output"
      $stdout = std_out
      $stderr = std_err
      puts '-' * message.length
      puts message
      puts '-' * message.length
    end
  end

  # The DEMO environment has an env var containing supplier numbers that should be used
  # to retrieve claims with supplier numbers that CCR "knows"
  #
  def sample_claims *states
    if redcentric_supplier_numbers
      Claim::AdvocateClaim.where(state: states).where(supplier_number: redcentric_supplier_numbers).sample(sample_size)
    else
      Claim::AdvocateClaim.where(state: states).sample(sample_size)
    end
  end

  def redcentric_supplier_numbers
    @redcentric_supplier_numbers ||= ENV['REDCENTRIC_CCR_SUPPLIER_NUMBERS']&.split(' ')
  end

  def admin_api_key
    @api_key ||= CaseWorker.where("roles LIKE '%admin%case_worker%'").first.user.api_key
  end
end
