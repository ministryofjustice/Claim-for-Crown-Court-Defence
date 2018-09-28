RSpec.describe CaseWorkers::TravelHelper do
  subject { helper }

  it { is_expected.to respond_to :link_to_map }

  describe '#link_to_map' do
    subject(:link) do
      Nokogiri::HTML.fragment(helper.link_to_map('Test my link', origin: 'SE9 2XX', destination: 'SE9 3XX', target: '_blank')).
        search('a').
        first
    end

    it 'sets text of link' do
      expect(link.text).to eql 'Test my link'
    end

    it 'sets href attribute to google api with matching params' do
      expect(link.attributes['href'].value).to match(/google.*origin=SE9 2XX.*destination=SE9 3XX.*travelmode=driving/)
    end

    it 'sets target of link' do
      expect(link.attributes['target'].value).to match(/_blank/)
    end

    it 'passes other html options to link_to' do
      expect(helper).to receive(:link_to).with('Test message sending', link.attributes['href'].value, { target: '_not_a_real_value', class: 'not-a-class' })
      helper.link_to_map('Test message sending', origin: 'SE9 2XX', destination: 'SE9 3XX', target: '_not_a_real_value', class: 'not-a-class')
    end
  end
end
