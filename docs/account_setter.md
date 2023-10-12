## Account setter

### Description:

Utility class for bulk operations on **external** user accounts.

Specifically this was written for soft deleting, undoing a soft deletion and password resetting of an external user account. It has since been extended
to include bulk disabling and enabling of users.

NB: "soft deletion" is a mechanism to deactivate an account by marking it as deleted without actually deleting it.

Disabling prevents login of a user but, unlike soft deletion, does not prevent
the user having claims submitted on their behalf via API submissions.

### Requirements:

The utility class is not autoloaded so it needs to be required before use:

```ruby
require 'utils/account_setter'
```

### Usage:

```ruby
emails = ['user1@exaxmple.com', 'user2@exaxmple.com']
accounts = Utils::AccountSetter.new(emails)
accounts.report
accounts.soft_delete
accounts.un_soft_delete
accounts.change_password
```
