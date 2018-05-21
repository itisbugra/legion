defmodule Legion.Messaging.Templatization do
  @moduledoc """
  Functions for templatization of parametric messages.

  A message can be parametrized using a supported templating language (i.e. *Liquid*).
  Parameterized messages can be sent to multiple platform users, with variadic subjects and bodies.
  Recipients of a templated message are enumerated over the message subject and body.
  The parameters for a certain user are injected during sending a message.

  Templatized messages can be sent using any messaging medium, same rules available for messaging
  apply for the templatized messages.

  ## Creating a message template

  Assume that we want to create an email template to send a terms of conditions change notification
  to the users.

      subject_template = \"\"\"
        Changes in Terms of Conditions by {{ date }}
      \"\"\"

      body_template = \"\"\"
        <!doctype html>
        <html>
          <head>
            <title>{{ subject }}</title>
          </head>
          <body>
            <h6>Dear, {{ recipient.name }}</h6>
            <p>Our Terms of Conditions are changed.</p>
          </body>
        </html>
      \"\"\"

      {:ok, template} = template_from_string owner, "toc change", subject_template, body_template, mediums: [:mailing]

      recipient_ids = [1, 5, 7]

      {:ok, result} = send_mail(recipient_ids, template)

  Here, we are creating two template strings using *Liquid* templating language.
  The subject template uses the `data` attribute; which is a localized, human readable date format (i.e. `January 5, 2017`).
  The body template uses the subject attribute, which is the evaluated result of subject template.
  Finally, we define the available push methods for this particular template, here it is available for
  *mailing* medium.
  """
end
