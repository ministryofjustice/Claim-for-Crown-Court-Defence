require 'rails_helper'

RSpec.describe CaseWorkerPresenter do

  describe '#working_days_markup' do
    let(:cw)            { FactoryGirl.build :case_worker }
    let(:presenter)     { CaseWorkerPresenter.new(cw, nil) }


    it 'should produce the correct markup if all days are set' do
      cw.days_worked = [ 1, 1, 1, 1, 1]
      expect(presenter.days_worked_markup).to eq all_days_markup
    end

    it 'should produce the correct markup if mon, wed, fri are set' do
      cw.days_worked = [ 1, 0, 1, 0, 1]
      expect(presenter.days_worked_markup).to eq mon_wed_fri_markup
    end


  end


  def all_days_markup
    %q{<div class="working-pattern"><span class="working-day" title="Monday">M</span><span class="working-day" title="Tuesday">T</span><span class="working-day" title="Wednesday">W</span><span class="working-day" title="Thursday">T</span><span class="working-day" title="Friday">F</span></div>}
  end

  def mon_wed_fri_markup
    %q{<div class="working-pattern"><span class="working-day" title="Monday">M</span><span title="Tuesday">T</span><span class="working-day" title="Wednesday">W</span><span title="Thursday">T</span><span class="working-day" title="Friday">F</span></div>}
  end
end
