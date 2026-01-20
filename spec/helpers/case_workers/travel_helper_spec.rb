RSpec.describe CaseWorkers::TravelHelper do
  subject { helper }

  it { is_expected.to respond_to :link_to_map }

  describe '#link_to_map' do
    let(:expense) { create(:expense, :with_calculated_distance, mileage_rate_id: mileage_rate, location: 'Basildon', date: 3.days.ago) }

    subject(:link) do
      Nokogiri::HTML4.fragment(helper.link_to_map(expense, origin: 'SE9 2XX', destination: 'SE9 3XX', target: '_blank'))
                     .search('a')
                     .first
    end

    context 'when on the higher mileage rate' do
      let(:mileage_rate) { 2 }

      it 'sets text of link' do
        expect(link.text).to eql 'View public transport journey'
      end

      it 'sets href attribute to google api with matching params' do
        expect(link.attributes['href'].value).to match(/google.*origin=SE9 2XX.*destination=SE9 3XX.*travelmode=transit/)
      end

      it 'sets target of link' do
        expect(link.attributes['target'].value).to match(/_blank/)
      end

      it 'passes other html options to govuk_link_to' do
        expect(helper).to receive(:govuk_link_to).with('View public transport journey', link.attributes['href'].value, { target: '_not_a_real_value', class: 'not-a-class' })
        helper.link_to_map(expense, origin: 'SE9 2XX', destination: 'SE9 3XX', target: '_not_a_real_value', class: 'not-a-class')
      end
    end

    context 'when on the lower mileage rate' do
      let(:mileage_rate) { 1 }

      it 'sets text of link' do
        expect(link.text).to eql 'View car journey'
      end

      it 'sets href attribute to google api with matching params' do
        expect(link.attributes['href'].value).to match(/google.*origin=SE9 2XX.*destination=SE9 3XX.*travelmode=driving/)
      end

      it 'sets target of link' do
        expect(link.attributes['target'].value).to match(/_blank/)
      end

      it 'passes other html options to govuk_link_to' do
        expect(helper).to receive(:govuk_link_to).with('View car journey', link.attributes['href'].value, { target: '_not_a_real_value', class: 'not-a-class' })
        helper.link_to_map(expense, origin: 'SE9 2XX', destination: 'SE9 3XX', target: '_not_a_real_value', class: 'not-a-class')
      end
    end
  end
end
