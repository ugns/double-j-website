import json
import os
import re
import boto3

ses = boto3.client("ses")

RECIPIENT = os.environ["RECIPIENT_EMAIL"]
ALLOWED_ORIGIN = os.environ["ALLOWED_ORIGIN"]

EMAIL_RE = re.compile(r"^[^\s@]+@[^\s@]+\.[^\s@]+$")


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": ALLOWED_ORIGIN,
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
        },
        "body": json.dumps(body),
    }


def handler(event, context):
    method = event.get("requestContext", {}).get("http", {}).get("method", "")

    if method == "OPTIONS":
        return _response(200, {})

    if method != "POST":
        return _response(405, {"error": "Method not allowed"})

    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return _response(400, {"error": "Invalid JSON body"})

    name = (body.get("name") or "").strip()
    email = (body.get("email") or "").strip()
    phone = (body.get("phone") or "").strip()
    message = (body.get("message") or "").strip()

    if not name or len(name) > 100:
        return _response(400, {"error": "Name is required (max 100 characters)"})

    if not EMAIL_RE.match(email) or len(email) > 254:
        return _response(400, {"error": "A valid email address is required"})

    if not message or len(message) > 5000:
        return _response(400, {"error": "Message is required (max 5000 characters)"})

    if phone and len(phone) > 30:
        return _response(400, {"error": "Phone number is too long"})

    site_domain = os.environ.get("SITE_DOMAIN", "doublejpropertygroup.com")
    phone_line = f"Phone: {phone}\n" if phone else ""
    text_body = (
        f"New contact form submission from {site_domain}\n\n"
        f"Name: {name}\n"
        f"Email: {email}\n"
        f"{phone_line}"
        f"\nMessage:\n{message}\n"
    )

    ses.send_email(
        Source=RECIPIENT,
        Destination={"ToAddresses": [RECIPIENT]},
        Message={
            "Subject": {"Data": f"[Contact Form] Message from {name}", "Charset": "UTF-8"},
            "Body": {"Text": {"Data": text_body, "Charset": "UTF-8"}},
        },
        ReplyToAddresses=[email],
    )

    return _response(200, {"message": "Message sent successfully"})
