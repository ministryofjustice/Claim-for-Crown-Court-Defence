require 'rails_helper'
require 'support/database_housekeeping'

RSpec.describe ClaimReporter do
  include DatabaseHousekeeping
  before(:all) do
    @draft_claim_1 = create(:draft_claim, form_id: SecureRandom.uuid)
    @authorised_claim_1 = create(:authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid)
    @submitted_claim_1 = create(:submitted_claim, form_id: SecureRandom.uuid)
    @allocated_claim_1 = create(:allocated_claim, form_id: SecureRandom.uuid)
    @allocated_claim_2 = create(:allocated_claim, form_id: SecureRandom.uuid)
    @part_authorised_claim_1 = create(:part_authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid)
    @part_authorised_claim_2 = create(:part_authorised_claim, authorised_at: Time.now, form_id: SecureRandom.uuid)
    @rejected_claim_1 = create(:rejected_claim, form_id: SecureRandom.uuid)
    @rejected_claim_2 = create(:rejected_claim, form_id: SecureRandom.uuid)

    @old_part_authorised_claim = create(:part_authorised_claim, form_id: SecureRandom.uuid).update_column(:authorised_at, 5.weeks.ago)
    @old_rejected_claim = create(:rejected_claim, form_id: SecureRandom.uuid).last_state_transition.update_column(:created_at, 5.weeks.ago)
  end

  after(:all) do
    clean_database
  end


  subject { ClaimReporter.new }

  describe '#authorised_in_full' do
    it 'returns the percentage of claims authorised in full this month' do
      expect(subject.authorised_in_full[:percentage]).to eq(10)
    end

    it 'returns the count of claims authorised in full this month' do
      expect(subject.authorised_in_full[:count]).to eq(1)
    end
  end

  describe '#authorised_in_part' do
    it 'returns the percentage of claims authorised in part this month' do
      expect(subject.authorised_in_part[:percentage]).to eq(20)
    end

    it 'returns the count of claims authorised in part this month' do
      expect(subject.authorised_in_part[:count]).to eq(2)
    end
  end

  describe '#rejected' do
    it 'returns the percentage of claims rejected this month' do
      expect(subject.rejected[:percentage]).to eq(20)
    end

    it 'returns the count of claims rejected this month' do
      expect(subject.rejected[:count]).to eq(2)
    end
  end

  describe '#rejected_count' do
    it 'returns a count of rejected claims' do
      expect(subject.rejected_count).to eq(3)
    end
  end

  describe '#outstanding' do
    it 'returns all outstanding claims' do
      expect(subject.outstanding).to match_array([@submitted_claim_1, @allocated_claim_1, @allocated_claim_2])
    end
  end

  describe '#oldest_outstanding' do
    it 'returns the oldest outstanding claim' do
      expect(subject.oldest_outstanding).to eq(@submitted_claim_1)
    end
  end

  describe '#completion_rate' do
    before do
      create(:claim_intention, form_id: @submitted_claim_1.form_id)
      create(:claim_intention, form_id: @allocated_claim_1.form_id)

      create(:claim_intention, form_id: SecureRandom.uuid)
      create(:claim_intention, form_id: SecureRandom.uuid)

    end

    it 'returns the completion rate for claims in the last 16 weeks' do
      expect(subject.completion_rate).to eq(50.0)
    end
  end

  describe 'processing_times' do
    it 'returns the claim processing times' do
      expect(subject.processing_times.count).to eq(7)
    end
  end

  describe '#average_processing_time' do
    it 'returns the average processing time for claims' do
      expect(subject.average_processing_time).to be_a Float
    end
  end

  describe '#average_processing_time_in_words' do
    it 'returns the average processing time in words' do
      expect(subject.average_processing_time_in_words).to eq('less than a minute')
    end
  end
end
