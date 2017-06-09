namespace :ccr_claims do
  desc 'extract CCR structured JSON for CCCD claims'
  task :sample_json => :environment do |_task, args|

    api_key = admin_api_key
    sample_claims.each do |claim|

      uri = "#{Settings.remote_api_url}/ccr/claims/#{claim.uuid}?api_key=#{api_key}"

      begin
        response = RestClient.get(uri)
        output JSON.pretty_generate(JSON.parse(response))
      rescue RestClient::ResourceNotFound => e
        output "Error: #{e.message} raised while processing claim #{claim.uuid}"
        output response
      rescue RestClient::InternalServerError => e
        output "Error: #{e.message} raised while processing claim #{claim.uuid}"
        output response
      end

    end
  end

  def output string
    puts string
  end

  def sample_claims
     Claim::BaseClaim.where(state: 'allocated').sample(10)
  end

  def admin_api_key
    CaseWorker.where("roles LIKE '%admin%case_worker%'").first.user.api_key
  end
end