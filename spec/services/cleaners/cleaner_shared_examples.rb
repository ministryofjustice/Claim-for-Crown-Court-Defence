RSpec.shared_examples 'clear cracked details' do
  it { expect { call_cleaner }.to change(claim, :trial_fixed_notice_at).to nil }
  it { expect { call_cleaner }.to change(claim, :trial_fixed_at).to nil }
  it { expect { call_cleaner }.to change(claim, :trial_cracked_at).to nil }
  it { expect { call_cleaner }.to change(claim, :trial_cracked_at_third).to nil }
end

RSpec.shared_examples 'does not clear cracked details' do
  it { expect { call_cleaner }.not_to change(claim, :trial_fixed_notice_at).from(cracked[:trial_fixed_notice_at]) }
  it { expect { call_cleaner }.not_to change(claim, :trial_fixed_at).from(cracked[:trial_fixed_at]) }
  it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at).from(cracked[:trial_cracked_at]) }
  it { expect { call_cleaner }.not_to change(claim, :trial_cracked_at_third).from(cracked[:trial_cracked_at_third]) }
end

RSpec.shared_examples 'fix advocate category' do
  context 'with no advocate category' do
    before { claim.advocate_category = nil }

    context 'with a fee scheme 13 representation order' do
      before do
        claim.defendants = [
          build(:defendant, scheme: 'scheme 13')
        ]
      end

      it { expect { call_cleaner }.not_to change(claim, :advocate_category) }
    end

    context 'with a fee scheme 15 representation order' do
      before do
        claim.defendants = [
          build(:defendant, scheme: 'scheme 15')
        ]
      end

      it { expect { call_cleaner }.not_to change(claim, :advocate_category) }
    end
  end

  context 'with a QC advocate category' do
    before { claim.advocate_category = 'QC' }

    context 'with no defendants' do
      before { claim.defendants = [] }

      it { expect { call_cleaner }.not_to change(claim, :advocate_category) }
    end

    context 'with a fee scheme 13 representation order' do
      before do
        claim.defendants = [
          build(:defendant, scheme: 'scheme 13')
        ]
      end

      it { expect { call_cleaner }.not_to change(claim, :advocate_category) }
    end

    context 'with a fee scheme 15 representation order' do
      before do
        claim.defendants = [
          build(:defendant, scheme: 'scheme 15')
        ]
      end

      it { expect { call_cleaner }.to change(claim, :advocate_category).to 'KC' }
    end
  end

  context 'with a KC advocate category' do
    before { claim.advocate_category = 'KC' }

    context 'with no defendants' do
      before { claim.defendants = [] }

      it { expect { call_cleaner }.not_to change(claim, :advocate_category) }
    end

    context 'with a fee scheme 13 representation order' do
      before do
        claim.defendants = [
          build(:defendant, scheme: 'scheme 13')
        ]
      end

      it { expect { call_cleaner }.to change(claim, :advocate_category).to 'QC' }
    end

    context 'with a fee scheme 15 representation order' do
      before do
        claim.defendants = [
          build(:defendant, scheme: 'scheme 15')
        ]
      end

      it { expect { call_cleaner }.not_to change(claim, :advocate_category) }
    end
  end
end
