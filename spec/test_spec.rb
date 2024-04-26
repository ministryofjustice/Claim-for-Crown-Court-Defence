require 'i18n/tasks'
require 'rails_helper'

RSpec.describe 'temp test' do
  it 'fails 50% of the time' do
    rand = Random.new.rand(1..2)
    expect(rand).to eq 1
  end
end
