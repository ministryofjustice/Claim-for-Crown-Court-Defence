require File.dirname(__FILE__) + '/database_housekeeping'

module TestHelpers
  # Methods here are exposed globally to all rspec tests, but do not abuse this.
  # Do not require external dependencies in this file, and only use it when the
  # methods are going to be used in a lot of specs.
  #
  # Requiring heavyweight dependencies from this file will add to the boot time of
  # the test suite on EVERY test run.
  # Instead, consider making a separate helper file and requiring it from the spec
  # file or files that actually need it.

  include DatabaseHousekeeping

  shared_context 'claim-types helpers' do
    let(:agfs_claim_types) { %w[agfs agfs_interim agfs_supplementary agfs_hardship] }
    let(:lgfs_claim_types) { %w[lgfs_final lgfs_interim lgfs_transfer] }
    let(:all_claim_types) { agfs_claim_types | lgfs_claim_types }
  end

  shared_context 'claim-types object helpers' do
    let(:agfs_claim_object_types) { %w[Claim::AdvocateClaim Claim::AdvocateInterimClaim Claim::AdvocateSupplementaryClaim Claim::AdvocateHardshipClaim] }
    let(:lgfs_claim_object_types) { %w[Claim::LitigatorClaim Claim::InterimClaim Claim::TransferClaim] }
    let(:all_claim_object_types) { agfs_claim_object_types | lgfs_claim_object_types }

    # Usable outside examples
    class << self
      def agfs_claim_type_objects
        [Claim::AdvocateClaim, Claim::AdvocateInterimClaim, Claim::AdvocateSupplementaryClaim, Claim::AdvocateHardshipClaim]
      end

      def lgfs_claim_type_objects
        [Claim::LitigatorClaim, Claim::InterimClaim, Claim::TransferClaim]
      end

      def all_claim_type_objects
        agfs_claim_type_objects | lgfs_claim_type_objects
      end
    end
  end

  def expect_invalid_attribute_with_message(record, attribute, value, message)
    error_attribute = attribute if error_attribute.nil?
    set_value(record, attribute, value)
    expect(record).not_to be_valid
    expect(record.errors[error_attribute]).to include(message)
  end

  def expect_valid_attribute(record, attribute, value)
    # error_attribute = attribute if error_attribute.nil?
    set_value(record, attribute, value)
    record.valid?
    expect(no_error_for(record, attribute)).to be true
    # expect(record.errors.keys).not_to include(error_attribute)
  end

  def set_value(record, attribute, value)
    setter_method = "#{attribute}=".to_sym
    record.__send__(setter_method, value)
  end

  def no_error_for(record, attribute)
    return true unless record.errors.keys.include?(attribute)
    return true if record.errors[attribute].empty?
    return false
  end

  def with_env(env)
    @original_env = ENV['ENV']
    ENV['ENV'] = env
    yield
  ensure
    ENV['ENV'] = @original_env
  end

  def scheme_date_for(text)
    case text&.downcase&.strip
      when 'scheme 11' then
        Settings.agfs_scheme_11_release_date.strftime
      when 'scheme 10' || 'post agfs reform' then
        Settings.agfs_fee_reform_release_date.strftime
      when 'scheme 9' || 'pre agfs reform' then
        "2016-01-01"
      when 'lgfs' then
        "2016-04-01"
      else
        "2016-01-01"
    end
  end
end
