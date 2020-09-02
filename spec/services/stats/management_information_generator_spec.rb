require 'rails_helper'

RSpec.describe Stats::ManagementInformationGenerator do
  subject(:result) { described_class.call }

  let(:frozen_time) { Time.new(2015, 3, 10, 11, 44, 55) }

  context 'data generation' do
    subject(:contents) { result.content.split("\n")}

    let!(:valid_claims) {
      [
        create(:allocated_claim),
        create(:authorised_claim),
        create(:part_authorised_claim)
      ]
    }
    let!(:draft_claim) { create(:draft_claim) }
    let!(:non_active_claim) { Timecop.freeze(frozen_time) { create(:allocated_claim) } }
    
    it 'returns CSV content with a header and a row for all active non-draft claims' do
      expect(contents.size).to eq(valid_claims.size + 1)
    end
    
    it 'has 21 columns' do
      expect(contents.first.split(',').count).to eql 21
    end
  end
  
  context 'logging' do
    let!(:error) { StandardError.new('test error') }

    it 'can log info using LogStuff' do
      expect(LogStuff).to receive(:send)
      .with(:info, 'Report generation started...')
      described_class.call 
    end
    
    it 'can log errors with LogStuff' do
      expect(LogStuff).to receive(:send)
      .with(
        :error, 
        'Stats::ManagementInformationGenerator', 
        error_message: "#{error.class} - #{error.message}",
        error_backtrace: error.backtrace.inspect.to_s) do
          'MI Report generation error'
        end
      described_class.new.send(:log_error, error)
    end
  end
  
end
