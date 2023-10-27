## Fee Schemes

Fee schemes are managed by the `FeeScheme` model and are defined by;

* **name**: Either `AGFS` or `LGFS`
* **version**: The scheme number
* **start_date**: Earliest representation order date
* **end_date**: Last representation order date, or `nil`

From LGFS fee scheme 10 and AGFS fee scheme 13 the main hearing date is used to
determine the scheme in addition to the representation order date. The correct
scheme is now found using a the fee scheme factory:

```ruby
FeeSchemeFactory::AGFS(
  representation_order_date: <date>,
  main_hearing_date: <date>
)
FeeSchemeFactory::LGFS(
  representation_order_date: <date>,
  main_hearing_date: <date>
)
```

### Creating a new fee scheme

Before creating a new fee scheme;

* The start date of the new fee scheme needs to be added to `config/settings.yml`.
* A new 'role' needs to be added to `lib/assets/data/fee_types.csv`.
* Update the list of roles seen in the API in `app/interfaces/api/v1/dropdown_data.rb`.
* Update the fee scheme factory to include the date range of the new scheme.
* Update `Claims::FetchEligibileMiscFeeTypes#agfs_scheme_scope`.
  * This will involve delegating the method `agfs_scheme_##?` (or lgfs) from `Claims::FetchEligibileMiscFeeTypes` to `:claim` (`Claim::BaseClaim`), and from there to `:fee_scheme` (`FeeScheme`) where the method will sit.
* Create a new `scheme_####?` method and a `in_scheme_##` scope in `app/models/offence.rb`
* Add the scheme to the `ROLES` constant in `app/models/base_fee_type.rb`
* Add the scheme to `db/seeds/seeds.rb` and create a new `scheme_##.rb` file in `db/seeds`


New fee schemes are created using a Rake task, such as can be found in
`lib/tasks/agfs_scheme_thirteen.rake`. This should include tasks for:

* Display the status
* Seed the new fee scheme
* Roll back

The 'seed' task should:

* Update the end date of the previous fee scheme in the database to the day
  before the start date of the new fee scheme.
* Create a new fee scheme in the database with the end date set to `nil`.
* Add the new fee scheme to the relevant fee types (this could also be done by
  updating `fee_types.csv` and reseeding).
* Assign offences to the new fee scheme, as appropriate. This has typically
  been done by copying all the offences from the previous fee scheme but it
  could also be done by adding the new new fee scheme to the offences of the
  previous fee scheme.


After creating the scheme, various bits of testing will need updating:


* In `features/support/hooks.rb` - Add the new `scheme_##.rb` file to `Before('not @no-seed') do`
* Create a new trait `with_fee_scheme_##` in `spec/factories/offences.rb`
* Create a new trait `agfs_scheme_##` in `factories/claim/shared/advocate_claim_traits.rb`
* Create a new trait `agfs_###` (of lgfs) in `spec/factories/fee_scheme.rb` and update the end_date attribute for the trait of the previous fee scheme
* Create a new trait `with_scheme_sixteen_offence` in `factories/claim/api_claims.rb`
* Create main hearing and scheme date mappings in `support/scheme_date_helpers.rb`
* `services/claims/fetch_eligible_advocate_categories_spec.rb`
* `models/fee/base_fee_type_spec.rb`
* `spec/support/seeds_helpers.rb`
* `spec/models/fee_scheme_factory.rb`
* `spec/models/fee_scheme_factory/agfs_spec.rb` or lgfs
  * For this one, if you are testing before the start-date of the fee scheme, you will need to temporarily modify the test to travel forwards in time.
* Create a new set of tests in `features/claims/advocate` (or litigator)
