require 'rails_helper'

RSpec.describe CaseWorkerService do
  subject(:service) { described_class.new(current_user: :my_user, criteria: { key: :my_criteria }) }

  describe '#active' do
    subject(:active) { service.active }

    before { allow(Remote::CaseWorker).to receive(:all) }

    it 'calls Remote::Caseworker with user and criteria' do
      service.active
      expect(Remote::CaseWorker).to have_received(:all).with(:my_user, { key: :my_criteria })
    end
  end
end
