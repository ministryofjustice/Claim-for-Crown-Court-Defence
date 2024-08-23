# Offence Data Cleanup

Over time the offence data across various environments has diverged. Some tools have been created to facilitate reconciling this data.

## Offence Data

Offences in CCCD are stored in the `Offence` model. Each offence record has
either an `OffenceBand` or an `OffenceClass` depending on the fee scheme. Each
`OffenceBand` has an `OffenceCategory`.

## `offences:extract` Rake task

The `offences:extract` Rake task fetches all the offences data in the four
models mentioned above and writes the data into four CSV files; `offence.csv`,
`band.csv`, `class.csv` and `category.csv`. A directory, specified by the
single argument to the task, is created to contain these files;

```bash
rails 'offences:extract[tmp/dumps]'
```

If the directory already exists then the Rake task will fail.

Running this on a pod in the production environment will create the files that
can later be used on other environment to check and update.

To copy the files from the production environment pod:

```bash
kubectl cp cccd-production/<pod>:tmp/dumps/offence.csv offence.csv
```

Then, to copy the files onto another environment pod:

```bash
kubectl cp offence.csv cccd-dev-lgfs/<pod>:tmp/dumps/offence.csv
```

## `offences:check` Rake task

The `offences:check` Rake tasks uses the CSV files created by
`offences:extract` to check the state of the tables in the current environment.

```bash
rails 'offences:check[tmp/dumps]'
```

This will display the number of records in the CSV file and the database table
for each model, indicating whether they are the same or not. It will then
display;

* How many records are in the CSV file that are not found in the database
* How many records in the CSV file can be found in the database but with a
  different id
* How many records are in the database that are not found in the CSV file

It will also create a file `output.txt` with details.

## `offences:fix_ids` Rake task

The `offences:fix_ids` Rake task attempts to fix the ids of the `Offence`
records in line with those in the `offences.csv` file created by the
`offences:extract` task. It is called as:

```bash
rails 'offences:fix_ids[tmp/dumps]'
```

The corrections are made in 4 stages;

1) The first stage works on the list of offences that are found in both the CSV
   file and the database but have different ids. In the database, the ids of
   these are changed to an id above the current highest id. These database
   records are stored for stage 4. Claims linked to these offences are updated
   accordingly.
2) The second stage works on the offences that exist in the database but not in
   the CSV file. These offences are removed.
3) The third stage works on the offences that exist in the CSV file but not in
   the database. These offences are created.
4) The offences that had their ids modified in the first stage are modified
   again to their correct value. Again, claims linked to these offences are
   updated accordingly.

The ids of offences are modified in two steps, in stages 1 and 4, to avoid
failures due to duplicate keys.

***Note:*** The above process is executed in a database transaction so any
errors will result in no modifications.

