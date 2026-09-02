# OmniAuth / SILAS Handoff

## Scope

The Entra ID/SILAS callback is implemented in `app/controllers/omniauth_callbacks_controller.rb`. It supports existing users plus creation of case workers, external users, and super admins.

## Authentication flow

1. OmniAuth invokes `OmniauthCallbacksController#entra_id` or `#entra_mock`.
2. `handle_omniauth` retrieves `request.env['omniauth.auth']`.
3. `resolved_persona` selects the stored persona type for an existing email; otherwise it infers the persona from `LAA_ROLES`, then falls back to `raw['persona']`, then `CaseWorker`.
4. A user with an existing but different persona is rejected. Personas are not switched or recreated during login.
5. Existing case workers and external users can have their mapped roles updated from `LAA_ROLES`.

Errors during provisioning are returned through the normal authentication failure redirect. Detailed provisioning and persona-mismatch messages are only exposed in the Rails development environment.

## Role mappings

Mappings are constants near the top of the controller:

- Internal SILAS roles map to `case_worker`, `provider_management`, and `admin`.
- External SILAS roles map to `advocate`, `litigator`, and `admin`.
- `Super Administrator` maps to the `SuperAdmin` persona.

`LAA_ROLES` is trimmed but not lowercased before mapping. Mapping keys are therefore case-sensitive and must match the SILAS payload values exactly.

For a new external user, a non-empty `LAA_ROLES` payload must yield a valid external mapping and an allowed role for the provider. There is no raw-role or default-admin fallback.

## Supplier numbers

`LAA_ACCOUNTS` is normalized to uppercase and split by existing model regexes:

- AGFS: `ExternalUser::SUPPLIER_NUMBER_REGEX`
- LGFS: `SupplierNumber::SUPPLIER_NUMBER_REGEX`

LGFS supplier numbers belong to `SupplierNumber` records associated with a provider. When a new provider is created, all extracted LGFS values are constructed as nested `lgfs_supplier_numbers`, so they exist during `Provider` validation.

`ExternalUser#supplier_number` represents an AGFS number for an advocate in a chamber. It is only populated for a chamber user with the `advocate` role. It is nil for firm and LGFS-only external users.

## Provider resolution and creation

`find_or_create_provider_for_external_user` works as follows:

1. Require `FIRM_NAME` and find an existing provider by normalized name.
2. If no name match exists and automatic creation is disabled, raise `No provider found for FIRM_NAME: ...`.
3. If automatic creation is enabled, split `LAA_ACCOUNTS` into AGFS and LGFS values.
4. Reject if an AGFS value already exists on an `ExternalUser`.
5. Use the provider attached to the first matching LGFS `SupplierNumber`.
6. If no LGFS match exists, create a new provider and nested LGFS supplier numbers.

Firm-name normalization uppercases the name, changes `&` to `AND`, removes punctuation, collapses whitespace, and compares in Ruby. It is inexpensive per name, but the lookup currently scans providers with `Provider.find_each`; consider an indexed normalized provider-name column if the provider table becomes large.

## Provider creation flag

`AUTO_CREATE_PROVIDERS_FROM_SILAS` controls automatic provider creation:

- Default: `false`
- `true`: allow provider lookup by LGFS number or create a provider when no match exists
- `false`: do not create a provider; fail if `FIRM_NAME` cannot match an existing provider

## Temporary provider defaults

The SILAS payload does not currently provide these provider fields. The controller deliberately uses:

- `provider_type`: `firm`
- provider roles: `['lgfs']`
- `vat_registered`: `true`

These are isolated in `extract_provider_type`, `extract_provider_roles`, and `provider_vat_registered?` for replacement when SILAS supplies authoritative values.

## Entra mock

`lib/omniauth/strategies/entra_mock.rb` is a local/test-only OmniAuth strategy. It is registered in `config/initializers/omniauth.rb` only when `Rails.env.local?`, equivalent to development or test.

`User` also includes `entra_mock` in Devise `omniauth_providers` only in local environments. Hosted AWS environments run as Rails production, so `/users/auth/entra_mock` is intentionally unavailable there and will otherwise show Devise's authentication passthru response.

Mock inputs:

- `ENTRA_MOCK_JSON`: JSON payload for `raw_info`
- `ENTRA_MOCK_HTTP_STATUS`: simulate a non-200 mock provider response

## Relevant files

- `app/controllers/omniauth_callbacks_controller.rb`: persona routing, provisioning, supplier/provider logic
- `app/models/user.rb`: Devise OmniAuth provider list
- `app/models/external_user.rb`: external-user roles and AGFS supplier-number behavior
- `app/models/provider.rb`: provider roles and LGFS supplier-number validation
- `app/models/supplier_number.rb`: LGFS supplier-number model and regex
- `app/models/ability.rb`: external-admin access is restricted to the admin's provider
- `config/initializers/omniauth.rb`: Entra ID and local mock strategy registration
- `lib/omniauth/strategies/entra_mock.rb`: mock strategy implementation

## Validation completed

- `bin/setup` completed successfully on 2026-08-27.
- `bundle check` passed after cleaning stale duplicate `bootsnap` and `brakeman` entries from `Gemfile.lock`.
- `docker build --check --file docker/Dockerfile .` passed after changing Bundler group exclusion to `bundle config set --local without 'development test'`.
