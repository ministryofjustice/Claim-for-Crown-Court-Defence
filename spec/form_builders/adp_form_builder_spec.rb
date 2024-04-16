require 'rails_helper'

RSpec.describe AdpFormBuilder do
  let(:resource)  { create(:claim) }
  let(:builder)   { AdpFormBuilder.new(:claim, resource, self, {}) }

  describe 'anchored_without_label' do
    context 'no anchor name supplied' do
      it 'takes the label as the anchor name' do
        expected_html = '<a id="advocate_category"></a>'
        expect(builder.anchored_without_label('Advocate category')).to eq expected_html
      end
    end

    context 'anchor name supplied' do
      it 'uses anchor name supplied' do
        expected_html = '<a id="ad_cat"></a>'
        expect(builder.anchored_without_label('Advocate category', 'ad_cat')).to eq expected_html
      end
    end

    context 'extra html attributes supplied' do
      it 'uses the attributes' do
        expected_html = '<a id="ad_cat" class="red"></a>'
        expect(builder.anchored_without_label('Advocate category', 'ad_cat', anchor_attributes: { class: 'red' })).to eq expected_html
      end
    end
  end

  describe 'anchored_attribute' do
    it 'builds the label from the object and label' do
      expected_html = '<a id="advocate_claim.test"></a>'
      expect(builder.anchored_attribute('test')).to eq expected_html
    end

    it 'uses any provided attributes' do
      expected_html = '<a id="advocate_claim.test" class="red"></a>'
      expect(builder.anchored_attribute('test', anchor_attributes: { class: 'red' })).to eq expected_html
    end
  end
end

def squash(html)
  html.gsub(/\s+</, '<').chomp
end
