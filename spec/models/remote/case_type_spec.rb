require 'rails_helper'

describe Remote::CaseType do
  let(:client) { instance_double(Remote::HttpClient, get: response) }

  it 'has the correct resource path' do
    expect(described_class.resource_path).to eq('case_types')
  end

  context 'class methods' do
    before(:each) do
      allow(described_class).to receive(:client).and_return(client)
    end

    describe '.all' do
      it 'returns a collection of all case types' do
        case_types = described_class.all
        expect(case_types.map(&:id)).to eq([1, 9, 13, 11, 12])
      end
    end

    describe '.agfs' do
      it 'returns a collection of case types with role agfs' do
        expect(described_class.agfs.map(&:id)).to eq([1, 9, 11, 12])
      end
    end

    describe '.lgfs' do
      it 'returns a collection of case types with role lgfs' do
        expect(described_class.lgfs.map(&:id)).to eq([1, 9, 13, 11, 12])
      end
    end

    describe '.interims' do
      it 'returns a collection of case types with role interim' do
        expect(described_class.interims.map(&:id)).to eq([11, 12])
      end
    end

    describe '.find' do
      it 'returns the case type with the specified id' do
        ct = described_class.find(9)
        expect(ct.id).to eq 9
        expect(ct.name).to eq('Elected cases not proceeded')
        expect(ct.is_fixed_fee).to be true
        expect(ct.requires_cracked_dates).to be false
        expect(ct.requires_trial_dates).to be false
        expect(ct.allow_pcmh_fee_type).to be false
        expect(ct.requires_maat_reference).to be true
        expect(ct.requires_retrial_dates).to be false
        expect(ct.roles).to eq(['agfs', 'lgfs'])
      end
    end
  end

  def response
    [
      {
        'id' => 1,
        'name' => 'Appeal against conviction',
        'is_fixed_fee' => true,
        'requires_cracked_dates' => false,
        'requires_trial_dates' => false,
        'allow_pcmh_fee_type' => false,
        'requires_maat_reference' => true,
        'requires_retrial_dates' => false,
        'roles' => ['agfs', 'lgfs'],
        'fee_type_code' => 'ACV'
      },
      {
        'id' => 9,
        'name' => 'Elected cases not proceeded',
        'is_fixed_fee' => true,
        'requires_cracked_dates' => false,
        'requires_trial_dates' => false,
        'allow_pcmh_fee_type' => false,
        'requires_maat_reference' => true,
        'requires_retrial_dates' => false,
        'roles' => ['agfs', 'lgfs'],
        'fee_type_code' => 'ENP'
      },
      {
        'id' => 13,
        'name' => 'Hearing subsequent to sentence',
        'is_fixed_fee' => true,
        'requires_cracked_dates' => false,
        'requires_trial_dates' => false,
        'allow_pcmh_fee_type' => false,
        'requires_maat_reference' => true,
        'requires_retrial_dates' => false,
        'roles' => ['lgfs'],
        'fee_type_code' => 'XH2S'
      },
      {
        'id' => 11,
        'name' => 'Retrial',
        'is_fixed_fee' => false,
        'requires_cracked_dates' => false,
        'requires_trial_dates' => true,
        'allow_pcmh_fee_type' => true,
        'requires_maat_reference' => true,
        'requires_retrial_dates' => true,
        'roles' => ['agfs', 'lgfs', 'interim'],
        'fee_type_code' => 'GRTR'
      },
      {
        'id' => 12,
        'name' => 'Trial',
        'is_fixed_fee' => false,
        'requires_cracked_dates' => false,
        'requires_trial_dates' => true,
        'allow_pcmh_fee_type' => true,
        'requires_maat_reference' => true,
        'requires_retrial_dates' => false,
        'roles' => ['agfs', 'lgfs', 'interim'],
        'fee_type_code' => 'GTRL'
      }
    ]
  end
end
