## Account setter

### Description:

Utility class for bulk operations on **external** user accounts.

Specifically this was written for soft deleting, undoing a soft deletion and password resetting
of an external user account. NB: "soft deletion" is a mechanism to deactivate an
account by marking it as deleted without actually deleting it.

### Requirements:

The utility class is not autoloaded so it needs to be required befure use:

```ruby
require 'utils/account_setter'
```

### Usage:

```ruby
emails = ['user1@exaxmple.com', 'user2@exaxmple.com']
accounts = AccountSetter.new(emails)
accounts.report
accounts.soft_delete
accounts.un_soft_delete
accounts.change_password
```
