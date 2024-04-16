require 'rails_helper'

RSpec.describe AdpFormBuilder do
  let(:resource)  { create(:claim) }
  let(:builder)   { AdpFormBuilder.new(:claim, resource, self, {}) }

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
