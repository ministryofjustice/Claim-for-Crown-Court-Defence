# Fee Schemes Overview

This document provides an overview of how fee schemes, offences, and fee types interact within the application.

## Core Components

### Fee Schemes (`app/models/fee_scheme.rb`)

Fee schemes define the billing framework for cases. They determine which fee types are available and how fees are calculated based on the case type and date. Fee schemes act as the central coordinator that links offences to their applicable fee types.

### Offences (`app/models/offence.rb`)

Offences represent the criminal charges associated with a case. Each offence has:
- An offence class (e.g., Class A, B, C, etc.) or an offence band (e.g., Band 1.3, 2.2, 17.1, etc.)
- An association with one or more fee schemes based on the offence date and category

### Fee Types (`app/models/fee/base_fee_type.rb`)

Fee types are classes inherited from `Fee::BaseFeeType` that define specific billable items. Different fee types may include:

- Basic fees
- Fixed fees
- Graduated fees
- Miscellaneous fees
- Travel and waiting fees

Each fee type is registered to specific fee schemes, determining when it's available for claims.

## Relationships

### Offence → Fee Scheme

- Offences are mapped to fee schemes based on their **offence class/band** and the **representation order date**
- Each fee scheme understands a specific set of offence classes or bands
- Different fee schemes apply to different time periods based on non-overlapping date ranges (separate ranges for LGFS and AGFS)
- The offence class determines the fee calculation band within a scheme
- Each fee scheme understands a specific set of offence classes or bands
- Different fee schemes apply to different time periods (e.g., Scheme 9, Scheme 10, etc.)
- The offence class determines the fee calculation band within a scheme

### Offence Versioning Across Fee Schemes

When a new fee scheme is created, it typically inherits its set of offences from the previous scheme, with the following behaviors:

- **Unchanged offences**: The same `Offence` model records are associated with both the old and new fee schemes
- **Modified offences**: When offence attributes change (such as banding or classification), new `Offence` model records are created and associated with the new fee scheme
- **Added/removed offences**: The new scheme's offence set reflects any additions or removals from the previous scheme

This approach maintains continuity between fee scheme versions while allowing offence-level changes to be captured through new record creation when necessary.

#### Specific examples

| Fee Scheme | Date Range | Details |
|---|---|---|
| AGFS 9  | up to 31/03/18 | 391 offences grouped into 11 offence classes (A to K). |
| AGFS 10 | 01/04/18 to 30/12/18 | Offences grouped into 17 categories with multiple offence bands. 1299 new `Offence` model records created (distinct from AGFS 9). |
| AGFS 11 | 31/12/18 to 16/09/20 | Some band 17.1 offences re-banded and two removed. 1253 `Offence` records shared with AGFS 10 and 44 new records created. |
| AGFS 12 | 17/09/20 to 29/09/22 | Offence banding unchanged. 1297 `Offence` records shared with AGFS 11. |

Subsequent AGFS fee schemes continue to use the same offence records as AGFS 12, with no further changes to offence banding.

All LGFS fee schemes use the same offence classes as AGFS 9 (classes A to K).

#### Adding offences to new fee schemes

When a new fee scheme shares offences with the previous scheme, the offence associations can be copied using:

```ruby
previous_fee_scheme_offences.each do |offence|
  offence.fee_schemes << new_fee_scheme
end
```

This approach is demonstrated in `db/seeds/schemas/add_agfs_fee_scheme_16.rb` within the `set_agfs_scheme_sixteen_offences` method.
When creating a new fee scheme with changes to offence classes or bands, the offence associations should be reviewed and updated accordingly to ensure the new scheme accurately reflects any modifications to offence classifications. In such cases, the code snippet above needs to be modified to create new `Offence` records for changed classifications rather than simply copying associations from the previous scheme.

### Fee Scheme → Fee Types

- Each fee scheme has a defined set of **allowed fee types**
- The mapping between fee schemes and their applicable fee types is defined in `lib/assets/data/fee_types.csv` via the `roles` column
- A fee type may be available in multiple schemes
- The scheme determines which fees are claimable

The `lib/assets/data/fee_types.csv` file lists all available fee types across all fee schemes. Each fee type's availability is controlled by the `roles` column, which contains a semicolon-delimited list of roles as defined by the `ROLES` constant in the `Fee::BaseFeeType` class.

#### Adding fee types to new fee schemes

To add fee types to a new fee scheme:

1. Add the new role to the `ROLES` constant in `app/models/fee/base_fee_type.rb`
2. Update `lib/assets/data/fee_types.csv` with the new role for each relevant fee type
3. When fee types are unchanged from the previous scheme, search for the previous scheme's role and append the new role to the list
4. Add any new fee types to the end of the list as appropriate

The `Seeds::FeeType::CsvSeeder` class applies changes from `lib/assets/data/fee_types.csv`. This approach is demonstrated in `db/seeds/schemas/add_agfs_fee_scheme_16.rb` within the `create_scheme_sixteen_fee_types` method.

## Summary

This application uses a three-tier model to manage legal fee claims:

1. **Fee Schemes** serve as the central framework, defining billing rules for specific time periods
2. **Offences** are mapped to fee schemes based on their class/band and representation order date
3. **Fee Types** define the specific billable items available within each scheme

When implementing a new fee scheme:
- Reuse existing `Offence` records where classifications remain unchanged
- Create new `Offence` records only when banding or classification changes
- Update the `roles` column in `lib/assets/data/fee_types.csv` to associate fee types with the new scheme
- Use the seeding classes (`Seeds::FeeType::CsvSeeder`) to apply changes

This design allows the application to handle evolving billing requirements while maintaining historical accuracy for claims from different time periods.

