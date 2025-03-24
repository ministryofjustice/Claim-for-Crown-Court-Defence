require 'rails_helper'

describe API::Entities::CCR::DateAttended do
  subject(:response) { JSON.parse(described_class.represent(date_attended).to_json).deep_symbolize_keys }

  let(:date_attended) { build(:date_attended, date: Time.zone.today - 30.days, date_to: Time.zone.today - 29.days) }

  it 'has expected json key-value pairs' do
    expect(response).to include(from: (Time.zone.today - 30.days).strftime('%Y-%m-%d'),
                                to: (Time.zone.today - 29.days).strftime('%Y-%m-%d'))
  end
end
