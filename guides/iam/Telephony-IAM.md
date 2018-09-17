# Telephony 

Telephony (not to be confused with *Core Telephony*) is one of the fundamental modules found in identity management subsystem. It allows the users to declare their phone numbers, which could be later used by the integration services (i.e. *PSDN*, *SMS*, application authentication pipelines). The comodule for this module providing validation and formatting services is `Telephony`.

This module is responsible for the following tasks:

- Managing phone numbers of the users found in the platform.
- Supplying a canonical phone number to an integration, which probably needs one phone number such task.

## Phone Numbers

A phone number entry may consist of various attributes, including a name, type and the number itself. The name of the phone number is a human-readable label, which makes easy to refer and perform inquiries in the address book. Additionally, a phone number entry also carries a type, showing if it points to home, work or such device category. The number is also contained in an entry, being preformatted by the platform upon successful creation.

| User     | Name     | Type   | Phone Number     | Date Created     |
| -------- | -------- | ------ | ---------------- | ---------------- |
| Alice H. | iPhone   | *work* | +966 55 867 4052 | March 20th, 2018 |
| Alice H. | Landline | *work* | +966 54 812 2592 | April 22nd, 2018 |

<p id="phone-numbers-of-alice" style="text-align: center; font-style: oblique;">Table 1: Phone numbers of Alice H.</p>

The phone numbers can be prioritized to be the primary phone number in particular integrated features. To give an illustration, sign-in module might need for sending verification code over SMS to a platform user, the prioritization policies will be applied to select one between numbers of the user.

### Canonical Selection

Users might have more than one phone number. In this case, the application performs *canonicalization* upon a few rules to decide the proper phone number. The canonicalization operation initially sorts the date of the phone number created, in descending order. The operation results with the heading phone number of the list, however, additional components might introduce various filters to the inquiry. For instance, when authentication module requests a phone number to send an authentication code over SMS, it adds a predicate that filters mobile phone numbers to narrow the search.

The date of the phone number created might not be solely adequate for all canonicalization purposes. Hence, the module provides a way to enforce canonicalization of a specific phone number manually, which is called *prioritization*. Phone number entries can be prioritized to be derived in canonicalization, since it overrides the date ordering.

### Prioritization

The *canonicalization* process prioritizes *primed* entries, nevertheless the predicates prepared by the additional component remains active. The latest entry received a prioritization becomes the *primary* phone number of the user, which is the default phone number seen on user interfaces, showing identity information.

As shown in [table 1](#phone-numbers-of-alice), a user might have more than phone numbers. Initially, the module canonicalizes this phone number list to derive the second entry.

| Phone Number     | Date Created     | Prioritized    | Canonicalization Result |
| ---------------- | ---------------- | -------------- | ----------------------- |
| +966 55 867 4052 | March 20th, 2018 |                |                         |
| +966 54 812 2592 | April 22nd, 2018 | June 1st, 2018 | *is primary*            |

### Safe guards

Phone numbers can be used in various scenarios, including authentication, information spill, or live support. During utilization of these services, it might require a need of a feedback mechanism to mark a phone number as unsafe, in case of fraud detection, misdial etc. Phone numbers marked unsafe are not counted in canonicalization stage, hence they will remain unusable (ignored) for most of the external services (unless it is explicitly specified by the service).