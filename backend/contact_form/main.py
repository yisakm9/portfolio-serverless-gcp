"""
Contact Form Cloud Function — GCP Version
GCP equivalent of: AWS Lambda + API Gateway POST /contact + DynamoDB + SES

Architecture:
  HTTP Request → Cloud Function → Firestore + SendGrid Email
"""
import json
import uuid
import os
from datetime import datetime, timezone

import functions_framework
from google.cloud import firestore
from google.cloud import secretmanager
import sendgrid
from sendgrid.helpers.mail import Mail

# Initialize Firestore client (equivalent to boto3.resource('dynamodb'))
db = firestore.Client()

# Collection name (equivalent to DynamoDB table)
COLLECTION = "contact-messages"


def get_sendgrid_api_key():
    """Fetch SendGrid API key from Secret Manager (replaces SES config)."""
    try:
        client = secretmanager.SecretManagerServiceClient()
        project = os.environ.get("GCP_PROJECT")
        secret_name = os.environ.get("SENDGRID_SECRET", "sendgrid-api-key")
        name = f"projects/{project}/secrets/{secret_name}/versions/latest"
        response = client.access_secret_version(request={"name": name})
        return response.payload.data.decode("UTF-8")
    except Exception as e:
        print(f"Warning: Could not fetch SendGrid key: {e}")
        return None


@functions_framework.http
def handle_contact(request):
    """
    HTTP Cloud Function entry point.
    Equivalent to Lambda handler(event, context).
    
    Cloud Functions use Flask under the hood, so request/response
    are Flask objects instead of API Gateway event/context.
    """

    # Handle CORS preflight (equivalent to API Gateway CORS config)
    if request.method == "OPTIONS":
        headers = {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "POST, OPTIONS",
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Max-Age": "300",
        }
        return ("", 204, headers)

    # Standard CORS headers for all responses
    cors_headers = {
        "Access-Control-Allow-Origin": "*",
        "Content-Type": "application/json",
    }

    try:
        # Parse request body (Flask handles JSON parsing)
        body = request.get_json(silent=True)
        if not body:
            raise ValueError("No body provided")

        # Prepare data (same logic as AWS version)
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

        # 1. Save to Firestore (replaces DynamoDB put_item)
        db.collection(COLLECTION).document(item_id).set(doc)
        print(f"Saved contact message {item_id} to Firestore")

        # 2. Send email via SendGrid (replaces SES send_email)
        try:
            api_key = get_sendgrid_api_key()
            if api_key:
                sender_email = os.environ.get("SENDER_EMAIL", "yisakmesifin@gmail.com")
                sg_mail = Mail(
                    from_email=sender_email,
                    to_emails=sender_email,  # Send to yourself
                    subject=f"Portfolio Contact: {name}",
                    plain_text_content=(
                        f"You received a new message!\n\n"
                        f"Name: {name}\n"
                        f"Email: {email}\n\n"
                        f"Message:\n{message}"
                    ),
                )
                sg = sendgrid.SendGridAPIClient(api_key=api_key)
                sg.send(sg_mail)
                print("Email sent successfully via SendGrid")
            else:
                print("SendGrid not configured — skipping email")
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