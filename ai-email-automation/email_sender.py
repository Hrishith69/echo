"""Mock email sender for AI Email Automation."""


def send_email_reply(to_email, subject, body):
    """Prints a mock email send action."""
    print(f"Sending email to {to_email}")
    print(f"Subject: {subject}")
    print(f"Body: {body}")
