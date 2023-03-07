# frozen_string_literal: true

RSpec.shared_examples 'a disablable object' do
  let(:factory_name) { described_class.name.demodulize.underscore.to_sym }

  describe '.disabled' do
    subject { described_class.disabled }

    let!(:disabled_object) { create(factory_name, disabled_at: Time.zone.now) }

    before { create(factory_name, disabled_at: nil) }

    it 'returns records with disabled_at present' do
      is_expected.to contain_exactly(disabled_object)
    end
  end

  describe '.enabled' do
    subject { described_class.enabled }

    let!(:enabled_object) { create(factory_name, disabled_at: nil) }

    before { create(factory_name, disabled_at: Time.zone.now) }

    it 'returns records with disabled_at absent' do
      is_expected.to contain_exactly(enabled_object)
    end
  end

  describe '#disable' do
    let(:object) { create(described_class.name.demodulize.underscore.to_sym, disabled_at: nil) }

    it 'sets disabled_at to a time' do
      expect { object.disable }.to change(object, :disabled_at).from(nil).to(be_a(Time))
    end
  end

  describe '#enable' do
    let(:object) { create(factory_name, disabled_at: Time.zone.now) }

    it 'sets disabled_at to nil' do
      expect { object.enable }.to change(object, :disabled_at).from(be_a(Time)).to(nil)
    end
  end

  describe '#disabled?' do
    it 'returns true if disabled_at present' do
      object = build(factory_name, disabled_at: Time.zone.now)
      expect(object).to be_disabled
    end

    it 'returns false if disabled_at absent' do
      object = build(factory_name, disabled_at: nil)
      expect(object).not_to be_disabled
    end
  end

  describe '#enabled?' do
    it 'returns true if disabled_at absent' do
      object = build(factory_name, disabled_at: nil)
      expect(object).to be_enabled
    end

    it 'returns false if disabled_at present' do
      object = build(factory_name, disabled_at: Time.zone.now)
      expect(object).not_to be_enabled
    end
  end
end

RSpec.shared_examples 'a disablable delegator' do |delegatee|
  let(:object) { create(factory_name) }
  let(:delegatee) { delegatee }
  let(:factory_name) { described_class.name.demodulize.underscore.to_sym }

  it { is_expected.to delegate_method(:disabled_at=).to(delegatee).with_arguments(Time.zone.now) }
  it { is_expected.to delegate_method(:disabled_at=).to(delegatee).with_arguments(nil) }
  it { is_expected.to delegate_method(:disabled_at).to(delegatee) }
  it { is_expected.to delegate_method(:disable).to(delegatee) }
  it { is_expected.to delegate_method(:disabled?).to(delegatee) }
  it { is_expected.to delegate_method(:enable).to(delegatee) }
  it { is_expected.to delegate_method(:enabled?).to(delegatee) }

  describe '#disabled_at=' do
    subject(:assignment) { object.disabled_at = Time.zone.now }

    it { expect { assignment }.to change(object, :disabled_at).from(nil).to(be_a(Time)) }
    it { expect { assignment }.to change(object.send(delegatee), :disabled_at).from(nil).to(be_a(Time)) }
  end

  describe '#disable' do
    subject(:call) { object.disable }

    it { expect { call }.to change(object, :disabled?).from(false).to(true) }
    it { expect { call }.to change(object.send(delegatee), :disabled?).from(false).to(true) }
    it { expect { call }.to change(object, :disabled_at).from(nil).to(be_a(Time)) }
    it { expect { call }.to change(object.send(delegatee), :disabled_at).from(nil).to(be_a(Time)) }
  end

  describe '#enable' do
    subject(:call) { object.enable }

    before { object.disabled_at = Time.zone.now }

    it { expect { call }.to change(object, :enabled?).from(false).to(true) }
    it { expect { call }.to change(object.send(delegatee), :enabled?).from(false).to(true) }
    it { expect { call }.to change(object, :disabled_at).from(be_a(Time)).to(nil) }
    it { expect { call }.to change(object.send(delegatee), :disabled_at).from(be_a(Time)).to(nil) }
  end

  describe '#disabled?' do
    it 'returns true if user.disabled_at present' do
      object = build(factory_name, delegatee => build(delegatee, disabled_at: Time.zone.now))
      expect(object).to be_disabled
    end

    it 'returns false if user.disabled_at absent' do
      object = build(factory_name, delegatee => build(delegatee, disabled_at: nil))
      expect(object).not_to be_disabled
    end
  end

  describe '#enabled?' do
    it 'returns true if user.disabled_at absent' do
      object = build(factory_name, delegatee => build(delegatee, disabled_at: nil))
      expect(object).to be_enabled
    end

    it 'returns false if user.disabled_at present' do
      object = build(factory_name, delegatee => build(delegatee, disabled_at: Time.zone.now))
      expect(object).not_to be_enabled
    end
  end

  describe '.disabled' do
    subject { described_class.disabled }

    before do
      create(factory_name, user: build(:user, disabled_at: nil))
      create(factory_name, user: build(:user, disabled_at: Time.zone.now))
    end

    it 'returns records with disabled_at present' do
      is_expected.to all(have_attributes(disabled_at: be_a(Time)))
    end
  end

  describe '.enabled' do
    subject { described_class.enabled }

    before do
      create(factory_name, user: build(:user, disabled_at: nil))
      create(factory_name, user: build(:user, disabled_at: Time.zone.now))
    end

    it 'returns records with disabled_at absent' do
      is_expected.to all(have_attributes(disabled_at: nil))
    end
  end
end
