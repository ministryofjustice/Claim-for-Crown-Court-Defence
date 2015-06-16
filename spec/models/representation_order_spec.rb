require 'rails_helper'

RSpec.describe RepresentationOrder, type: :model do

  it { should validate_presence_of(:granting_body) }

end