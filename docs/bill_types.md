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

## Further Steps

Subsequent steps to complete the full bill type journey will be documented
here as they are implemented.