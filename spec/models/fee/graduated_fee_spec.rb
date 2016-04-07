# == Schema Information
#
# Table name: fees
#
#  id                    :integer          not null, primary key
#  claim_id              :integer
#  fee_type_id           :integer
#  quantity              :integer
#  amount                :decimal(, )
#  created_at            :datetime
#  updated_at            :datetime
#  uuid                  :uuid
#  rate                  :decimal(, )
#  type                  :string
#  warrant_issued_date   :date
#  warrant_executed_date :date
#

require 'rails_helper'

module Fee
  describe GraduatedFee do
    it { should belong_to(:fee_type) }

    it { should validate_presence_of(:claim).with_message('blank') }

    it { should validate_presence_of(:fee_type).with_message('blank') }

    it { expect(subject).to respond_to(:requires_trial_dates) }
    it { expect(subject).to respond_to(:first_day_of_trial) }
    it { expect(subject).to respond_to(:actual_trial_length) }

    describe "Trial timings", "(FDoT = First Day of Trial, ATL = Actual Trial Length)" do
      let(:a_week_ago) { Time.now - 7.days }

      context "Case type requires trial dates" do
        before do
          allow(subject).to receive(:requires_trial_dates).and_return(true)
        end

        context "FDoT is blank" do
          before do
            allow(subject).to receive(:first_day_of_trial).and_return(nil)
            allow(subject).to receive(:actual_trial_length).and_return(5)
            subject.valid?
          end

          it "Error message on FDoT" do
            expect(subject.errors.messages[:first_day_of_trial])
              .to eq(["blank"])
          end

          it "No error message on ATL" do
            expect(subject.errors.messages[:actual_trial_length])
              .to eq(nil)
          end
        end

        context "ATL is blank" do
          before do
            allow(subject).to receive(:first_day_of_trial)
              .and_return(a_week_ago)
            allow(subject).to receive(:actual_trial_length).and_return(nil)
            subject.valid?
          end

          it "No error message on FDoT" do
            expect(subject.errors.messages[:first_day_of_trial])
              .to eq(nil)
          end

          it "Error message on ATL" do
            expect(subject.errors.messages[:actual_trial_length])
              .to eq(["blank"])
          end
        end

        context "FDoT and ATL are both populated" do
          context "FDoT not in the past" do
            let(:tomorrow) { Time.now + 1.day }

            before do
              allow(subject).to receive(:first_day_of_trial)
                .and_return(tomorrow)
              allow(subject).to receive(:actual_trial_length).and_return(5)
              subject.valid?
            end

            it "Error on FDoT" do
              expect(subject.errors[:first_day_of_trial])
                .to eq(["in_past"])
            end
          end

          context "FDoT over 5 years ago" do
            let(:over_5_years) { Time.now - 5.years - 1.day }

            before do
              allow(subject).to receive(:first_day_of_trial)
                .and_return(over_5_years)
              allow(subject).to receive(:actual_trial_length).and_return(5)
              subject.valid?
            end

            it "Error on FDoT" do
              expect(subject.errors[:first_day_of_trial])
                .to eq(["since_5_years"])
            end
          end

          context "ATL too long" do
            before do
              allow(subject).to receive(:first_day_of_trial)
                .and_return(a_week_ago)
              allow(subject).to receive(:actual_trial_length).and_return(9)
              subject.valid?
            end

            it "Error on ATL" do
              expect(subject.errors[:actual_trial_length])
                .to eq(["too_long"])
            end
          end

          context "FDofT less than 5 years ago, ATL within limits" do
            before do
              allow(subject).to receive(:first_day_of_trial)
                .and_return(a_week_ago)
              allow(subject).to receive(:actual_trial_length).and_return(3)
              subject.valid?
            end

            it "No errors on FDoT" do
              expect(subject.errors[:first_day_of_trial]).to eq([])
            end

            it "No errors on ATL" do
              expect(subject.errors[:actual_trial_length]).to eq([])
            end
          end
        end
      end

      context "Case type does not require trial dates" do
        before do
          allow(subject).to receive(:requires_trial_dates)
            .and_return(false)
        end

        context "FDoT is populated" do
          before do
            allow(subject).to receive(:first_day_of_trial).and_return(a_week_ago)
            allow(subject).to receive(:actual_trial_length).and_return(nil)
            subject.valid?
          end

          it "Error message on FDoT" do
            expect(subject.errors.messages[:first_day_of_trial])
              .to eq(["present"])
          end
        end

        context "ATL is populated" do
          before do
            allow(subject).to receive(:first_day_of_trial).and_return(nil)
            allow(subject).to receive(:actual_trial_length).and_return(5)
            subject.valid?
          end

          it "Error message on ATL" do
            expect(subject.errors.messages[:actual_trial_length])
              .to eq(["present"])
          end
        end
      end
    end
  end
end
