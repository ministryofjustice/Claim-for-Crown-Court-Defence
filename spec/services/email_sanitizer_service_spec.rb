require 'rails_helper'

RSpec.describe EmailSanitizerService, type: :service do
  describe '#call' do
    subject { service.call }

    let(:service) { described_class.new(email) }

    context 'when the email has multiple characters before the @ symbol' do
      let(:email) { 'example@example.com' }
      let(:expected_response) { 'e*****e@example.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the email has a single character before the @ symbol' do
      let(:email) { 'a@b.com' }
      let(:expected_response) { 'a*a@b.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the email has two characters before the @ symbol' do
      let(:email) { 'ab@cd.com' }
      let(:expected_response) { 'a*b@cd.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the email has a dot (.) before the @ symbol' do
      let(:email) { 'first.last@example.com' }
      let(:expected_response) { 'f********t@example.com' }

      it { is_expected.to eq(expected_response) }
    end

    context 'when the email has a hyphen before the @ symbol' do
      let(:email) { 'first-last@example.com' }
      let(:expected_response) { 'f********t@example.com' }

      it { is_expected.to eq(expected_response) }
    end
  end
end
