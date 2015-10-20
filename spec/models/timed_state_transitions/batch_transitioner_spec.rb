require 'rails_helper'


module TimedTransitions

  describe BatchTransitioner do 

    before(:each) do
      Timecop.freeze 61.days.ago do
        @old_draft     = FactoryGirl.create :claim
        @old_auth      = FactoryGirl.create :authorised_claim
        @old_part_auth = FactoryGirl.create :part_authorised_claim
        @old_refused   = FactoryGirl.create :refused_claim
        @old_rejected  = FactoryGirl.create :rejected_claim
        @old_archived  = FactoryGirl.create :archived_pending_delete_claim
      end

      Timecop.freeze 59.days.ago do
        @new_draft     = FactoryGirl.create :claim
        @new_auth      = FactoryGirl.create :authorised_claim
        @new_part_auth = FactoryGirl.create :part_authorised_claim
        @new_refused   = FactoryGirl.create :refused_claim
        @new_rejected  = FactoryGirl.create :rejected_claim
        @new_archived  = FactoryGirl.create :archived_pending_delete_claim
      end
    end
   
    it 'should transition those that need to be transitioned and not others' do
      BatchTransitioner.new.run
      
      expect(@new_draft.state).to eq 'draft'
      expect(@new_auth.state).to eq 'authorised'
      expect(@new_part_auth.state).to eq 'part_authorised'
      expect(@new_refused.state).to eq 'refused'
      expect(@new_rejected.state).to eq 'rejected'
      expect(@new_archived.state).to eq 'archived_pending_delete'

      expect(@old_draft.reload.state).to eq 'draft'
      expect(@old_auth.reload.state).to eq 'archived_pending_delete'
      expect(@old_part_auth.reload.state).to eq 'archived_pending_delete'
      expect(@old_refused.reload.state).to eq 'archived_pending_delete'
      expect(@old_rejected.reload.state).to eq 'archived_pending_delete'
      
      expect {
        @old_archived.reload
      }.to raise_error ActiveRecord::RecordNotFound


    end

  end
end