# NOTEs:
# scheme 9:
#   BASAF/MISAF and defendant uplift MISAU: only days 5 to 30 claimable separately
#   BAPCM/MIPCM: only appearances 6+ have a value in API but supposedly 2+ in web
#   help text - from business point of view a PTPH is a SAF and and contibutes towards the
#   limits of claimable SAFs (5+) see AGFS 2013 regs. Schedule 1, part, para.12
#
RSpec.describe Claims::FeeCalculator::FeeTypeLimit do
  SCHEME_9_FEE_TYPE_LIMIT_MAPPINGS = {
    BABAF: { from: 1, to: 2 },
    BADAF: { from: 3, to: 40 },
    BADAH: { from: 41, to: 50 },
    BADAJ: { from: 51, to: 9999 },
    BASAF: { from: 5, to: 30 },
    BAPCM: { from: 6, to: nil },
    BACAV: { from: 7, to: 8 },
    MISAF: { from: 5, to: 30 },
    MISAU: { from: 5, to: 30 },
    MIPCM: { from: 6, to: nil }
  }

  SCHEME_10_PLUS_FEE_TYPE_LIMIT_MAPPINGS = {
    BABAF: { from: 1, to: 1 },
    BADAT: { from: 2, to: 9999 },
    BASAF: { from: 1, to: 6 },
    BAPCM: { from: 1, to: 6 },
    BACAV: { from: 7, to: 8 },
    MISAF: { from: 1, to: 6 },
    MISAU: { from: 1, to: 6 },
    MIPCM: { from: 1, to: 6 }
  }

  let(:agfs_scheme_9_claim) do
    create(:draft_claim, create_defendant_and_rep_order_for_scheme_9: true)
  end

  let(:agfs_scheme_10_claim) do
    create(:draft_claim, create_defendant_and_rep_order_for_scheme_10: true)
  end

  let(:lgfs_claim) do
    create(:litigator_claim, create_defendant_and_rep_order_for_scheme_9: true)
  end

  context 'instance' do
    subject { described_class.new(fee_type, claim) }

    let(:claim) { instance_double(Claim::BaseClaim) }
    let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code: 'whatever') }

    it { is_expected.to respond_to(:limit_from) }
    it { is_expected.to respond_to(:limit_to) }
  end

  describe '#limit_from' do
    subject { described_class.new(fee_type, claim).limit_from }

    context 'AGFS claim' do
      context 'scheme 9' do
        let(:claim) { agfs_scheme_9_claim }

        SCHEME_9_FEE_TYPE_LIMIT_MAPPINGS.each do |unique_code, limits|
          context "fee type unique code #{unique_code}" do
            let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code:) }

            it { is_expected.to eql limits[:from] }
          end
        end
      end

      context 'scheme 10+' do
        let(:claim) { agfs_scheme_10_claim }

        SCHEME_10_PLUS_FEE_TYPE_LIMIT_MAPPINGS.each do |unique_code, limits|
          context "fee type unique code #{unique_code}" do
            let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code:) }

            it { is_expected.to eql limits[:from] }
          end
        end

        context 'other fee types' do
          let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code: 'NONSENSE') }

          it { is_expected.to eq 1 }
        end
      end
    end

    context 'LGFS claim' do
      let(:claim) { lgfs_claim }

      context 'all fee types' do
        let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code: 'NONSENSE') }

        it { is_expected.to eq 0 }
      end
    end
  end

  describe '#limit_to' do
    subject { described_class.new(fee_type, claim).limit_to }

    context 'AGFS claim' do
      context 'scheme 9' do
        let(:claim) { agfs_scheme_9_claim }

        SCHEME_9_FEE_TYPE_LIMIT_MAPPINGS.each do |unique_code, limits|
          context "fee type unique code #{unique_code}" do
            let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code:) }

            it { is_expected.to eql limits[:to] }
          end
        end
      end

      context 'scheme 10+' do
        let(:claim) { agfs_scheme_10_claim }

        SCHEME_10_PLUS_FEE_TYPE_LIMIT_MAPPINGS.each do |unique_code, limits|
          context "fee type unique code #{unique_code}" do
            let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code:) }

            it { is_expected.to eql limits[:to] }
          end
        end

        context 'other fee types' do
          let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code: 'NONSENSE') }

          it { is_expected.to be_nil }
        end
      end
    end

    context 'LGFS claim' do
      let(:claim) { lgfs_claim }

      context 'all fee types' do
        let(:fee_type) { instance_double(Fee::BaseFeeType, unique_code: 'NONSENSE') }

        it { is_expected.to be_nil }
      end
    end
  end
end
