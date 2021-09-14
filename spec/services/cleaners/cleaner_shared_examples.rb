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
