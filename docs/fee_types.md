## Fee Types

### Seeding

Fee types are defined in the file `lib/assets/data/fee_types.csv` containing the following columns:

|Column|Description|
|---|---|
|Id|Unique id in the database|
|Description|Description of the fee displayed to the user|
|Code|The code of the fee|
|Unique code|A unique code, comprising a prefix based on the class (**BA**sic, **F**i**X**ed, **WA**rrant, **IN**terim, **TRANS**fer **HARDSHIP** or **MI**scellaneous) usually followed by the code|
|Max amount||
|Calculated||
|Class|The class of the fee; `Fee::BasicFeeType`, `Fee::FixedFeeType` or `Fee::MiscFeeType`|
|Roles|A semicolon delimited list of fee schemes (roles) to which the fee applies. The roles must be included in the `ROLES` constant in `Fee::BaseFeeType`|
|Parent Id||
|Quantity is decimal|Whether the quantity is an integer or a decimal|
|Position||

After amending the list of fees the database is updated with the task
`data:migrate:fee_types:reseed`. By default, this task will run in 'dry mode'
(i.e. will not make changes) and output to the screen. To perform the changes:

```bash
bundle exec rails 'data:migrate:fee_types:reseed[false]'
```

### Interface with other services

The unique code of a fee type, defined above, needs to be mapped for the
injection into CCR and CCLF, and for lookups with Fee Calculator. This is set
in `app/services/ccr/fee/misc_fee_adapter.rb`. Also see
`spec/services/ccr/fee/misc_fee_adapter_spec.rb` for tests.

### Miscellaneous

Any new fees added as miscellaneous fees will appear automatically in the
drop-down list on the relevant page for final and hardship claims. For
supplementary fee claims, however, the fee will only be available if it listed
in `AGFS_SUPPLEMENTARY_SHARED_TYPES` in `app/models/fee/misc_fee_type.rb`.