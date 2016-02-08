require "rails_helper"


describe ApplicationHelper do

  context '#present' do
    let(:claim) { create(:claim) }

    it 'should return a <Classname>Presenter instance' do
     expect(present(claim)).to be_instance_of ClaimPresenter
    end

    it 'should yield a <Classname>Presenter Class' do
      expect{ |b| present(claim, &b) }.to yield_with_args(ClaimPresenter)
    end

  end

  context '#present_collection' do
    let(:claims) { create_list(:claim, 2) }

    it 'should return a collection of <Classname>Presenter instances' do
      present_collection(claims).each do |claim|
        expect(claim).to be_instance_of ClaimPresenter
      end
    end

    it 'should yield a collection of <Classname>Presenter Class instances' do
      expect { |block| present_collection(claims, &block) }.to yield_with_args([ClaimPresenter,ClaimPresenter])
    end

  end

  context '#number_with_precision_or_default' do

    it 'should return empty string if given integer zero and no precision' do
      expect(number_with_precision_or_default(0)).to eq ''
    end

    it 'should return empty string if given integer zero and precision' do
      expect(number_with_precision_or_default(0, precision: 2)).to eq ''
    end

    it 'should return empty string if given BigDecimal zero' do
      expect(number_with_precision_or_default(BigDecimal.new(0,5))).to eq ''
    end

    it 'should return empty string if given Float zero' do
      expect(number_with_precision_or_default(0.0, precision: 2)).to eq ''
    end

    it 'should return 3.33 if given 3.3333 with precsion 2' do
      expect(number_with_precision_or_default(3.333, precision: 2)).to eq '3.33'
    end

    it 'should return 24.5 if given 24.5 with no precision' do
      expect(number_with_precision_or_default(24.5)).to eq '24.5'
    end

    it 'should return 4 if given 3.645 with precsion 0' do
      expect(number_with_precision_or_default(3.645, precision: 0)).to eq '4'
    end

    context 'with default specified' do
      it 'should return default value if given Float zero with precision 2' do
        expect(number_with_precision_or_default(0.0, precision: 2, default: '1')).to eq '1'
      end

      it 'should NOT return default value if given a non-zero value' do
        expect(number_with_precision_or_default(2, default: '1')).to eq '2'
      end
    end

  end

end