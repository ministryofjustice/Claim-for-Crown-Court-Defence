require 'rails_helper'

describe CaseWorkerService do
  describe '#active' do
    it 'calls Remote::Caseworker with user and criteria' do
      service = CaseWorkerService.new(current_user: :my_user, criteria: { key: :my_criteria })
      expect(Remote::CaseWorker).to receive(:all).with(:my_user, { key: :my_criteria })
      service.active
    end
  end
end
