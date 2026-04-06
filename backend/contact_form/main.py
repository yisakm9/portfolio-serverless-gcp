"""
Contact Form Cloud Function — GCP Version
Architecture:
  HTTP Request → Cloud Function → Firestore + Resend Email

Resend replaces SendGrid (no phone verification required).
"""
import json
import uuid
import os
from datetime import datetime, timezone

import functions_framework
import requests as http_requests
from google.cloud import firestore
from google.cloud import secretmanager

# Initialize Firestore client
db = firestore.Client()

# Collection name
COLLECTION = "contact-messages"

# Resend API endpoint
RESEND_API_URL = "https://api.resend.com/emails"


def get_email_api_key():
    """Fetch email API key from Secret Manager."""
    try:
        client = secretmanager.SecretManagerServiceClient()
        project = os.environ.get("GCP_PROJECT")
        secret_name = os.environ.get("SENDGRID_SECRET", "sendgrid-api-key")
        name = f"projects/{project}/secrets/{secret_name}/versions/latest"
        response = client.access_secret_version(request={"name": name})
        return response.payload.data.decode("UTF-8")
    except Exception as e:
        print(f"Warning: Could not fetch email API key: {e}")
        return None


def send_email_via_resend(api_key, to_email, name, email, message):
    """Send notification email via Resend API."""
    payload = {
        "from": "Portfolio Contact <onboarding@resend.dev>",
        "to": [to_email],
        "subject": f"Portfolio Contact: {name}",
        "text": (
            f"You received a new message from your portfolio!\n\n"
            f"Name: {name}\n"
            f"Email: {email}\n\n"
            f"Message:\n{message}\n\n"
            f"---\n"
            f"Reply directly to: {email}"
        ),
    }

    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    response = http_requests.post(RESEND_API_URL, json=payload, headers=headers)
    response.raise_for_status()
    return response.json()


@functions_framework.http
def handle_contact(request):
    """
    HTTP Cloud Function entry point.
    Saves message to Firestore and sends email notification via Resend.
    """

    # Handle CORS preflight
    if request.method == "OPTIONS":
        headers = {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Max-Age": "300",
        }
        return ("", 204, headers)

    # Standard CORS headers
    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
    }

    try:
        # Parse request body
        body = request.get_json(silent=True)
        if not body:
            raise ValueError("No body provided")

        # Prepare data
        item_id = str(uuid.uuid4())
        name = body.get("name", "Anonymous")
        email = body.get("email", "No Email")
        message = body.get("message", "No Message")

        doc = {
            "id": item_id,
            "name": name,
            "email": email,
            "message": message,
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        # 1. Save to Firestore
        db.collection(COLLECTION).document(item_id).set(doc)
        print(f"Saved contact message {item_id} to Firestore")

        # 2. Send email via Resend
        try:
            api_key = get_email_api_key()
            if api_key:
                recipient = os.environ.get("SENDER_EMAIL", "yisakmesifin@gmail.com")
                result = send_email_via_resend(api_key, recipient, name, email, message)
                print(f"Email sent via Resend: {result}")
            else:
                print("Email API key not configured — skipping email")
        except Exception as email_error:
            # Don't fail the request if email fails (data is safe in Firestore)
            print(f"Failed to send email: {str(email_error)}")

        return (
            json.dumps({"message": "Message sent successfully!", "id": item_id}),
            200,
            cors_headers,
        )

    except Exception as e:
        print(f"Error: {str(e)}")
        return (
            json.dumps({"error": str(e)}),
            500,
            cors_headers,
        )