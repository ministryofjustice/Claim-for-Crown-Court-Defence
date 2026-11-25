# AGFS Fee Scheme 18

Scheme 18 applies to representation orders dated on or after 1 November 2026.
The main-hearing date does not affect this boundary. Existing scheme 17 fees,
prices, offences and eligibility rules remain unchanged.

## New fees

| CCCD code | Calculator code | Fee | Junior alone / led junior | Leading junior | KC |
| --- | --- | --- | --- | --- | --- |
| MISHA | AGFS_SENT_ADD | Sentencing Hearing Additional Claim (Hourly Rates) | 48.02/hour | 68.94/hour | 91.11/hour |
| MIMSH | AGFS_MITIG | Hearing for Mitigation of Sentence | 166.00 | 266.00 | 400.00 |
| MIMSA | AGFS_MIT_ADD | Hearing for Mitigation of Sentence Additional Claim (Hourly Rates) | 48.02/hour | 68.94/hour | 91.11/hour |
| MIBAM | AGFS_BAIL_APP | Bail applications, mentions and other applications in appeal, committals for sentence and breach hearings | 118.00 | 176.00 | 234.00 |

Amounts are GBP excluding VAT. The four fees are independently selectable for
all case types on final and supplementary advocate claims. They can be combined
without additional fee-specific eligibility restrictions. Existing shared
calculation restrictions apply as they do for other miscellaneous fees.
Hourly and fixed fees follow the
existing quantity and rounding conventions; no new allowances or uplifts apply.

## Deployment

Deploy and load the Fee Calculator scheme 18 data before using the new CCCD fees.
Fresh CCCD databases include scheme 18 through `db:seed`. Upgrade existing CCCD
databases with the existing data-migration convention:

```sh
bundle exec rake 'db:agfs_scheme_eighteen:seed'
bundle exec rake 'db:agfs_scheme_eighteen:seed[true]'
bundle exec rake db:agfs_scheme_eighteen:status
```

The first command previews; the second requires typing `yes` at confirmation and applies the
transactional, repeatable upgrade. Scheme 17 ends on 31 October 2026 and all its
offences are also associated with scheme 18.

Rollback uses `db:agfs_scheme_eighteen:rollback[true]`. It restores scheme 17's
open-ended date, removes scheme 18 associations and roles, and deletes fee types
whose only role is scheme 18, following the scheme 17 rollback convention.
Type `yes` at the confirmation prompt: any other answer cancels the operation.
Roll back before users submit scheme 18 claims; the new fee types are removed,
and an old calculator cannot calculate these fees.

The new codes use the existing CCR miscellaneous-fee adapter for both calculator
lookup and export mappings, just like existing miscellaneous fees. The CCR
application itself is not updated; support for these codes in CCR remains later
work and must be in place before relying on their export to CCR.