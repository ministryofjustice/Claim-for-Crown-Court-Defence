require 'rails_helper'

RSpec.describe Claim::LitigatorClaimPresenter do

  let(:claim) { create :claim }
  subject { Claim::LitigatorClaimPresenter.new(claim, view) }

  it { expect(subject).to be_instance_of(Claim::LitigatorClaimPresenter) }
  it { expect(subject).to be_kind_of(Claim::BaseClaimPresenter) }

end
