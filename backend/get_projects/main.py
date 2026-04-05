"""
Get Projects Cloud Function — GCP Version
GCP equivalent of: AWS Lambda + API Gateway GET /projects

Architecture:
  HTTP Request → Cloud Function → GitHub API → JSON Response
"""
import json
import urllib.request
import os

import functions_framework

# Configuration
GITHUB_USERNAME = os.environ.get("GITHUB_USERNAME", "yisakm9")


@functions_framework.http
def handle_projects(request):
    """
    HTTP Cloud Function entry point.
    Equivalent to Lambda handler(event, context).
    
    Fetches public GitHub repositories and returns them as JSON.
    """

    # Handle CORS preflight
    if request.method == "OPTIONS":
        headers = {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "GET, OPTIONS",
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
        print(f"Fetching projects for: {GITHUB_USERNAME}")

        # Fetch 6 most recently updated repositories (same logic as AWS version)
        url = f"https://api.github.com/users/{GITHUB_USERNAME}/repos?sort=updated&per_page=6"

        # GitHub API requires a User-Agent header
        req = urllib.request.Request(
            url, headers={"User-Agent": "GCP-CloudFunction-Portfolio"}
        )

        with urllib.request.urlopen(req) as response:
            if response.status != 200:
                raise Exception(f"GitHub API returned {response.status}")

            data = json.loads(response.read().decode())

            projects = []
            for repo in data:
                # Skip forked repos to show only original work
                if not repo["fork"]:
                    projects.append(
                        {
                            "id": repo["id"],
                            "name": repo["name"],
                            "description": repo["description"]
                            or "No description provided.",
                            "html_url": repo["html_url"],
                            "language": repo["language"],
                            "stars": repo["stargazers_count"],
                        }
                    )

        return (json.dumps(projects), 200, cors_headers)

    except Exception as e:
        print(f"Error fetching projects: {str(e)}")
        return (
            json.dumps({"error": "Failed to fetch projects from GitHub"}),
            500,
            cors_headers,
        )