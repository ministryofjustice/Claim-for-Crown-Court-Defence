require 'rails_helper'

RSpec.describe Claim, type: :model do
  it { should belong_to(:advocate) }
  it { should belong_to(:court) }
  it { should have_many(:claim_fees) }
  it { should have_many(:fees) }
  it { should have_many(:expenses) }
  it { should have_many(:defendants) }
  it { should have_many(:documents) }

  it { should have_many(:case_worker_claims) }
  it { should have_many(:case_workers) }

  it { should validate_presence_of(:advocate) }
  it { should validate_presence_of(:court) }

  it { should validate_presence_of(:case_type) }
  it { should validate_inclusion_of(:case_type).in_array(%w( guilty trial retrial cracked_retrial )) }

  it { should validate_presence_of(:offence_class) }
  it { should validate_inclusion_of(:offence_class).in_array(('A'..'J').to_a) }

  it { should accept_nested_attributes_for(:claim_fees) }
  it { should accept_nested_attributes_for(:expenses) }
  it { should accept_nested_attributes_for(:defendants) }
end
