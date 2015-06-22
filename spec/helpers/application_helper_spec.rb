require "rails_helper"


describe ApplicationHelper do

  context '#present' do
    let(:claim) { create(:claim) }

    it 'returns a <Classname>Presenter instance' do
     expect(present(claim)).to be_a ClaimPresenter
    end

    it 'yields a <Classname>Presenter Class' do
      expect{ |b| present(claim, &b) }.to yield_with_args(ClaimPresenter)
    end

  end

  context '#number_with_precision_or_blank' do

    it 'should return empty string if given integer zero and no precision' do
      expect(number_with_precision_or_blank(0)).to eq ''
    end

    it 'should return empty string if given integer zero and precision' do
      expect(number_with_precision_or_blank(0, precision: 2)).to eq ''
    end

    it 'should return empty string if given BigDecimal zero' do
      expect(number_with_precision_or_blank(BigDecimal.new(0,5))).to eq ''
    end

    it 'should return empty string if given Float zero' do
      expect(number_with_precision_or_blank(0.0, precision: 2)).to eq ''
    end

    it 'should return 3.33 if given 3.3333 with precsion 2' do
      expect(number_with_precision_or_blank(3.333, precision: 2)).to eq '3.33'
    end

    it 'should return 24.5 if given 24.5 with no precision' do
      expect(number_with_precision_or_blank(24.5)).to eq '24.5'
    end

    it 'should return 4 if given 3.645 with precsion 0' do
      expect(number_with_precision_or_blank(3.645, precision: 0)).to eq '4'
    end

  end

end