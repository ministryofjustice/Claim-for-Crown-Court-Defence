require 'rails_helper'

RSpec.describe Claim::AdvocateClaimPresenter do

  let(:claim) { create :claim }
  subject { Claim::AdvocateClaimPresenter.new(claim, view) }

  it { expect(subject).to be_instance_of(Claim::AdvocateClaimPresenter) }
  it { expect(subject).to be_kind_of(Claim::BaseClaimPresenter) }

end
