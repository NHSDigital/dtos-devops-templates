from typing import Dict


def slack_message(header, body, context, outline_color) -> Dict:
    blocks1 = []
    blocks2 = []
    headers = []

    if header:
        if isinstance(header, list):
            headers.extend(header)
        else:
            headers.append(header)

    if body:
        if isinstance(body, list):
            blocks1.extend(body)
        else:
            blocks1.append(
                {"type": "section", "text": {"type": "mrkdwn", "text": body}}
            )

    blocks1.append({"type": "section", "text": {"text": "   ", "type": "plain_text"}})

    if context:
        if isinstance(context, list):
            blocks2.extend(context)
        else:
            blocks2.append(context)

    return {
        "username": "PipelinesBot",
        "blocks": headers,
        "attachments": [{"color": f"{outline_color}", "blocks": blocks1}],
    }


def clean_url(url) -> str:
    if url and not url.startswith("http"):
        return "https://" + url
    else:
        return url


def url_link_text(url):
    return f"<{url}|here" if url else "(no URL)"


def slack_message_header_block_1(pipeline_source, success: bool | None = None):
    pipeline_source = pipeline_source or "Build Pipelines"
    success_text = " 😎 " if success is True else " 😭 " if success is False else ""

    return [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"{success_text}*{pipeline_source}*",
            },
        }
    ]


def slack_message_header_block_2(test_results, build_url):
    total_circles = 5
    green_circles = round((test_results["pass_rate"] / 100) * total_circles)
    gray_circles = total_circles - green_circles

    if test_results["pass_rate"] == 100:
        emoji_bar = " 🏆🎉 "
    else:
        emoji_bar = "⭐" * green_circles + "☆" * gray_circles

    build = (
        f"<{build_url}|Overall test results from latest build>"
        if build_url
        else "Overall test results"
    )

    return [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"*{build}* {emoji_bar} ({test_results['total']} total tests)",
            },
        }
    ]


def slack_message_content_style_1(
    test_results,
    environment,
    deployDate: str,
    deployUser: str,
    deployId: str,
    build_url: str,
):

    user = deployUser or "(unknown user)"
    build = deployId or "(unknown)"
    date = deployDate or "(unknown date)"
    env = environment or "(unknown environment)"
    url = build_url or "https://example.com/"

    def safe_get(key):
        return test_results.get(key, "-") if test_results else "-"

    return [
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": f"The build in {env} requested by *{user}* on *{date}* has a *{safe_get('pass_rate')}%* pass rate",
            },
        },
        {
            "type": "section",
            "fields": [
                {"type": "mrkdwn", "text": f"*Passed:*\n {safe_get('passed')}"},
                {"type": "mrkdwn", "text": f"*Failures:*\n {safe_get('failures')}"},
                {"type": "mrkdwn", "text": f"*Errors:*\n {safe_get('errors')}"},
                {"type": "mrkdwn", "text": f"*Skipped:*\n {safe_get('skipped')}"},
            ],
        },
    ]
