require 'shell-spinner'

#
# Redcentric is the CCR application's development environment
#
namespace :redcentric do

  # retrieve claims for use as fixtures in CCR testing
  desc 'extract CCR structured JSON for CCCD claims: args[sample_size: 10, filename: nil/STDOUT]'
  task :ccr_claims_json, [:sample_size, :filename] => :environment do |_task, args|

    args.with_defaults(sample_size: 10, filename: nil)

    redirect_output args[:filename] do
      claims_json = sample_claims('part_authorised', 'authorised', sample_size: args[:sample_size].to_i).each_with_object([]) do |claim, memo|
        uri = ccr_claim_api uuid: claim.uuid, api_key: admin_api_key
        begin
          response = RestClient.get(uri)
          memo << JSON.parse(response)
        rescue => e
          warn "Error: #{e} for claim #{claim.uuid} on endpoint #{uri}"
        end
      end
      puts JSON.pretty_generate(claims_json)
    end
  end

  # update a sample (default 20) of external users' supplier numbers
  # and their advocate claims of the specified state (default: authorised)
  # to have supplier numbers and maat refs that are known to redcentric CCR
  # ----------------------
  # NOTE:
  # - you cannot update claim supplier numbers without first updating their external uses supplier number
  # - once you update an external users suppplier number you should update all their claims.
  #
  desc 'update a sample of external users and their claims to have Redcentric CCR known supplier numbers and MAAT references: args[ sample size: 20, states: authorised]'
  task :update_cccd_claims, [:sample_size, :states] => :environment do |_task, args|

    environment_protected

    args.with_defaults(sample_size: 20, states: 'authorised')
    states = args[:states].split(',')
    sample_size = args[:sample_size].to_i
    updated_claims = []

    ShellSpinner 'updating claims' do
      external_users = Claim::AdvocateClaim.where(state: states).map(&:external_user).sample(sample_size).uniq

      external_users.each do |eu|
        sn = redcentric_supplier_numbers.sample
        eu.update!(supplier_number: sn)
        Claim::AdvocateClaim.where(external_user_id: eu.id).where(state: states).each_with_object(updated_claims) do |claim, claims|
          claim.update!(supplier_number: sn)
          claim.defendants.map(&:representation_orders).flatten.each do |rep_order|
            rep_order.update!(maat_reference: redcentric_maat_references.sample)
          end
          claims << claim
        end
      end
    end

    puts "Updated #{updated_claims.size} claims:"
    puts Claim::BaseClaim.where(id: updated_claims.map(&:id)).pluck(:uuid)
  end

  def environment_protected
    raise 'The operation was aborted because the result might destroy production data!' if ActiveRecord::Base.connection_config[:database] =~ /gamma/
    raise 'The operation was aborted because it is intended only for use in the demo environment!' if ActiveRecord::Base.connection_config[:database] !~ /demo/
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

  # The DEMO environment has env vars containing supplier numbers
  # and MAAT references that should be used to retrieve claims
  # with supplier numbers/MAAT refs that CCR "knows"
  #
  def sample_claims *states, sample_size:
    if redcentric_supplier_numbers && redcentric_maat_references
      Claim::AdvocateClaim.
        joins(defendants: :representation_orders).
        where(state: states).
        where(supplier_number: redcentric_supplier_numbers).
        where(representation_orders: { maat_reference: redcentric_maat_references })
    else
      Claim::AdvocateClaim.where(state: states).sample(sample_size)
    end
  end

  def redcentric_supplier_numbers
    @redcentric_supplier_numbers ||= ENV['REDCENTRIC_CCR_SUPPLIER_NUMBERS']&.split(' ')
  end

  def redcentric_maat_references
    @redcentric_maat_references ||= ENV['REDCENTRIC_CCR_MAAT_REFS']&.split(' ')
  end

  def admin_api_key
    @api_key ||= CaseWorker.where("roles LIKE '%case_worker%'").first.user.api_key
  end
end
