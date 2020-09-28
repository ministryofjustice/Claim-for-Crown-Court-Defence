## VAT

The rules for when and when not to apply VAT are rather complex, so are summarised here:

### AGFS

The claim's external_user attribute is an ExternalUser with a role of 'advocate' and has a vat_registered attribute which governs whether or not VAT is applied to fees and expenses.

If true, VAT at the prevailing rate is automatically added to fees and expenses; if false, not VAT is added.

## LGFS

The claim's provider has an attribute 'vat_registered' which governs whether or not VAT is applied.  In this case, VAT is automatically applied to fees.

For both VAT registered and unregistered LGFS providers, a VAT amount field is provided for manual input of VAT