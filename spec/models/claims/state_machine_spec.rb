require 'rails_helper'

RSpec.describe Claims::StateMachine, type: :model do
  subject { build(:claim) }

  describe 'all available states' do
    let(:states) do
      [:allocated, :appealed, :archived_pending_delete, :awaiting_further_info, :awaiting_info_from_court, :completed,
       :deleted, :draft, :paid, :part_paid, :parts_rejected, :refused, :rejected, :submitted]
    end

    it('exist')       { expect(Claim.state_machine.states.map(&:name).sort).to eq(states.sort) }
    it('are valid')   { states.each { |s| subject.state = s; expect(subject).to be_valid } }
  end

  describe 'valid transitions' do
    describe 'from allocated' do
      before { subject.submit!; subject.allocate! }
      it { expect{ subject.reject! }.to                 change{ subject.state }.to('rejected') }
      it { allow(subject).to receive(:complete!);       expect{ subject.refuse! }.to change{ subject.state }.to('refused') }
      it { expect{ subject.pay_part! }.to               change{ subject.state }.to('part_paid') }
      it { expect{ subject.pay! }.to                    change{ subject.state }.to('paid') }
      it { expect{ subject.await_info_from_court! }.to  change{ subject.state }.to('awaiting_info_from_court') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from appealed' do
      before { subject.submit!; subject.allocate!; subject.pay_part!; subject.reject_parts!; subject.appeal! }
      it { expect{ subject.complete! }.to change{ subject.state }.to('completed') }
      it { expect{ subject.pay! }.to      change{ subject.state }.to('paid') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from awaiting_further_info' do
      before { subject.submit!; subject.allocate!; subject.pay_part!; subject.await_further_info! }
      it { expect{ subject.complete! }.to change{ subject.state }.to('completed') }
      it { expect{ subject.draft! }.to    change{ subject.state }.to('draft') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from awaiting_further_info_from_court' do
      before { subject.submit!; subject.allocate!; subject.await_info_from_court! }
      it { expect{ subject.allocate! }.to change{ subject.state }.to('allocated') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from draft' do
      it { expect{ subject.submit! }.to change{ subject.state }.to('submitted') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from paid' do
      before { subject.submit!; subject.allocate!; subject.pay! }
      it { expect{ subject.complete! }.to change{ subject.state }.to('completed') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from part_paid' do
      before { subject.submit!; subject.allocate!; subject.pay_part! }
      it { expect{ subject.await_further_info! }.to change{ subject.state }.to('awaiting_further_info') }
      it { expect{ subject.reject_parts! }.to          change{ subject.state }.to('parts_rejected') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from parts_rejected' do
      before { subject.submit!; subject.allocate!; subject.pay_part!; subject.reject_parts! }
      it { expect{ subject.complete! }.to change{ subject.state }.to('completed') }
      it { expect{ subject.appeal! }.to   change{ subject.state }.to('appealed') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from refused' do
      before { subject.submit!; subject.allocate!; }
      describe 'note refused state and automatically move to completed' do
        it { expect(subject).to receive(:complete!); subject.refuse! }
      end
      it { expect{ subject.update_column(:state, 'refused'); subject.complete! }.to change{ subject.state }.to('completed') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from rejected' do
      before { subject.submit!; subject.allocate!; subject.reject! }
      it { expect{ subject.draft! }.to change{ subject.state }.to('draft') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end

    describe 'from submitted' do
      before { subject.submit! }
      it { expect{ subject.allocate! }.to change{ subject.state }.to('allocated') }
      it { expect{ subject.archive_pending_delete! }.to change{ subject.state }.to('archived_pending_delete') }
    end
  end # describe 'valid transitions'

  describe 'set triggers' do
    before { Timecop.freeze(Time.now) }
    after  { Timecop.return }

    describe 'make appeal valid for 21 days' do
      before { subject.submit!; subject.allocate!; subject.pay_part!; subject.reject_parts! }
      it { expect(subject).to receive(:update_column).with(:valid_until, Time.now + 21.days); subject.appeal! }
    end

    describe 'make awaiting_furhter_info valid for 21 days' do
      before { subject.submit!; subject.allocate!; subject.pay_part! }
      it { expect(subject).to receive(:update_column).with(:valid_until, Time.now + 21.days); subject.await_further_info! }
    end

    describe 'make parts_rejected valid for 21 days' do
      before { subject.submit!; subject.allocate!; subject.pay_part! }
      it { expect(subject).to receive(:update_column).with(:valid_until, Time.now + 21.days); subject.reject_parts! }
    end

    describe 'make archive_pending_delete valid for 180 days' do
      it { expect(subject).to receive(:update_column).with(:valid_until, Time.now + 180.days); subject.archive_pending_delete! }
    end

    describe 'make submitted_at attribute equal now' do
      it {  expect(subject).to receive(:update_column).with(:submitted_at,Time.now); subject.submit!; }
    end

    describe 'make paid_at attribute equal now' do
      before { subject.submit!; subject.allocate! }
      it {  expect(subject).to receive(:update_column).with(:paid_at,Time.now); subject.pay!; }
    end

  end # describe 'set triggers'
end
