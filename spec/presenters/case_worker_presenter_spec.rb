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
    %q{<div class="working-pattern"><ul><li class="working-day"><abbr title="Monday">M</abbr></li><li class="working-day"><abbr title="Tuesday">T</abbr></li><li class="working-day"><abbr title="Wednesday">W</abbr></li><li class="working-day"><abbr title="Thursday">T</abbr></li><li class="working-day"><abbr title="Friday">F</abbr></li></ul></div>}
  end

  def mon_wed_fri_markup
    %q{<div class="working-pattern"><ul><li class="working-day"><abbr title="Monday">M</abbr></li><li><abbr title="Tuesday">T</abbr></li><li class="working-day"><abbr title="Wednesday">W</abbr></li><li><abbr title="Thursday">T</abbr></li><li class="working-day"><abbr title="Friday">F</abbr></li></ul></div>}
  end
end
