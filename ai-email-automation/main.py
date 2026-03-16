"""AI Email Automation starter entry point."""

import email_reader
import ai_processor
import email_sender


def main():
    """Main entry point for AI email automation."""
    print("AI Email Automation Started")

    # Load mocked unread emails
    unread_emails = email_reader.get_unread_emails()
    print(f"Found {len(unread_emails)} unread email(s)")

    # Process each message with placeholder AI functions
    for email in unread_emails:
        print("\n--- Processing email ---")
        print(f"From: {email['sender']}")
        print(f"Subject: {email['subject']}")

        category = ai_processor.classify_email(email["body"])
        summary = ai_processor.summarize_email(email["body"])
        reply = ai_processor.generate_reply(email["body"])

        print(f"Category: {category}")
        print(f"Summary: {summary}")

        # Send a placeholder reply
        email_sender.send_email_reply(
            to_email=email["sender"],
            subject=f"Re: {email['subject']}",
            body=reply,
        )


if __name__ == "__main__":
    main()
