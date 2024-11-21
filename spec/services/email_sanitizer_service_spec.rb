require 'rails_helper'

RSpec.describe EmailSanitizerService, type: :service do
  describe '#call' do
    subject { service.call }

    let(:service) { described_class.new(email) }

    context 'when the local part has multiple characters' do
      let(:email) { 'example@example.com' }
      let(:expected_response) { 'e*****e@e*****e.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the local part has a single character' do
      let(:email) { 'a@b.com' }
      let(:expected_response) { 'a*a@b*b.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the local part has two characters' do
      let(:email) { 'ab@cd.com' }
      let(:expected_response) { 'a*b@c*d.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the local part contains a dot (.)' do
      let(:email) { 'first.last@example.com' }
      let(:expected_response) { 'f********t@e*****e.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the local part contains a hyphen (-)' do
      let(:email) { 'first-last@example.com' }
      let(:expected_response) { 'f********t@e*****e.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the domain has multiple parts' do
      let(:email) { 'user@sub.example.com' }
      let(:expected_response) { 'u**r@s*b.e*****e.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the domain has a single character' do
      let(:email) { 'user@a.com' }
      let(:expected_response) { 'u**r@a*a.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the email is invalid without an @ symbol' do
      let(:email) { 'invalidemail.com' }
      let(:expected_response) { 'Invalid email, cannot be redacted' }

      it { is_expected.to eq(expected_response) }
    end
  end
end
