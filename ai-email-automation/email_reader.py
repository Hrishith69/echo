"""Mock email reader for AI Email Automation."""


def get_unread_emails():
    """Return mocked unread emails list."""
    # In a real system, this would call an email API (e.g. Gmail API)
    return [
        {
            "id": "1",
            "sender": "customer@example.com",
            "subject": "Need help with my order",
            "body": "Hello, I need help with my recent purchase...",
        }
    ]
