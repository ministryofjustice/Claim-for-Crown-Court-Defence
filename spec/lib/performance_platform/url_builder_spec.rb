require 'rails_helper'

describe PerformancePlatform::UrlBuilder do
  subject(:url_builder) { described_class.for_type(type) }

  describe 'when called with a group and type' do
    before { allow(PerformancePlatform.configuration).to receive(:group).and_return('report_group')}
    let(:type) { 'report_type' }

    it { is_expected.to eql 'https://www.performance.service.gov.uk/data/report_group/report_type' }
  end
end
