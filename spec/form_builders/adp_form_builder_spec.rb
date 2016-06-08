require 'rails_helper'

describe AdpFormBuilder do

  # before(:all) do
  #   create :court, name: 'Kinghtsbridge', code: '400', id: 98731
  #   create :court, name: 'Reading', code: '635', id: 98732
  #   create :court, name: 'Southwark', code: '306', id: 98733
  # end
  #
  # after(:all) do
  #   Court.delete_all
  # end
  #
  # let(:resource)  { FactoryGirl.create :claim, court: Court.find_by(name: 'Reading') }
  # let(:builder)   { AdpFormBuilder.new(:claim, resource, self, {} ) }
  #
  # describe 'awesomeplete_collection_select' do
  #
  #   context 'error' do
  #     it 'raises if no name specified in data_optiont' do
  #       expect {
  #         builder.awesomeplete_collection_select(:court, Court.all, :id, :name)
  #       }.to raise_error ArgumentError, 'Must specify name of field in data options'
  #     end
  #   end
  #
  #   context 'valid object with values' do
  #     it 'produces ordered list with no prompt' do
  #       actual = builder.awesomeplete_collection_select(:court, Court.all, :id, :name, name: 'claim[court_id]')
  #       expect(actual).to eq expected_html_for_simple_list_no_prompt_with_valid_object
  #     end
  #
  #     it 'produces an ordered list with prompt' do
  #       actual = builder.awesomeplete_collection_select(:court, Court.all, :id, :name, prompt: 'Please select value')
  #       expect(actual).to eq expected_html_for_simple_list_with_prompt_with_valid_object
  #     end
  #
  #     it 'produces an ordered list with blank first line' do
  #       let(:resource)  { FactoryGirl.create :claim, court: Court.find_by(name: 'Reading') }
  #     end
  #
  #     def expected_html_for_simple_list_no_prompt_with_valid_object
  #       result = %q|<div class="awesomplete">|
  #       result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" name="claim[court_id]" value="Reading" autocomplete="off" aria-autocomplete="list">|
  #       result += %q|<ul>|
  #       result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
  #       result += %q|<li aria-selected="true" data-value="98732">Reading</li>|
  #       result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
  #       result += %q|</ul>|
  #       result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
  #       result += %q|</div>|
  #       squash(result)
  #     end
  #
  #     def expected_html_for_simple_list_with_prompt_with_valid_object
  #       result = %q|<div class="awesomplete">|
  #       result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" value="Reading" autocomplete="off" aria-autocomplete="list">|
  #       result += %q|<ul>|
  #       result += %q|<li aria-selected="false">Please select value</li>|
  #       result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
  #       result += %q|<li aria-selected="true" data-value="98732">Reading</li>|
  #       result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
  #       result += %q|</ul>|
  #       result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
  #       result += %q|</div>|
  #       squash(result)
  #     end
  #
  #     def expected_html_for_simple_list_with_with_blank_first_item_for_valid_object
  #       result = %q|<div class="awesomplete">|
  #       result += %q|<input class="form-control" id="claim_case_type_id_autocomplete" value="Reading" autocomplete="off" aria-autocomplete="list">|
  #       result += %q|<ul>|
  #       result += %q|<li aria-selected="false"></li>|
  #       result += %q|<li aria-selected="false" data-value="98731">Kinghtsbridge</li>|
  #       result += %q|<li aria-selected="true" data-value="98732">Reading</li>|
  #       result += %q|<li aria-selected="false" data-value="98733">Southwark</li>|
  #       result += %q|</ul>|
  #       result += %q|<span class="visually-hidden" role="status" aria-live="assertive" aria-relevant="additions"></span>|
  #       result += %q|</div>|
  #       squash(result)
  #     end
  #   end
  #
  #   context 'nil object' do
  #     let(:resource)  { FactoryGirl.create :claim, court: nil }
  #
  #     it 'produces ordered list with nothing selected' do
  #       actual = builder.awesomeplete_collection_select(:court, Court.all, :id, :name)
  #       expect(actual).to eq expected_html_for_simple_list_no_prompt_with_nil_object
  #     end
  #
  #     def expected_html_for_simple_list_no_prompt_with_nil_object
  #
  #     end
  #   end
  #
  # end


  describe 'anchored_label' do
    context 'no anchor name supplied' do
      it 'should take the label as the anchor name' do
        expected_html = %Q[<a name="advocate_category"></a><label for="claim_advocate_category">Advocate category</label>]
        expect(builder.anchored_label('Advocate category')).to eq expected_html
      end
    end

    context 'anchor name supplied' do
      it 'should use anchor name supplied' do
        expected_html = %Q[<a name="ad_cat"></a><label for="claim_ad_cat">Advocate category</label>]
        expect(builder.anchored_label('Advocate category', 'ad_cat')).to eq expected_html
      end
    end

    context 'extra html attributes supplied' do
      it 'should use the attributes when anchor name supplied' do
        expected_html = %Q[<a name="ad_cat" class="red"></a><label class="blue" for="claim_ad_cat">Advocate category</label>]
        expect(builder.anchored_label('Advocate category', 'ad_cat', { anchor_attributes: {class: 'red'}, label_attributes: {class: 'blue'} })).to eq expected_html
      end

      it 'should use the attributes when no anchor name provided' do
        expected_html = %Q[<a name="advocate_category" class="red"></a><label class="blue" for="claim_advocate_category">Advocate category</label>]
        expect(builder.anchored_label('Advocate category', nil, { anchor_attributes: {class: 'red'}, label_attributes: {class: 'blue'} })).to eq expected_html
      end
    end
  end

  describe 'anchored_without_label' do
    context 'no anchor name supplied' do
      it 'should take the label as the anchor name' do
        expected_html = %Q[<a name="advocate_category"></a>]
        expect(builder.anchored_without_label('Advocate category')).to eq expected_html
      end
    end

    context 'anchor name supplied' do
      it 'should use anchor name supplied' do
        expected_html = %Q[<a name="ad_cat"></a>]
        expect(builder.anchored_without_label('Advocate category', 'ad_cat')).to eq expected_html
      end
    end

    context 'extra html attributes supplied' do
      it 'should use the attributes' do
        expected_html = %Q[<a name="ad_cat" class="red"></a>]
        expect(builder.anchored_without_label('Advocate category', 'ad_cat', anchor_attributes: {class: 'red'})).to eq expected_html
      end
    end
  end

  describe 'anchored_attribute' do
    it 'should build the label from the object and label' do
      expected_html = %Q[<a name="advocate_claim.test"></a>]
      expect(builder.anchored_attribute('test')).to eq expected_html
    end

    it 'should use any provided attributes' do
      expected_html = %Q[<a name="advocate_claim.test" class="red"></a>]
      expect(builder.anchored_attribute('test', anchor_attributes: {class: 'red'})).to eq expected_html
    end
  end
end


def squash(html)
  html.gsub(/\s+\</, '<').chomp
end
