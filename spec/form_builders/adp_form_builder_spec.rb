require 'rails_helper'

describe AdpFormBuilder do

  before(:all) do
    create :court, name: 'Kinghtsbridge', code: '400'
    create :court, name: 'Reading', code: '635'
    create :court, name: 'Southward', code: '306'
  end

  after(:all) do
    Court.delete_all
  end

  let(:resource)  { FactoryGirl.create :claim, court: Court.find_by(name: 'Reading') }
  let(:builder)   { AdpFormBuilder.new(:claim, resource, self, {} ) }

  describe 'awesomeplete_collection_select' do

    it 'should produce ordered list with no prompt' do
      actual = builder.awesomeplete_collection_select(:court_id, Court.all, :id, :name)
      expect(actual).to eq expected_html_for_simple_selection_no_prompt
    end

    def expected_html_for_simple_list_no_prompt
      result =
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


def squash(html)
  html.gsub(/\s+\</, '<').chomp
end
