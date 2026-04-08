# Adding New Bill Types

This document describes the steps required to add new bill types to the
Claim for Crown Court Defence application, based on the addition of the
`AdvocatePermissionClaim` (AGFS) and `LitigatorPermissionClaim` (LGFS) bill
types as a worked example.

---

## Step 1: Make the bill type visible on the 'Choose your bill type' page

This is the first step in adding a new bill type. At this stage the bill type
will appear on the opening page of the claim journey but none of the
subsequent functionality will work yet.

### 1. Create the model file

Create a new model class in `app/models/claim/` inheriting from `BaseClaim`.
The `route_key_name` determines the URL routing and must be unique.

For an AGFS (advocate) bill type:

```ruby
# app/models/claim/advocate_permission_claim.rb
module Claim
  class AdvocatePermissionClaim < BaseClaim
    route_key_name 'advocates_permission_claim'
  end
end
```

For an LGFS (litigator) bill type:

```ruby
# app/models/claim/litigator_permission_claim.rb
module Claim
  class LitigatorPermissionClaim < BaseClaim
    route_key_name 'litigators_permission_claim'
  end
end
```

### 2. Register the claim type on `ExternalUser`

Add the new claim class to the appropriate claim type list in
`app/models/external_user.rb`:

```ruby
def advocate_claim_types
  [
    Claim::AdvocateClaim,
    Claim::AdvocateInterimClaim,
    Claim::AdvocateSupplementaryClaim,
    Claim::AdvocateHardshipClaim,
    Claim::AdvocatePermissionClaim  # Add new AGFS type here
  ]
end

def litigator_claim_types
  [
    Claim::LitigatorClaim,
    Claim::InterimClaim,
    Claim::TransferClaim,
    Claim::LitigatorHardshipClaim,
    Claim::LitigatorPermissionClaim  # Add new LGFS type here
  ]
end
```

### 3. Register the claim type on `Provider`

Add the new claim class to the appropriate claim type list in
`app/models/provider.rb`:

```ruby
def agfs_claim_types
  [
    Claim::AdvocateClaim,
    Claim::AdvocateInterimClaim,
    Claim::AdvocateSupplementaryClaim,
    Claim::AdvocateHardshipClaim,
    Claim::AdvocatePermissionClaim  # Add new AGFS type here
  ]
end

def lgfs_claim_types
  [
    Claim::LitigatorClaim,
    Claim::InterimClaim,
    Claim::TransferClaim,
    Claim::LitigatorHardshipClaim,
    Claim::LitigatorPermissionClaim  # Add new LGFS type here
  ]
end
```

### 4. Add the context mapping

Add the new claim type to the context mapper in
`app/services/claims/context_mapper.rb`. The context key follows the
convention `agfs_<type>` or `lgfs_<type>`:

```ruby
'Claim::AdvocatePermissionClaim' => 'agfs_permission',
'Claim::LitigatorPermissionClaim' => 'lgfs_permission'
```

The full mapping block should look like:

```ruby
{
  'Claim::AdvocateClaim'              => 'agfs',
  'Claim::AdvocateInterimClaim'       => 'agfs_interim',
  'Claim::AdvocateSupplementaryClaim' => 'agfs_supplementary',
  'Claim::AdvocateHardshipClaim'      => 'agfs_hardship',
  'Claim::AdvocatePermissionClaim'    => 'agfs_permission',  # New
  'Claim::LitigatorClaim'             => 'lgfs_final',
  'Claim::InterimClaim'               => 'lgfs_interim',
  'Claim::TransferClaim'              => 'lgfs_transfer',
  'Claim::LitigatorHardshipClaim'     => 'lgfs_hardship',
  'Claim::LitigatorPermissionClaim'   => 'lgfs_permission'   # New
}[claim_type.to_s]
```

### 5. Add the locale strings

Add the display label for the radio button on the 'Choose your bill type'
page in `config/locales/en.yml`. The key follows the convention
`<context_key>_rb` (radio button):

```yaml
en:
  # ...
  external_users:
    claims:
      new:
        agfs_permission_rb: Advocate permission fee   # New AGFS label
        lgfs_permission_rb: Litigator permission fee  # New LGFS label
```

An optional hint key `<context_key>_hint` or `<context_key>_hint_html` can
also be added if further explanation is needed on the page:

```yaml
agfs_permission_hint: Some helpful hint text for the advocate permission fee
```

### 6. Add the context key to `ClaimType#valid_ids`

The `ClaimType` model in `app/models/claim_type.rb` maintains a hardcoded
allowlist of valid context keys. This is used to validate the form submission
on the 'Choose your bill type' page — selecting a context key not in this
list produces the error _"Choose a valid bill type"_. Add the new context
keys to `valid_ids`:

```ruby
# app/models/claim_type.rb
def self.valid_ids
  %w[agfs
     agfs_interim
     agfs_supplementary
     agfs_hardship
     agfs_permission     # New AGFS type
     lgfs_final
     lgfs_interim
     lgfs_transfer
     lgfs_hardship
     lgfs_permission].freeze  # New LGFS type
end
```

Also update the `valid_ids` list in the corresponding spec
`spec/models/claim_type_spec.rb` to match:

```ruby
let(:valid_ids) do
  %w[agfs
     agfs_interim
     agfs_supplementary
     agfs_hardship
     agfs_permission
     lgfs_final
     lgfs_interim
     lgfs_transfer
     lgfs_hardship
     lgfs_permission]
end
```

---

### 6. Update the test support shared context

The shared context in `spec/support/shared_examples_for_claim_types.rb`
defines the lists of claim types used across many specs. Add the new context
keys and class names to all three places:

```ruby
# spec/support/shared_examples_for_claim_types.rb

RSpec.shared_context 'claim-types helpers' do
  let(:agfs_claim_types) { %w[agfs agfs_interim agfs_supplementary agfs_hardship agfs_permission] }
  let(:lgfs_claim_types) { %w[lgfs_final lgfs_interim lgfs_transfer lgfs_hardship lgfs_permission] }
  let(:all_claim_types) { agfs_claim_types | lgfs_claim_types }
end

RSpec.shared_context 'claim-types object helpers' do
  let(:agfs_claim_object_types) do
    %w[Claim::AdvocateClaim Claim::AdvocateInterimClaim Claim::AdvocateSupplementaryClaim
       Claim::AdvocateHardshipClaim Claim::AdvocatePermissionClaim]
  end
  let(:lgfs_claim_object_types) do
    %w[Claim::LitigatorClaim Claim::InterimClaim Claim::TransferClaim
       Claim::LitigatorHardshipClaim Claim::LitigatorPermissionClaim]
  end
  # ...and the class-level methods accordingly
end
```

These shared contexts are included by the following specs (which will pick up
the new types automatically once the shared context is updated):

- `spec/services/claims/context_mapper_spec.rb`
- `spec/controllers/external_users/claim_types_controller_spec.rb`
- `spec/views/external_users/claim_types/new_spec.rb`

### 7. Update the claim types controller spec

Add the new context keys and their expected redirect paths to the
`claim_type_redirect_mappings` hash in
`spec/controllers/external_users/claim_types_controller_spec.rb`:

```ruby
def self.claim_type_redirect_mappings
  { # ...existing mappings...
    'agfs_permission' => '/advocates/permission_claims/new',
    'lgfs_permission' => '/litigators/permission_claims/new' }
end
```

> **Note**: these redirect paths will cause the test to fail at this stage
> because the routes do not exist yet. The tests should be added now and are
> expected to pass once routing is implemented in a later step.

### 8. Update the claim types view spec

Add the new radio button label text to the assertions in
`spec/views/external_users/claim_types/new_spec.rb`:

```ruby
# In the 'with all available_claim_types' context:
expect(response.body).to include('Advocate permission fee', 'Litigator permission fee')

# In the 'with agfs available_claim_types' context:
expect(response.body).to include('Advocate permission fee')
expect(response.body).not_to include('Litigator permission fee')

# In the 'with lgfs available_claim_types' context:
expect(response.body).to include('Litigator permission fee')
expect(response.body).not_to include('Advocate permission fee')
```

---

### Running the tests for Steps 1 and 6

The specs most directly affected by Steps 1 and 6 are:

| Spec file | What it tests |
|-----------|--------------|
| `spec/models/claim_type_spec.rb` | `ClaimType#valid_ids` allowlist |
| `spec/support/shared_examples_for_claim_types.rb` | Shared type arrays used by many specs |
| `spec/services/claims/context_mapper_spec.rb` | Context key mappings for each claim type |
| `spec/controllers/external_users/claim_types_controller_spec.rb` | Radio button selection and redirect behaviour |
| `spec/views/external_users/claim_types/new_spec.rb` | Label text rendered on the 'Choose your bill type' page |

Run them all together with:

```bash
bundle exec rspec \
  spec/models/claim_type_spec.rb \
  spec/services/claims/context_mapper_spec.rb \
  spec/controllers/external_users/claim_types_controller_spec.rb \
  spec/views/external_users/claim_types/new_spec.rb
```

#### Expected state after Steps 1 and 6

After completing Steps 1 and 6, running the above command should produce
**60 passing examples and 2 failures**. The two failing examples are:

```
ExternalUsers::ClaimTypesController POST #create with agfs_permission claim
  is expected to redirect to "/advocates/permission_claims/new"

ExternalUsers::ClaimTypesController POST #create with lgfs_permission claim
  is expected to redirect to "/litigators/permission_claims/new"
```

These failures are **expected at this stage**. They exist because the routes
for the new claim types have not yet been defined. They will be resolved in a
later step when routing and controllers are added.

All other examples should pass, confirming that:
- The new claim types appear in the `ExternalUser` and `Provider` type lists
- The context mapper correctly maps the new class names to their context keys
- The 'Choose your bill type' page renders the new radio button labels
- The view correctly shows or hides labels based on the user's scheme

---

## Checklist for Steps 1 and 6

### Application code
- [ ] Create `app/models/claim/<type>_claim.rb` with a unique `route_key_name`
- [ ] Add the class to `ExternalUser#advocate_claim_types` or `ExternalUser#litigator_claim_types`
- [ ] Add the class to `Provider#agfs_claim_types` or `Provider#lgfs_claim_types`
- [ ] Add the context mapping in `Claims::ContextMapper`
- [ ] Add `<context_key>_rb` locale string in `config/locales/en.yml`
- [ ] Add the new context keys to `ClaimType#valid_ids` in `app/models/claim_type.rb`
- [ ] Verify the bill type appears on the 'Choose your bill type' page

### Tests
- [ ] Update `valid_ids` list in `spec/models/claim_type_spec.rb`
- [ ] Add new context keys to `agfs_claim_types` / `lgfs_claim_types` in `spec/support/shared_examples_for_claim_types.rb`
- [ ] Add new class names to `agfs_claim_object_types` / `lgfs_claim_object_types` in `spec/support/shared_examples_for_claim_types.rb`
- [ ] Add redirect mappings to `claim_type_redirect_mappings` in `spec/controllers/external_users/claim_types_controller_spec.rb`
- [ ] Add new label assertions to `spec/views/external_users/claim_types/new_spec.rb`

---

## Step 2: Set up the claim form journey

This step wires up the multi-step claim form for the new bill types. After
this step a user can navigate through all the form steps for the new bill
type, although the form may not yet validate or persist correctly.

### 1. Add `SUBMISSION_STAGES` to the model

`SUBMISSION_STAGES` defines the ordered sequence of form steps and the
transitions between them. It is read by `BaseClaim#submission_stages` to
drive navigation. Add it to both model files:

```ruby
# app/models/claim/advocate_permission_claim.rb
SUBMISSION_STAGES = [
  {
    name: :case_details,
    transitions: [{ to_stage: :defendants }]
  },
  {
    name: :defendants,
    transitions: [{ to_stage: :miscellaneous_fees }],
    dependencies: %i[case_details]
  },
  {
    name: :miscellaneous_fees,
    transitions: [{ to_stage: :expenses }],
    dependencies: %i[defendants]
  }
].freeze
```

```ruby
# app/models/claim/litigator_permission_claim.rb
SUBMISSION_STAGES = [
  {
    name: :case_details,
    transitions: [{ to_stage: :defendants }]
  },
  {
    name: :defendants,
    transitions: [{ to_stage: :miscellaneous_fees }],
    dependencies: %i[case_details]
  },
  {
    name: :miscellaneous_fees,
    transitions: [{ to_stage: :expenses }],
    dependencies: %i[defendants]
  }
].freeze
```

> **Note**: the `SUBMISSION_STAGES` currently defined for both models ends at
> `miscellaneous_fees → expenses` but does not include `expenses` as a named
> stage with its own transitions. Compare with `AdvocateHardshipClaim` which
> continues through `expenses`, `offence_details`, and
> `supporting_evidence`. The stages will need to be extended as the form
> journey is fleshed out.

### 2. Override `requires_case_type?`

`BaseClaim#requires_case_type?` returns `true` by default, meaning the claim
validation expects a `case_type` to be present. Permission hearings do not
use case types, so both models override this to return `false`:

```ruby
def requires_case_type? = false
```

This is the same pattern used by `AdvocateInterimClaim`, `AdvocateSupplementaryClaim`,
and `TransferClaim`.

### 4. Include `ProviderDelegation` (AGFS only)

AGFS claim models include the `ProviderDelegation` module, which handles the
difference between firms (where the supplier number lives on the `Provider`)
and chambers (where it lives on the `ExternalUser`). It provides:

- `provider_delegator` — returns the `Provider` or `ExternalUser` depending
  on the provider type
- `agfs_supplier_number` — returns the correct supplier number for the claim
- `set_supplier_number` — sets the claim's supplier number from the
  appropriate source

Add it to the AGFS model immediately after `route_key_name`:

```ruby
# app/models/claim/advocate_permission_claim.rb
include ProviderDelegation
```

All other AGFS claim models (`AdvocateClaim`, `AdvocateHardshipClaim`,
`AdvocateInterimClaim`, `AdvocateSupplementaryClaim`) include this module.
LGFS models do not — they use a different supplier number mechanism.

### 5. Set `fee_scheme_factory`

`BaseClaim#fee_scheme` calls `fee_scheme_factory` to determine which fee
scheme applies to the claim based on the representation order date. Each
claim type must point at the correct factory constant.

For AGFS claims:

```ruby
def fee_scheme_factory = FeeSchemeFactory::AGFS
```

For LGFS claims:

```ruby
def fee_scheme_factory = FeeSchemeFactory::LGFS
```

> **Note**: `LitigatorPermissionClaim` does not yet define
> `fee_scheme_factory`. This will need to be added.

### 6. Add routes
namespaces in `config/routes.rb`:

```ruby
scope module: 'external_users' do
  amend_actions = %i[new create edit update]
  namespace :advocates do
    # ...existing routes...
    resources :permission_claims, only: amend_actions
  end
  namespace :litigators do
    # ...existing routes...
    resources :permission_claims, only: amend_actions
  end
end
```

This generates the URL helpers used in the next step:
- `new_advocates_permission_claim_url`
- `new_litigators_permission_claim_url`

### 7. Add the redirect in `ClaimTypesController`

Add the two new context key → URL mappings to
`claim_type_redirect_url_for` in
`app/controllers/external_users/claim_types_controller.rb`:

```ruby
def claim_type_redirect_url_for(claim_type)
  {
    # ...existing mappings...
    'agfs_permission' => new_advocates_permission_claim_url,
    # ...
    'lgfs_permission' => new_litigators_permission_claim_url
  }[claim_type.to_s]
end
```

### 8. Create the controllers

Create a controller for each bill type, inheriting from
`ExternalUsers::ClaimsController`.

```ruby
# app/controllers/external_users/advocates/permission_claims_controller.rb
module ExternalUsers
  module Advocates
    class PermissionClaimsController < ExternalUsers::ClaimsController
      skip_load_and_authorize_resource

      resource_klass Claim::AdvocatePermissionClaim

      private

      def build_nested_resources
        %i[misc_fees expenses].each do |association|
          build_nested_resource(@claim, association)
        end

        super
      end
    end
  end
end
```

```ruby
# app/controllers/external_users/litigators/permission_claims_controller.rb
module ExternalUsers
  module Litigators
    class PermissionClaimsController < ExternalUsers::ClaimsController
      skip_load_and_authorize_resource

      resource_klass Claim::LitigatorPermissionClaim

      private

      def build_nested_resources
        %i[misc_fees disbursements expenses].each do |association|
          build_nested_resource(@claim, association)
        end

        super
      end
    end
  end
end
```

The difference in `build_nested_resources` reflects the difference in claim
type: the litigator controller also builds `disbursements`, which advocates
do not have.

### 9. Create the presenters

Presenters drive the claim summary page. Create one for each bill type.

```ruby
# app/presenters/claim/advocate_permission_claim_presenter.rb
class Claim::AdvocatePermissionClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :basic_fees_total

  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    basic_fees: :basic_fees,
    misc_fees: :miscellaneous_fees,
    expenses: :travel_expenses,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def pretty_type = 'AGFS Permission'
  def type_identifier = 'agfs_permission'
  def can_have_disbursements? = false
  def summary_sections = SUMMARY_SECTIONS

  def mandatory_case_details?
    claim.case_type && claim.court && claim.case_number && claim.external_user
  end

  # ...fee total helpers omitted for brevity
end
```

```ruby
# app/presenters/claim/litigator_permission_claim_presenter.rb
class Claim::LitigatorPermissionClaimPresenter < Claim::BaseClaimPresenter
  present_with_currency :permission_fees_total

  SUMMARY_SECTIONS = {
    case_details: :case_details,
    defendants: :defendants,
    offence_details: :offence_details,
    permission_fee: :permission_fees,
    misc_fees: :miscellaneous_fees,
    supporting_evidence: :supporting_evidence,
    additional_information: :supporting_evidence
  }.freeze

  def requires_trial_dates? = false
  def requires_retrial_dates? = false
  def pretty_type = 'LGFS Permission'
  def type_identifier = 'lgfs_permission'
  def summary_sections = SUMMARY_SECTIONS

  def mandatory_case_details?
    claim.case_type && claim.court && claim.case_number && claim.supplier_number
  end

  # ...fee total helpers omitted for brevity
end
```

> **Note**: `LitigatorPermissionClaimPresenter#SUMMARY_SECTIONS` references
> `:permission_fee` / `:permission_fees` — this implies a `permission_fee`
> association and fee total on the model that has not yet been defined.
> `AdvocatePermissionClaimPresenter` also references `:offence_details` and
> `:basic_fees` in `SUMMARY_SECTIONS` which may not match the
> `SUBMISSION_STAGES` defined in Step 2.1. Both presenters carry a comment
> noting they are copied from `AdvocateHardshipClaimPresenter` and will need
> further adjustment.

### 10. Create the views

#### AGFS: `app/views/external_users/advocates/permission_claims/`

Create `new.html.haml` and `edit.html.haml` — both are identical boilerplate
shared by all bill types:

```haml
= content_for :page_title, flush: true do
  = t('.page_title')

= render partial: 'external_users/claims/error_summary', locals: { ep: @error_presenter }

= render partial: 'layouts/header', locals: { page_heading: t('.page_heading') }

= render partial: 'external_users/claims/form_layout_wrapper', locals: { claim: @claim }
```

Then create a form step partial for each stage in `SUBMISSION_STAGES`. The
AGFS permission claim uses the same partials as `hardship_claims` with the
exception of `_basic_fees_form_step.html.haml` which uses the
`permission_claims`-specific locale namespace.

#### LGFS: `app/views/external_users/litigators/permission_claims/`

Create the same `new.html.haml` / `edit.html.haml` boilerplate.

The LGFS `_case_details_form_step.html.haml` differs from the AGFS version —
it includes a `govuk_inset_text` case stage warning and renders the
`supplier_number/fields` partial (required for litigator claims):

```haml
= govuk_inset_text(text: t('.case_stage_warning_html'))

%h2.govuk-heading-l
  = t('.page_heading')

= render partial: 'external_users/claims/api_promo_banner', locals: { claim: @claim }

= render partial: 'external_users/claims/supplier_number/fields', locals: { f: f }

= render partial: 'external_users/claims/case_details/fields', locals: { f: f }
```

The LGFS controller also has a `_hardship_fees_form_step.html.haml` which
renders `external_users/claims/hardship_fee/fields`. This appears to be
copied from the litigator hardship claim and will likely need renaming or
replacing.

### 11. Add locale strings for form steps

Add page title and heading strings for each form step under both
`external_users.advocates.permission_claims` and
`external_users.litigators.permission_claims` in `config/locales/en.yml`:

```yaml
advocates:
  permission_claims:
    new:
      page_title: &agfs_permission_claim_title Enter case details for advocate permission fees claim
      page_heading: &agfs_permission_claim_heading Claim for advocate permission fees
    edit:
      page_title: *agfs_permission_claim_title
      page_heading: *agfs_permission_claim_heading
    case_details_form_step:
      page_title: *agfs_permission_claim_title
      page_heading: Case details
    defendants_form_step:
      page_title: Enter defendant details for advocate permission fees claim
    # ...etc for each step

litigators:
  permission_claims:
    new:
      page_title: &lgfs_permission_claim_title Enter case details for litigator permission fees claim
      page_heading: &lgfs_permission_claim_heading Claim for litigator permission fees
    # ...etc
```

Also add claim summary page titles under `external_users.claims.show`:

```yaml
claims:
  show:
    agfs:
      advocate_permission_claim:
        page_title: View claim summary for advocate permission fees claim
        page_heading: Claim for advocate permission fees
    lgfs:
      litigator_permission_claim:
        page_title: View claim summary for litigator permission fees claim
        page_heading: Claim for litigator permission fees
```

---

## Checklist for Step 2

### Application code
- [ ] Add `SUBMISSION_STAGES` to `app/models/claim/advocate_permission_claim.rb`
- [ ] Add `SUBMISSION_STAGES` to `app/models/claim/litigator_permission_claim.rb`
- [ ] Override `requires_case_type?` to return `false` in both model files
- [ ] Add `include ProviderDelegation` to `app/models/claim/advocate_permission_claim.rb`
- [ ] Add `fee_scheme_factory = FeeSchemeFactory::AGFS` to `app/models/claim/advocate_permission_claim.rb`
- [ ] Add `fee_scheme_factory = FeeSchemeFactory::LGFS` to `app/models/claim/litigator_permission_claim.rb`
- [ ] Add `resources :permission_claims` to advocates namespace in `config/routes.rb`
- [ ] Add `resources :permission_claims` to litigators namespace in `config/routes.rb`
- [ ] Add `agfs_permission` and `lgfs_permission` redirect mappings to `ClaimTypesController#claim_type_redirect_url_for`
- [ ] Create `app/controllers/external_users/advocates/permission_claims_controller.rb`
- [ ] Create `app/controllers/external_users/litigators/permission_claims_controller.rb`
- [ ] Create `app/presenters/claim/advocate_permission_claim_presenter.rb`
- [ ] Create `app/presenters/claim/litigator_permission_claim_presenter.rb`
- [ ] Create AGFS views under `app/views/external_users/advocates/permission_claims/`
- [ ] Create LGFS views under `app/views/external_users/litigators/permission_claims/`
- [ ] Add form step locale strings for AGFS permission claim to `config/locales/en.yml`
- [ ] Add form step locale strings for LGFS permission claim to `config/locales/en.yml`

### Tests
- [ ] Controller spec for `ExternalUsers::Advocates::PermissionClaimsController`
- [ ] Controller spec for `ExternalUsers::Litigators::PermissionClaimsController`
- [ ] Presenter spec for `Claim::AdvocatePermissionClaimPresenter`
- [ ] Presenter spec for `Claim::LitigatorPermissionClaimPresenter`
- [ ] Update `claim_type_redirect_mappings` in `spec/controllers/external_users/claim_types_controller_spec.rb` (both mappings should now pass)