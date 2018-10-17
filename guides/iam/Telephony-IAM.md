# Telephony 

Telephony (not to be confused with *Core Telephony*) is one of the fundamental modules found in identity management subsystem. It allows the users to declare their phone numbers, which could be later used by the integration services (i.e. *PSDN*, *SMS*, application authentication pipelines). The comodule for this module providing validation and formatting services is `Telephony`.

This module is responsible for the following tasks:

- Managing phone numbers of the users found in the platform.
- Supplying a canonical phone number to an integration, which probably needs one phone number such task.

A phone number entry may consist of various attributes, including a name, type and the number itself. The name of the phone number is a human-readable label, which makes easy to refer and perform inquiries in the address book. Additionally, a phone number entry also carries a type, showing if it points to home, work or such device category. The number is also contained in an entry, being preformatted by the platform upon successful creation.

| User     | Name     | Type   | Phone Number     | Date Created     |
| -------- | -------- | ------ | ---------------- | ---------------- |
| Alice H. | iPhone   | *work* | +966 55 867 4052 | March 20th, 2018 |
| Alice H. | Landline | *work* | +966 54 812 2592 | April 22nd, 2018 |

<p id="phone-numbers-of-alice" style="text-align: center;">Table 1: Phone numbers of Alice H.</p>

The phone numbers can be prioritized to be the primary phone number in particular integrated features. To give an illustration, sign-in module might need for sending verification code over SMS to a platform user, the prioritization policies will be applied to select one between numbers of the user.

### Canonical selection

Users might have more than one phone number. In this case, the application performs *canonicalization* upon a few rules to decide the proper phone number. The canonicalization operation initially sorts the date of the phone number created, in descending order. The operation results with the heading phone number of the list, however, additional components might introduce various filters to the inquiry. For instance, when authentication module requests a phone number to send an authentication code over SMS, it adds a predicate that filters mobile phone numbers to narrow down the search results.

The date of the phone number created might not be solely adequate for all canonicalization purposes. Hence, the module provides a way to enforce canonicalization of a specific phone number manually, which is called *prioritization*. Phone number entries can be prioritized to be derived in canonicalization, since it overrides the ordering by timestamps.

#### Canonicalization process

The *canonicalization* process prioritizes *primed* entries, nevertheless the predicates prepared by the additional component remains active. The latest entry received a prioritization becomes the *primary* phone number of the user, which is the default phone number seen on user interfaces, showing identity information.

As shown in [table 1](#phone-numbers-of-alice), a user might have more than phone numbers. Initially, the module canonicalizes this phone number list to derive the second entry.

| Phone Number     | Date Created     | Prioritized    | Canonicalization Result |
| ---------------- | ---------------- | -------------- | ----------------------- |
| +966 55 867 4052 | March 20th, 2018 |                |                         |
| +966 54 812 2592 | April 22nd, 2018 | June 1st, 2018 | *is primary*            |

<p style="text-align: center;">Table 2: Prioritization operation affects canonicalization result directly</p>

### Safe guards

Phone numbers can be used in various scenarios, including authentication, information dispatch, or live support. During utilization of these services, it might require a need of a feedback mechanism to mark a phone number as unsafe in abnormal flows — fraud detection, misdial etc. where guards render as an internal blacklisting feature.

External services do not respect to unsafe phone numbers, unless it is explicitly stated. Phone numbers marked unsafe are not counted in canonicalization stage either, hence they will remain unusable (ignored) for most of the external services.

### Searching and inquiries

Phone numbers can be queried with numerous attributes, including country / area codes (and their names), call history, and additional metadata, if applicable.

### Formatting phone numbers

Phone numbers can be formatted in *E164* or human-readable formats, without being stored in the server.

To reduce the latency by shrinking the number of round trips, client applications should utilize their internal implementation for phone number formatting. They can also leverage the power of the information sources found in the client device, for instance, the contact list of the owner of the client device can be used to synchronize the phonebook (see Client Services).

Phone numbers, as parameters, expected by the platform does not have to be formatted. In general, client applications are expected to send phone numbers as formatted as *E164* to prevent misunderstandings and validation failures by the platform, since there are edge cases where such phone number can be parsed to more than a single result. The best practice for designing user interfaces for such kind of task could be illustrated, the client application may exhibit a selection box, which holds constrained number of entries to select the country code.

> There can be two phone numbers, which could be constituted by the same string of numbers, but inherently valid for one country, at most, at the same time.
>
> *+9 524 751 12* (a valid number for Australia)
> *+952 475 112* (an invalid number for Qatar)

## Managing phonebook entries

The phonebook can be managed through the platform interface, the entries found in phonebook are subject to several operations. The [figure 1](#phone-number-state-machine) represents the finite state machine of a phone number entry.

![phone_number_sm](/Users/chatatata-mbpr15/Development/OSS/Legion/guides/iam/svg/phone_number_sm.svg)

<p id="phone-number-state-machine" style="text-align: center;">Figure 1: State diagram for a phone number entry</p>

#### Creating and updating a phone number

Platform users can register phone numbers belonging to themselves or other platform users. The phone number is validated by the platform, upon successful validation, it is saved on the platform itself. Additionally, phone numbers can be updated later by the user.

> ##### Limitations
>
> The platform limits the number of active phone number entries belonging to a user, where the limit is configurable by the administrator on per-user basis. Users may contact their system administrators to increase their personal limits.

#### Marking a phone number safe

To be used by the integrated modules and external services of the platform, a phone number had better be marked as safe, since unsafe phone numbers will be ripped out upon canonicalization process. Initially, the phonebook entry is instantiated as safe, for a predetermined amount of time. After that time, if the safety mark is not extended by the user, it is counted as unsafe.

For more information about phone number safety, refer to the [**safe guards**](#safe-guards).

#### Prioritizing a phone number

Phonebook entries can be prioritized to be implied in future canonicalization results. The phone number needs to be safe to be prioritized at that time, when it is casted to be unsafe, the prioritization operation loses its effect.

#### Ignoring a phone number

Phonebook entries can be marked as ignored by the user. These phone numbers are implied by the users to be safe but to be not used in platform integrations.



In [table 3](#operation-state-compatibility-table), the compatibility of the operations with the state of the phone numbers are shown.

|                         | Safe | Primary | Safe and Ignored | Unsafe |
| ----------------------: | :--: | :-----: | :--------------: | :----: |
|      **Prioritization** | yes  | *no-op* |        no        |   no   |
|    **Safety Extension** | yes  |   yes   |       yes        |  yes   |
| **Safety Invalidation** | yes  |   no    |       yes        |   no   |
|          **Neglection** | yes  |   no    |     *no-op*      |  yes   |

<p id="operation-state-compatibility-table" style="text-align: center;">Table 3: Operation - state compatibility table</p>

## Communication preferences



