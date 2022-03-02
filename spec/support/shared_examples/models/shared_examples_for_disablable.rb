# frozen_string_literal: true

RSpec.shared_examples 'a disablable object' do
  describe '.disabled' do
    subject { described_class.disabled }

    before do
      create(:user, disabled_at: nil)
      create(:user, disabled_at: Time.zone.now)
    end

    it 'returns records with disabled_at present' do
      is_expected.to all(have_attributes(disabled_at: be_kind_of(Time)))
    end
  end

  describe '.enabled' do
    subject { described_class.enabled }

    before do
      create(described_class.to_s.downcase.to_sym, disabled_at: nil)
      create(described_class.to_s.downcase.to_sym, disabled_at: Time.zone.now)
    end

    it 'returns records with disabled_at absent' do
      is_expected.to all(have_attributes(disabled_at: nil))
    end
  end

  describe '#disable' do
    let(:object) { create(described_class.to_s.downcase.to_sym, disabled_at: nil) }

    it 'sets disabled_at to a time' do
      expect { object.disable }.to change(object, :disabled_at).from(nil).to(be_kind_of(Time))
    end
  end

  describe '#enable' do
    let(:object) { create(described_class.to_s.downcase.to_sym, disabled_at: Time.zone.now) }

    it 'sets disabled_at to nil' do
      expect { object.enable }.to change(object, :disabled_at).from(be_kind_of(Time)).to(nil)
    end
  end

  describe '#disabled?' do
    it 'returns true if disabled_at present' do
      object = build(described_class.to_s.downcase.to_sym, disabled_at: Time.zone.now)
      expect(object).to be_disabled
    end

    it 'returns false if disabled_at absent' do
      object = build(described_class.to_s.downcase.to_sym, disabled_at: nil)
      expect(object).not_to be_disabled
    end
  end

  describe '#enabled?' do
    it 'returns true if disabled_at absent' do
      object = build(described_class.to_s.downcase.to_sym, disabled_at: nil)
      expect(object).to be_enabled
    end

    it 'returns false if disabled_at present' do
      object = build(described_class.to_s.downcase.to_sym, disabled_at: Time.zone.now)
      expect(object).not_to be_enabled
    end
  end
end
