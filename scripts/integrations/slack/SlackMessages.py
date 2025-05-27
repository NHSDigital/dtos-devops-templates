import math
from typing import Dict
from datetime import datetime

def slack_message(header, body, context, outline_color) -> Dict:
    attachmentBlocks = []
    headerBlocks =[]

    if header:
        headerBlocks = header if isinstance(header, list) else [{"type": "section", "text": {"type": "mrkdwn", "text": header}}]

    if body:
        bodies = body if isinstance(body, list) else [{"type": "section", "text": {"type": "mrkdwn", "text": body}}]
        attachmentBlocks.extend(bodies)

    headerBlocks.append({"type": "section", "text": {"text": "   ", "type": "plain_text"}})

    if context:
        contexts = context if isinstance(context, list) else [{"type": "section", "text": {"type": "mrkdwn", "text": context}}]
        attachmentBlocks.extend(contexts)

    return {
        "username": "PipelinesBot",
        "blocks": headerBlocks,
        "attachments": [{"color": f"{outline_color}", "blocks": attachmentBlocks}],
    }


def clean_url(url) -> str:
    if not url:
        return "(no URL)"
    return url if url.startswith(("http://", "https://")) else f"https://{url}"


def url_link_text(url):
    return f"<{url}|here>" if url else "(no URL)"

def slack_message_style1_heading(pipeline_source, success: bool | None = None):
    pipeline_source = pipeline_source or "Build Pipelines"
    success_text = " 😎 " if success is True else " 😭 " if success is False else ""

    return [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"{success_text}*{pipeline_source}*",
            },
        }]

def slack_message_style1_subheading(test_results, build_url):
    total_circles = 5
    pass_rate = test_results.get("pass_rate", 0)
    total_tests = test_results.get("total", 0)

    try:
        green_circles = math.floor((pass_rate / 100) * total_circles)
    except (TypeError, ZeroDivisionError):
        green_circles = 0

    gray_circles = total_circles - green_circles

    emoji_bar = "✅ " * green_circles + "⚪️" * gray_circles
    if pass_rate == 100:
        emoji_bar = " 🏆🎉 "

    build = f"<{build_url}|Overall test results from latest build>" if build_url else "Overall test results"

    return [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"{emoji_bar} | *{build}* ({total_tests} total tests)",
            },
        }
    ]


def slack_message_style1_content(
    test_results,
    environment,
    deploy_date: str,
    deploy_user: str,
    deploy_id: str,
    branch_id: str
):
    '''
    Creates a default Build Completed with Test Results style
    '''

    user = deploy_user or "(user)"
    id = f" (#{deploy_id})" if deploy_id else ""
    date = deploy_date or datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    env = environment or "(environment)"

    def safe_get(key):
        return test_results.get(key, "-") if test_results else "-"

    return [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"Build{id} in *{env}* completed at *{date}* with a *{safe_get('pass_rate')}%* pass rate",
            },
        },
        {
            "type": "section",
            "fields": [
                {"type": "mrkdwn", "text": f"Requested by:\n {user}"},
                {"type": "mrkdwn", "text": f"Branch:\n {branch_id}"},
            ],
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [
                {"type": "mrkdwn", "text": f"*Failures:*\n {safe_get('failures')}"},
                {"type": "mrkdwn", "text": f"*Errors:*\n {safe_get('errors')}"},
                {"type": "mrkdwn", "text": f"*Skipped:*\n {safe_get('skipped')}"},
            ]
        },
    ]
