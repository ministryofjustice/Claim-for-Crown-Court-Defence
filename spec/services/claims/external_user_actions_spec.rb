require 'rails_helper'

RSpec.describe Claims::ExternalUserActions do
  describe '.available' do
    subject { described_class.all }

    it { is_expected.to eq ['Apply for redetermination', 'Request written reasons'] }
  end
end
