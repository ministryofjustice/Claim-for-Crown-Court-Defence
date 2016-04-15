require 'rails_helper'

describe AdpFormBuilder do

  let(:resource)  { FactoryGirl.create :claim }
  let(:builder)   { AdpFormBuilder.new(:claim, resource, self, {} ) }


  describe 'collection_select2_with_data' do

    before(:each) do
      CaseType.delete_all
      @ct1 = FactoryGirl.create :case_type, name: "Case Type A", is_fixed_fee: true
      @ct2 = FactoryGirl.create :case_type, name: "Case Type B", is_fixed_fee: false
      @ct3 = FactoryGirl.create :case_type, name: "Case Type C", is_fixed_fee: true
      @case_types = [@ct1, @ct2, @ct3]
    end


    it 'should output select with data attributes on each option' do
      html = builder.collection_select2_with_data(:case_type_id, @case_types, :id, :name, {'is-fixed-fee' => :is_fixed_fee?}, { prompt: true } )
      expect(html).to eq(squash(expected_output_with_one_data_attribute))
    end
  end


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

def expected_output_with_one_data_attribute
  html = <<EOS
    <select id="claim_case_type_id" name="claim[case_type_id]" class="select2">
      <option value="">Please select</option>
      <option data-is-fixed-fee="true" value="#{@ct1.id}">Case Type A</option>
      <option data-is-fixed-fee="false" value="#{@ct2.id}">Case Type B</option>
      <option data-is-fixed-fee="true" value="#{@ct3.id}">Case Type C</option>
    </select>
EOS
end


def squash(html)
  html.gsub(/\s+\</, '<').chomp
end
