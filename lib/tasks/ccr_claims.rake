namespace :ccr_claims do
  desc 'extract CCR structured JSON for CCCD claims'
  task :sample_json, [:filename] => :environment do |_task, args|

    api_key = admin_api_key

    redirect_output args[:filename] do

      claims_json = sample_claims.each_with_object([]) do |claim, memo|
        uri = "#{Settings.remote_api_url}/ccr/claims/#{claim.uuid}?api_key=#{api_key}"
        begin
          response = RestClient.get(uri)
          memo << JSON.parse(response)
        rescue => e
          warn "Error: #{e} for claim #{claim.uuid}"
        end
      end

      puts JSON.pretty_generate(claims_json)
    end
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

  def sample_claims
     Claim::BaseClaim.where(state: 'allocated').sample(10)
  end

  def admin_api_key
    CaseWorker.where("roles LIKE '%admin%case_worker%'").first.user.api_key
  end
end