require 'rails_helper'

describe AwesomepleteCollectionSelector do


  before(:all) do
    create :court, name: 'Kinghtsbridge', code: '400', id: 98731
    create :court, name: 'Reading', code: '635', id: 98732
    create :court, name: 'Southwark', code: '306', id: 98733
  end

  after(:all) do
    Court.delete_all
  end

  let(:resource)  { FactoryGirl.create :claim, court: Court.find_by(name: 'Reading') }
  let(:builder)   { AdpFormBuilder.new(:claim, resource, self, {} ) }

  describe 'awesomeplete_collection_select' do

    context 'error' do
      it 'raises if no name specified in data_optiont' do
        expect {
          AwesomepleteCollectionSelector.new(builder, :court, Court.all, :id, :name, prompt: 'Select value')
        }.to raise_error ArgumentError, 'Must specify name of field in data options'
      end
    end

    context 'valid object with values' do
      it 'produces ordered list with no prompt' do
        selector = AwesomepleteCollectionSelector.new(builder, :court, Court.all, :id, :name, name: 'claim[court_id]')
        expect(selector.to_html).to eq valid_no_prompt
      end

      it 'produces an ordered list with prompt' do
        selector = AwesomepleteCollectionSelector.new(builder, :court, Court.all, :id, :name, prompt: 'Please select value', name: 'claim[court_id]')
        expect(selector.to_html).to eq valid_with_prompt
      end

      it 'produces an ordered list with blank first line' do
        selector = AwesomepleteCollectionSelector.new(builder, :court, Court.all, :id, :name, include_blank: true, name: 'claim[court_id]')
        expect(selector.to_html).to eq valid_with_blank
      end


      def valid_no_prompt
        result = %q|<div class="awesomplete">|
        result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" name="claim[court_id]" value="Reading" autocomplete="off" aria-autocomplete="list">|
        result += %q|<ul>|
        result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
        result += %q|<li aria-selected="true" data-value="98732">Reading</li>|
        result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
        result += %q|</ul>|
        result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
        result += %q|</div>|
        squash(result)
      end

      def valid_with_prompt
        result = %q|<div class="awesomplete">|
        result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" name="claim[court_id]" value="Reading" autocomplete="off" aria-autocomplete="list">|
        result += %q|<ul>|
        result += %q|<li aria-selected="false">Please select value</li>|
        result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
        result += %q|<li aria-selected="true" data-value="98732">Reading</li>|
        result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
        result += %q|</ul>|
        result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
        result += %q|</div>|
        squash(result)
      end

      def valid_with_blank
        result = %q|<div class="awesomplete">|
        result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" name="claim[court_id]" value="Reading" autocomplete="off" aria-autocomplete="list">|
        result += %q|<ul>|
        result += %q|<li aria-selected="false"></li>|
        result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
        result += %q|<li aria-selected="true" data-value="98732">Reading</li>|
        result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
        result += %q|</ul>|
        result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
        result += %q|</div>|
        squash(result)
      end
    end

    context 'nil object' do
      let(:resource)  { FactoryGirl.create :claim, court: nil }

      it 'produces ordered list with nothing selected' do
        selector = AwesomepleteCollectionSelector.new(builder, :court, Court.all, :id, :name, name: 'claim[court_id]')
        expect(selector.to_html).to eq nil_no_prompt
      end

      it 'produces an ordered list with prompt' do
        selector = AwesomepleteCollectionSelector.new(builder, :court, Court.all, :id, :name, prompt: 'Please select value', name: 'claim[court_id]')
        expect(selector.to_html).to eq nil_with_prompt
      end

      it 'produces an ordered list with blank first line' do
        selector = AwesomepleteCollectionSelector.new(builder, :court, Court.all, :id, :name, include_blank: true, name: 'claim[court_id]')
        expect(selector.to_html).to eq nil_with_blank
      end



      def nil_no_prompt
        result = %q|<div class="awesomplete">|
        result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" name="claim[court_id]" autocomplete="off" aria-autocomplete="list">|
        result += %q|<ul>|
        result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
        result += %q|<li aria-selected="false" data-value="98732">Reading</li>|
        result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
        result += %q|</ul>|
        result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
        result += %q|</div>|
        squash(result)
      end

      def nil_with_prompt
        result = %q|<div class="awesomplete">|
        result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" name="claim[court_id]" value="Please select value" autocomplete="off" aria-autocomplete="list">|
        result += %q|<ul>|
        result += %q|<li aria-selected="true">Please select value</li>|
        result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
        result += %q|<li aria-selected="false" data-value="98732">Reading</li>|
        result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
        result += %q|</ul>|
        result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
        result += %q|</div>|
        squash(result)
      end

      def nil_with_blank
        result = %q|<div class="awesomplete">|
        result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" name="claim[court_id]" autocomplete="off" aria-autocomplete="list">|
        result += %q|<ul>|
        result += %q|<li aria-selected="true"></li>|
        result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
        result += %q|<li aria-selected="false" data-value="98732">Reading</li>|
        result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
        result += %q|</ul>|
        result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
        result += %q|</div>|
        squash(result)
      end
    end

  end

  def squash(html)
    html.gsub(/\s+\</, '<').chomp
  end




end