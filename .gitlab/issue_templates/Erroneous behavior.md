## Report

*Type the description for the issue, e.g.: The error occurs due to a programmer error found in the view declaration.*

### Module (or function) being affected

*Type the function or module name if available involved in the issue, e.g.:* `Legion.Identity.Telephony.PhoneNumber.FiniteStateMachine.primary?/1`

### Scenario

*You can implement the scenario with a pseudocode or anything to be reproduced by the engineer later. For example,*

With the following test stub,

```elixir
owner = Factory.insert(:user)
authority = Factory.insert(:user)

owner_passphrase = Factory.insert(:passphrase, user: owner)
authority_passphrase = Factory.insert(:passphrase, user: authority)
safe_and_prioritized = Factory.insert(:phone_number, user: owner)
Factory.insert(:phone_number_safety_trait, phone_number: safe_and_prioritized, authority: owner_passphrase)
Factory.insert(:phone_number_prioritization_trait, phone_number: safe_and_prioritized, authority: owner_passphrase)
```

### Recipe to reproduce

*You can implement a pseudocode or put an assertion here to reproduce the actual problem. Here is an example with an assertion,*

```elixir
assert primary? safe_and_prioritized.id   # fails to pass
```

### Possible reason

*If you're available to have a shot about the possible reason underneath the problem occurred, type it here like this,*

The assertion fails to pass since the owner of the prioritization is derived by using owner of the authority passphrase instead of phone number affected.

### Proposal

*If you have any kind of resolution about this situation, you might type it here. Something like this,*

The view declaration should be modified.