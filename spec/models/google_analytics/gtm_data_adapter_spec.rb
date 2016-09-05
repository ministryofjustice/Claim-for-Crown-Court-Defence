require 'rails_helper'

module GoogleAnalytics

  describe GTMDataAdapter do
    describe '.new' do
      it 'raises an exception if the template is unknown' do
        expect { described_class.new(:test, {}) }.to raise_exception(UnknownDataTemplate)
      end
    end

    describe '#template' do
      context 'for virtual_page' do
        it 'returns the expected hash for this template' do
          expect(described_class.new(:virtual_page, {}).template).to \
            eq({event: 'VirtualPageview', virtualPageURL: '%{url}', virtualPageTitle: '%{title}'})
        end
      end
    end

    describe '#to_s' do
      context 'for virtual_page' do
        it 'returns the expected javascript string for this template' do
          expect(described_class.new(:virtual_page, url: '/test', title: 'Test').to_s).to \
            eq %q{dataLayer.push({"event":"VirtualPageview","virtualPageURL":"/test","virtualPageTitle":"Test"});}
        end

        it 'returns the expected javascript string for this template with the data for interpolation provided' do
          expect(described_class.new(:virtual_page, {url: '/test/%{id}/%{action}', title: 'Test %{id} %{action}'}, {id: 123, action: 'new'}).to_s).to \
            eq %q{dataLayer.push({"event":"VirtualPageview","virtualPageURL":"/test/123/new","virtualPageTitle":"Test 123 new"});}
        end
      end
    end
  end
end
