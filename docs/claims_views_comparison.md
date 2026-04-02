# Claims views comparison

Files under `app/views/external_users/advocates/<bill_type>/`.

| File | `claims` | `hardship_claims` | `interim_claims` | `supplementary_claims` | `permission_claims` |
|------|:--------:|:-----------------:|:----------------:|:----------------------:|:-------------------:|
| `new.html.haml` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `edit.html.haml` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `_basic_fees_form_step.html.haml` | ✅ | ✅ | ❌ | ❌ | ✅ |
| `_case_details_form_step.html.haml` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `_defendants_form_step.html.haml` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `_fixed_fees_form_step.html.haml` | ✅ | ❌ | ❌ | ❌ | ❌ |
| `_interim_fees_form_step.html.haml` | ❌ | ❌ | ✅ | ❌ | ❌ |
| `_miscellaneous_fees_form_step.html.haml` | ✅ | ✅ | ❌ | ✅ | ✅ |
| `_offence_details_form_step.html.haml` | ✅ | ✅ | ✅ | ❌ | ✅ |
| `_supporting_evidence_form_step.html.haml` | ✅ | ✅ | ✅ | ✅ | ✅ |
| `_travel_expenses_form_step.html.haml` | ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Content differences relative to `claims`

`claims` is used as the baseline. A cell is blank where the file is identical to `claims`, or where the file does not exist.

| File | `hardship_claims` | `interim_claims` | `supplementary_claims` | `permission_claims` |
|------|-------------------|-----------------|------------------------|---------------------|
| `new.html.haml` | Identical | Identical | Identical | Identical |
| `edit.html.haml` | Identical | Identical | Identical | Identical |
| `_basic_fees_form_step.html.haml` | `locale_scope` uses `hardship_claims` namespace; passes `fees_calculator_html: nil` to `fees_shared_header` | — | — | `locale_scope` uses `permission_claims` namespace; passes `fees_calculator_html: nil` to `fees_shared_header` |
| `_case_details_form_step.html.haml` | Identical | Identical | Identical | Identical |
| `_defendants_form_step.html.haml` | Identical | Identical | Identical | Identical |
| `_fixed_fees_form_step.html.haml` | — | — | — | — |
| `_interim_fees_form_step.html.haml` | — | Unique to `interim_claims`; renders `advocate_category` and `warrant_fee/fields` (no basic fees) | — | — |
| `_miscellaneous_fees_form_step.html.haml` | Passes `''` as third arg to `fee_shared_headings`; omits `interim_claim_info/fields` | — | Adds `advocate_category` partial; renders `misc_fees/advocates/supplementary/fields` instead of `misc_fees/advocates/fields` | Passes `''` as third arg to `fee_shared_headings`; omits `interim_claim_info/fields` (same as `hardship_claims`) |
| `_offence_details_form_step.html.haml` | Identical | Identical | — | Identical |
| `_supporting_evidence_form_step.html.haml` | Identical | Identical | Identical | Identical |
| `_travel_expenses_form_step.html.haml` | Identical | Identical | Identical | Identical |
