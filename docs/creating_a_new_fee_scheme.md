# Creating a New Fee Scheme: Step-by-Step Guide

This guide documents the process of creating a new fee scheme in the Claim for Crown Court Defence application. It is based on the implementation patterns established in previous fee scheme additions.

## Overview

Creating a new fee scheme involves several stages:

1. **Configuration**: Add dates and settings
2. **Data setup**: Define roles and seed data
3. **Model updates**: Add scopes and methods
4. **Factory updates**: Update fee scheme factory logic
5. **Service updates**: Update eligibility services
6. **Rake tasks**: Create migration/seeding tasks
7. **Test updates**: Update factories and specs

## Prerequisites

Before starting, you need:

- The **start date** of the new fee scheme (from policy/legal team)
- Confirmation of which **offences** are included (usually inherited from previous scheme)
- Details of any **new or modified fee types**
- The **scheme number** (typically the next sequential number)

---

## Part 1: Application Code Changes

### Step 1: Add the Start Date to Settings

Update `config/settings.yml` with the new scheme's start date:

```yaml
# config/settings.yml

# For AGFS:
agfs_scheme_17_start_date: '2025-04-01'

# For LGFS:
lgfs_scheme_12_start_date: '2025-04-01'
```

### Step 2: Add the New Role to Fee Types

#### Update fee_types.csv

Add a new column for the scheme role in `lib/assets/data/fee_types.csv`. Each fee type that should be available in the new scheme needs the role added in the `ROLES` field, which contains a semicolon-delimited list:

```csv
ID,DESCRIPTION,CODE,UNIQUE_CODE,...,ROLES,PARENT_ID,QUANTITY_IS_DECIMAL,POSITION
1,Basic Fee,BASIC,BABAF,...,agfs;agfs_scheme_9;agfs_scheme_10;agfs_scheme_12;agfs_scheme_13;agfs_scheme_14;agfs_scheme_15;agfs_scheme_16;agfs_scheme_17,,FALSE,1
2,Daily attendance fee (3 to 40),DAF,BADAF,...,agfs_scheme_9,,FALSE,2
```

In this example, `agfs_scheme_17` has been added to the basic fee (code `BASIC`) but not the daily attendance fee (code `DAF`).

#### Update the ROLES constant

Add the new role to `app/models/fee/base_fee_type.rb`:

```ruby
# app/models/fee/base_fee_type.rb
ROLES = %w[
  lgfs lgfs_scheme_9 lgfs_scheme_10 lgfs_scheme_11
  agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12 agfs_scheme_13 
  agfs_scheme_14 agfs_scheme_15 agfs_scheme_16 agfs_scheme_17
].freeze
```

#### Update the API dropdown data

Add the new role to `app/interfaces/api/v1/dropdown_data.rb`:

```ruby
# app/interfaces/api/v1/dropdown_data.rb
params :scheme_role_filter do
  optional :role,
            type: String,
            desc: I18n.t('api.v1.dropdown_data.params.role_filter'),
            values: %w[
              agfs agfs_scheme_9 agfs_scheme_10 agfs_scheme_12
              agfs_scheme_13 agfs_scheme_14 agfs_scheme_15 agfs_scheme_16 agfs_scheme_17
              lgfs lgfs_scheme_9 lgfs_scheme_10
            ]
end
```

This will make the new scheme available in the API via the Swagger docs.

![Screenshot of Swagger docs for the API showing the `api/fee_types` endpoint with the `roles` field open and displaying all available roles, representting fee schemes.](swagger-fee_types-roles.png)

### Step 3: Update the Fee Scheme Model

Add a method to check if a fee scheme is the new scheme in `app/models/fee_scheme.rb`:

```ruby
# app/models/fee_scheme.rb
def agfs_scheme_17?
  agfs? && version == 17
end
```

### Step 4: Update the Fee Scheme Factory

Update the appropriate factory to include the new scheme's date range. Ususally this requires a simple date range, as detailed below. These
factories allow for more complex fee scheme determination if necessary. See, for example. AGFS fee scheme 13 and LGFS fee scheme 10.

The end date of the previous fee scheme should also be updated, from `Time.zone.today` to the date one day prior to the start of the new fee scheme.

#### For AGFS

Update `app/models/fee_scheme_factory/agfs.rb`:

```ruby
# app/models/fee_scheme_factory/agfs.rb
module FeeSchemeFactory
  class AGFS
    private

    def name = 'AGFS'

    def filters
      @filters ||= [
        { scheme: 9, range: Date.parse('1 April 2012')..(Settings.agfs_fee_reform_release_date - 1.day) },
        ...
        { scheme: 16, range: scheme_sixteen_range },
        { scheme: 17, range: scheme_seventeen_range} # Filter for the new fee scheme
      ]
    end

    ...

    # Updated to fix end date of the range
    def scheme_sixteen_range
      Settings.agfs_scheme_16_section_twenty_eight_increase..(Settings.agfs_scheme_17_start_date - 1.day)
    end

    # Range for the new fee scheme, ending 'today'
    def scheme_seventeen_range
      Settings.agfs_scheme_17_start_date..Time.zone.today
    end
  end
end
```

#### For LGFS

Update `app/models/fee_scheme_factory/lgfs.rb` following the same pattern.

### Step 5: Update the Offence Model

Add a scope and query method in `app/models/offence.rb`:

```ruby
# app/models/offence.rb
class Offence < ApplicationRecord
  # Add scope to find offences in the new scheme
  scope :in_scheme_17, -> { joins(:fee_schemes).merge(FeeScheme.agfs.where(version: 17)) }
  
  # Method to determine if offence is valid for the new fee scheme
  def scheme_seventeen?
    fee_schemes.map(&:version).any?(17)
  end
end
```

### Step 6: Update Claim Models

Add scheme delegation in `app/models/claim/base_claim.rb`:

```ruby
# app/models/claim/base_claim.rb
delegate :agfs_scheme_17?, to: :fee_scheme, allow_nil: true
```

> [!NOTE]
> This has previously only been done for AGFS schemes as it is used in `Claims::FetchEligibleMiscFeeTypes` (below) and it is not necessary at present to test the versions of LGFS schemes.

### Step 7: Update Eligibility Services

Update `app/services/claims/fetch_eligible_misc_fee_types.rb`:

```ruby
# app/services/claims/fetch_eligible_misc_fee_types.rb
class Claims::FetchEligibleMiscFeeTypes
  # Add delegation
  delegate :agfs_scheme_17?, to: :claim
  
  private
  
  # Update scheme scope determination
  def agfs_scheme_scope
      return Fee::MiscFeeType.agfs_scheme_17s if agfs_scheme_17?
      return Fee::MiscFeeType.agfs_scheme_16s if agfs_scheme_16?
      return Fee::MiscFeeType.agfs_scheme_15s if agfs_scheme_15?
      # ... existing scheme checks
    end
  end
end
```

> [!NOTE]
> At present this is only necessary for AGFS fee schemes. All LGFS fee schemes use the same fee types. Should this change with
> future LGFS fee schemes it will be necessary to create a similar `lgfs_scheme_scope` method.

### Step 8: Update Claim::TransferBrain::DataItem model

> [!NOTE]
> This is only necessary for LGFS fee schemes. An update may only be required if the new fee scheme includes a change to the 
> logic governing transfer cases

The Claim::TransferBrain::DataItem model contains logic used for LGFS transfer claims. The rules for transfer claims changed 
after LGFS fee scheme 9. This class contains two methods used to override the `==` operater depending on fee scheme in effect.
The `equal_for_scheme_nine?` and `equal_for_scheme_ten_or_later?` methods are used to do this. If the rules around transfer 
claims change again in a future fee scheme, it may be necessary to update this class.

For example by renaming `equal_for_scheme_ten_or_later?` to `equal_for_scheme_ten_or_eleven` and creating `equal_for_scheme_twelve?`
to handle the new scenarios:

``` ruby
# Claim-for-Crown-Court-Defence/app/models/claim/transfer_brain/data_item.rb
def ==(other)
  return false unless litigator_type == other.litigator_type
  return false unless equal_for_scheme_nine?(other)
  return false unless equal_for_scheme_ten_or_eleven?(other)
  return false unless equal_for_scheme_twelve?(other)
  return false unless transfer_stage_id == other.transfer_stage_id

  true
end
```

---

## Part 2: Seed Data and Rake Tasks

### Step 9: Create Seed Data

#### Create seed file

Create a new seed file in `db/seeds/`:

```ruby
require Rails.root.join('db', 'seeds', 'schemas', 'add_agfs_fee_scheme_17')

adder = Seeds::Schemas::AddAGFSFeeScheme17.new(pretend: false)
adder.up
```

This is a wrapper for the `Seeds::Schemas::AddAGFSFeeScheme17` class (see below) that will be used by `rails db:seed` to seed
a new database, for development, as well as by the rake task (see below) to update and existing database with the new fee scheme.
#### Create schema file

Create a schema file in `db/seeds/schemas/`. This class handles the creation and rollback of the new fee scheme:

```ruby
# db/seeds/schemas/add_agfs_fee_scheme_17.rb
module Seeds
  module Schemas
    class AddAGFSFeeScheme17
      attr_reader :pretend
        alias_method :pretending?, :pretend

        def initialize(pretend: false)
          @pretend = pretend
        end

        def status
          # Display the current state of the fee scheme
          # Check if the fee scheme exists and count associated offences and fee types
        end

        def up
          # Create the new fee scheme by:
          #   1. Creating the FeeScheme record with version 17
          #   2. Updating the previous scheme's end_date
          #   3. Associating offences with the new scheme (typically inherited from the previous scheme)
          #   4. Associating fee types with the new scheme via roles
          #   5. Creating any new offence or fee type records as required
        end

        def down
          # Roll back the fee scheme by:
          #   1. Removing associations between offences and the scheme
          #   2. Removing associations between fee types and the scheme
          #   3. Deleting any newly created offence or fee type records
          #   4. Removing the FeeScheme record
          #   5. Restoring the previous scheme's end_date to nil
        end

        private

        # Helper methods for status, up, and down operations
        # Example methods:
        #   - agfs_fee_scheme_16: finds the previous fee scheme
        #   - create_agfs_scheme_seventeen: creates the new fee scheme and updates the previous one
        #   - set_agfs_scheme_seventeen_offences: copies offences from the previous scheme and creates new ones
        #   - create_scheme_seventeen_fee_types: assigns fee types to the fee scheme and creates new ones
    end
  end
end
```

> [!TIP]
> Use existing schema classes in `db/seeds/schemas/` as templates. Recent examples include `AddAGFSFeeScheme16` and `AddLGFSFeeScheme11`, which demonstrate common patterns for scheme creation and rollback.

#### Update main seeds file

Update `db/seeds.rb` to include the new seed file:

```ruby
# db/seeds.rb
...
SEED_FILES = %w[
  case_types
  case_stages
  ...
  scheme_16
  scheme_17
]
...
```

> [!NOTE]
> These seed files are applied in order so it is important that the new file is added to the end of the list.

### Step 10: Create Rake Tasks

Create a rake file for the scheme migration. Use existing rake files (e.g., `lib/tasks/agfs_scheme_thirteen.rake`) as a template:

```ruby
# lib/tasks/agfs_scheme_seventeen.rake
namespace :agfs do
  namespace :scheme_17 do
    desc 'Display AGFS Scheme 17 status'
    task status: :environment do
      adder = Seeds::Schemas::AddAGFSFeeScheme17.new(pretend: false)
      puts adder.status
    end

    desc 'Seed AGFS Scheme 17'
    task seed: [:not_pretend] => :environment do |_task, args|
      # seed['true'] should seed, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will seed data for AGFS Fee Scheme 17. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      adder = Seeds::Schemas::AddAGFSFeeScheme17.new(pretend: pretend)
      adder.up
      ActiveRecord::Base.logger.level = log_level
    end

    desc 'Rollback AGFS Scheme 17'
    task :rollback, [:not_pretend] => :environment do |_task, args|
      # rollback['true'] should rollback, otherwise pretend
      args.with_defaults(not_pretend: 'false')
      not_pretend = !args.not_pretend.to_s.downcase.eql?('false')
      pretend = !not_pretend

      continue?('This will rollback data for AGFS Fee Scheme 17. Are you sure?') if not_pretend
      puts "#{pretend ? 'pretending' : 'working'}...".yellow

      log_level = ActiveRecord::Base.logger.level
      ActiveRecord::Base.logger.level = 1
      adder = Seeds::Schemas::AddLAFSFeeScheme17.new(pretend: pretend)
      adder.down
      ActiveRecord::Base.logger.level = log_level
    end
  end
end
```

---

## Part 3: Test Updates

### Step 11: Update Cucumber Hooks

Update `features/support/hooks.rb` to include the new seed file:

```ruby
# features/support/hooks.rb
Before('not @no-seed') do
  # ... existing code ...
  load "#{Rails.root}/db/seeds/scheme_16.rb"
  load "#{Rails.root}/db/seeds/agfs_scheme_cleaner.rb"
  load Rails.root.join('db/seeds/scheme_17.rb') # Add to seed new fee scheme
end
```

> [!NOTE]
> `"#{Rails.root}/db/seeds/scheme.rb"` and
> `Rails.root.join('db/seeds/scheme.rb')` are equivalent. The latter is now
> recommended.

### Step 12: Update factories and helpers

#### Offence factory

Update `spec/factories/offences.rb`:

```ruby
# spec/factories/offences.rb
FactoryBot.define do
  factory :offence do
    # ... existing code ...
    
    trait :with_fee_scheme_seventeen do
      offence_class { nil }
      offence_band
      after(:build) do |offence|
        offence.fee_schemes << (FeeScheme.agfs.where(version: 17).first || build(:fee_scheme, :agfs_seventeen))
      end
    end
  end
end
```

#### Fee scheme factory

Update `spec/factories/fee_scheme.rb`:

```ruby
# spec/factories/fee_scheme.rb
FactoryBot.define do
  factory :fee_scheme do
    # ... existing code ...
    
    # Update previous scheme trait with end date
    trait :agfs_sixteen do
      name { 'AGFS' }
      version { 16 }
      start_date { Settings.agfs_scheme_16_start_date }
      end_date { Settings.agfs_scheme_17_start_date - 1.day }
    end
    
    # Add new scheme trait
    trait :agfs_seventeen do
      name { 'AGFS' }
      version { 17 }
      start_date { Settings.agfs_scheme_17_start_date }
      end_date { nil }
    end
  end
end
```

#### Base claims factory

Update `spec/factories/claim/base_claims.rb`:

```ruby
# spec/factories/claim/base_claims.rb
   transient do
      # ... existing code ...
      create_defendant_and_rep_order_for_scheme_17 { false }
    end
    after(:create) do |claim, evaluator|
      if evaluator.create_defendant_and_rep_order_for_scheme_17
        add_defendant_and_reporder(claim, scheme_date_for('scheme 17'))
      elsif # ... existing code ...
      end
    end
```

#### Advocate claim traits

Update `spec/factories/claim/shared/advocate_claim_traits.rb`:

```ruby
# spec/factories/claim/shared/advocate_claim_traits.rb
trait :agfs_scheme_17 do
  after(:create) do |claim|
    claim.defendants.each do |defendant|
      defendant
        .representation_orders
        .update_all(representation_order_date: Settings.agfs_scheme_17_start_date)
    end
  end
end
```

For LGFS fee schemes, `spec/factories/claim/litigator_claims.rb` should be updated instead.

#### API claims factory

Update `spec/factories/claim/api_claims.rb`:

```ruby
# spec/factories/claim/api_claims.rb
trait :with_scheme_seventeen_offence do
  advocate_category { 'KC' }
  offence { association(:offence, :with_fee_scheme_seventeen) }
end
```

### Step 13: Update Support Helpers

#### Scheme date helpers

Update `spec/support/scheme_date_helpers.rb`:

```ruby
# spec/support/scheme_date_helpers.rb
module SchemeDateHelpers
  # ... existing code ...
  
  def scheme_date_mappings
    {
      'scheme 17' => Settings.agfs_scheme_17_start_date.strftime,
      # Existing dates
    }
  end
  
  def main_hearing_date_mappings
    {
      'scheme 17' => Settings.agfs_scheme_17_start_date.strftime,
      # Existing dates
    }
  end
end
```

#### Seed helpers

Update `spec/support/seed_helpers.rb`:

```ruby
# spec/support/seed_helpers.rb
module SeedHelpers
  def self.seed_fee_schemes
    # ... existing schemes ...
    
    # Update previous scheme with end date
    FeeScheme.find_or_create_by!(name: 'AGFS', version: 16) do |fs|
      fs.start_date = Settings.agfs_scheme_16_start_date
      fs.end_date = Settings.agfs_scheme_17_start_date - 1.day
    end
    
    # Create new scheme
    FeeScheme.find_or_create_by!(name: 'AGFS', version: 17) do |fs|
      fs.start_date = Settings.agfs_scheme_17_start_date
      fs.end_date = nil
    end
  end
end
```

> [!NOTE]
> Previous `find_or_create_by` lines pass all attributes as arguments while the
> examples given above use a block to achive the same effect.

### Step 14: Update Spec Files

#### Fee scheme factory spec

Update the files in `spec/models/fee_scheme_factory`.

The fee scheme factory finds the correct fee scheme based on the representation
order and main hearing date. The main hearing date was introduced specifically
for AGFS fee scheme 13 and LGFS fee scheme 10 which applied to earlier
representation order dates depending on this main hearing date. It was not used
again in subsequent fee schemes and this is reflected in the spec files. 

In the AGFS tests there are shared examples for fee schemes 9 to 11 and a separate 
set of shared examples for fee schemes 12 onwards. This is to accommodate the
special case of fee schemes 12 and 13. In the LGFS tests there are shared examples
for fee schemes 9 and 10 which accommodate this special case, and a separate set
of shared examples for fee schemes 11 onwards for fee schemes where the main 
hearing date is not relevant.

#### Base fee type spec

Update `spec/models/fee/base_fee_type_spec.rb`.

Tests included in this spec:

* An instace of a fee type class should respond to `agfs_scheme_17?` for the new fee scheme
* The fee type classes should respond to `agfs_scheme_17s`
* The new method `agfs_scheme_17s` should return all fee types related to the new fee scheme

#### Fetch eligible advocate categories spec

Update `spec/services/claims/fetch_eligible_advocate_categories_spec.rb`:

```ruby
# spec/services/claims/fetch_eligible_advocate_categories_spec.rb
RSpec.describe Claims::FetchEligibleAdvocateCategories do
  # ... existing code ...
  
  context 'with AGFS scheme 17 claim' do
    let(:claim) { create(:advocate_claim, :agfs_scheme_17) }
    
    it 'returns correct categories' do
      # Test appropriate categories for scheme 17
    end
  end
end
```

#### Offence spec

Update `spec/models/offence_spec.rb`.

Add details of the new fee scheme to the `'can be queried by fee scheme types'` spec:

```ruby
# spec/models/offence_spec.rb
  expect(described_class).to \
    respond_to(
      # ... existing code ..
      :in_scheme_16,
      :in_scheme_sixteen,
      :in_scheme_17,
      :in_scheme_seventeen
    )
```

Add a new set of tests for the new fee scheme, replicating what exists for the previous scheme:

```ruby
# spec/models/offence_spec.rb
  describe '#scheme_seventeen?' do
    subject { offence.scheme_seventeen? }

    # Appropriate contexts for scheme 17
  end
```

#### TransferBrain::DataItem spec

Update `spec/models/claim/transfer_brain/data_item_spec.rb` if changes have been made to the `TransferBrain::DataItem` class for LGFS transfer claims.

#### Fee scheme usage specs

Update `spec/services/stats/fee_scheme_usage_generator_spec.rb` and `spec/services/stats/graphs/six_month_period_spec.rb`
to include the new fee scheme in specs that test the visualisation of fee scheme usage.

A test in `spec/requests/super_admins/stats_request_spec.rb` will fail if the number of fee schemes is greater than or equal 
to the number of colours defined for use by the ChartKick library. If this occurs, it can fixed by adding additional colours
to the `@chart_colours` variable in `app/controllers/super_admins/stats_controller.rb`.

### Step 15: Create Feature Tests

Create new feature tests in `features/claims/advocate/` (or `features/claims/litigator/`).
These can be copied from the previous fee scheme and modified. 

These tests assert that the fee values returned from Fee Calculator are correct. To test
this. It will be necessary to initially run these tests using the `FEE_CALC_VCR_MODE=new_episodes`
prefix to record new VCR cassettes. If fee values are being changed in the new fee scheme
then the tests should be run against a Fee Calculator instance which has had the correspinding
changes implemented.


### Step 16: Update API release notes

Update `app/views/pages/api_release_notes.html.haml` to provide details of the new fee scheme to
software vendors who maintain case management systems that integrate with the CCCD API and may need 
to make changes to their software.

### Step 17: Enable manual testing

Manual testing will need to be carried out before the start date of the new fee scheme. CCCD does 
not allow the creation of claims with dates in the future. To facilitate this testing, the 
`ALLOW_FUTURE_DATES` flag can be set to `true` in the `app-config.yaml` file for the appropriate
environment.

This is enabled by default in the `dev-lgfs` and `api-sandbox` environments. It should never be enabled
in the `production` environment.

---

## Deployment

### Pre-Deployment Checklist

Before deploying to production, verify:

- [ ] Start date added to `config/settings.yml`
- [ ] Fee types CSV updated with new role column
- [ ] ROLES constant updated in `app/models/fee/base_fee_type.rb`
- [ ] API dropdown data updated
- [ ] Fee scheme model updated with query method
- [ ] Fee scheme factory updated with new scheme logic
- [ ] Offence model updated with scope and query method
- [ ] Claim delegation added
- [ ] Eligibility services updated
- [ ] TransferBrain logic updated
- [ ] Seed data created
- [ ] Rake tasks created and tested locally
- [ ] All factory traits created
- [ ] Unit tests passing
- [ ] Feature tests passing
- [ ] Rake task tested in staging environment
- [ ] API release notes updated

### Running the Migration

To deploy a new fee scheme:

```bash
# Check current status
bundle exec rake agfs:scheme_17:status

# Run the seed task
bundle exec rake agfs:scheme_17:seed

# Verify the result
bundle exec rake agfs:scheme_17:status
```

### Rollback Procedure

If something goes wrong:

```bash
# Rollback the new scheme
bundle exec rake agfs:scheme_17:rollback

# Verify rollback
bundle exec rake agfs:scheme_17:status
```

---

## Troubleshooting

### Common Issues

#### Fee types not appearing for new scheme

- Check that the role has been added to `lib/assets/data/fee_types.csv`
- Verify the ROLES constant in `app/models/fee/base_fee_type.rb` includes the new scheme
- Re-run the fee types seeder if necessary

#### Wrong scheme being selected

- Check the date comparisons in the fee scheme factory
- Verify Settings values are correctly configured
- Check that main hearing date logic is correct (used for schemes LGFS 10+/AGFS 13+)

#### Offences not associated with new scheme

- Verify the seed task ran successfully
- Check the `offences_fee_schemes` join table
- Re-run the offence association part of the seed task

#### Tests failing due to missing scheme

- Ensure `spec/support/seeds_helpers.rb` creates the new scheme
- Check that factory traits are correctly defined
- Verify Cucumber hooks load the new seed file

---

## Related Documentation

- [Fee Schemes](fee_schemes.md) - Basic fee scheme documentation

## Reference Files

Key files involved in fee scheme creation:

| Category | File Path |
|----------|-----------|
| Settings | `config/settings.yml` |
| Fee Types Data | `lib/assets/data/fee_types.csv` |
| Base Fee Type | `app/models/fee/base_fee_type.rb` |
| Fee Scheme Model | `app/models/fee_scheme.rb` |
| AGFS Factory | `app/models/fee_scheme_factory/agfs.rb` |
| LGFS Factory | `app/models/fee_scheme_factory/lgfs.rb` |
| Offence Model | `app/models/offence.rb` |
| Base Claim | `app/models/claim/base_claim.rb` |
| Eligibility Service | `app/services/claims/fetch_eligible_misc_fee_types.rb` |
| API Dropdown | `app/interfaces/api/v1/dropdown_data.rb` |
| Seeds | `db/seeds.rb`, `db/seeds/scheme_##.rb` |
| Rake Tasks | `lib/tasks/*_scheme_*.rake` |