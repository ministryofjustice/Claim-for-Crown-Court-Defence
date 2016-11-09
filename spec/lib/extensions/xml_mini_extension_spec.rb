require 'rails_helper'

describe XmlMiniExtension do

  subject { [1, 'a', nil] }

  let(:xml_result) { subject.to_xml(options.merge(skip_instruct: true, indent: 0)) }

  context 'without any options' do
    let(:options) { {} }

    it 'should serialize nil values' do
      expect(xml_result).to eq('<objects type="array"><object type="integer">1</object><object>a</object><object nil="true"/></objects>')
    end
  end

  context 'with blank_nils option' do
    let(:options) { {blank_nils: true} }

    it 'should serialize nil values to empty strings' do
      expect(xml_result).to eq('<objects type="array"><object type="integer">1</object><object>a</object><object></object></objects>')
    end
  end

  context 'with skip_nils option' do
    let(:options) { {skip_nils: true} }

    it 'should not serialize nil values and omit them' do
      expect(xml_result).to eq('<objects type="array"><object type="integer">1</object><object>a</object></objects>')
    end
  end
end
