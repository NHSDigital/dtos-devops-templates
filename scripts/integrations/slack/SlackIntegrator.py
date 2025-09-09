import logging
import sys
import os
from typing import Dict
from SlackWebhookBot import SlackWebhookBot

logger = logging.getLogger()
logger.setLevel(logging.INFO)

import argparse


def str_to_bool(val):
    val = str(val).lower()
    true_vals = {"yes", "true", "t", "1"}
    false_vals = {"no", "false", "f", "0"}

    if val in true_vals:
        return True
    if val in false_vals:
        return False

    raise argparse.ArgumentTypeError("Boolean value expected (true/false).")


def parse_args():
    parser = argparse.ArgumentParser(
        description="Send Slack notifications for post-deployment test results or deployments."
    )

    parser.add_argument(
        "-u",
        "--url",
        help="The URL of the completed build and artifacts.",
        required=False,
    )
    parser.add_argument(
        "-e",
        "--env",
        help="The environment related to the build and artifacts.",
        required=False,
    )
    parser.add_argument(
        "-t",
        "--testtype",
        help="The testtype of the test runs (e.g,. 'smoke', 'end-end' ' epic1')",
        required=False,
    )
    parser.add_argument(
        "-p",
        "--pipeline",
        help="The pipeline source containing the build and artifacts.",
        required=False,
    )
    parser.add_argument(
        "-r",
        "--reports",
        help="Path to the test report file (e.g., JUnit XML).",
        required=False,
    )
    parser.add_argument(
        "-s",
        "--success",
        help="Flag to indicate test success (overrides report parsing).",
        default=None,
        type=str_to_bool,
        nargs="?",
        const=True,
    )
    parser.add_argument(
        "-i",
        "--id",
        help="The ID of the deployment associated with this test run.",
        required=False,
    )
    parser.add_argument(
        "-b",
        "--branch",
        help="The main branch which the build executed against.",
        required=False,
    )
    parser.add_argument(
        "-d",
        "--date",
        help="The date and time the deployment started.",
        required=False,
    )
    parser.add_argument(
    "-m",
    "--message",
    help="Custom message to send to Slack (if not sending test results).",
    required=False,
)
    parser.add_argument(
        "-U",
        "--user",
        help="The user who initiated/triggered the build.",
        required=False,
    )
    parser.add_argument(
        "-v", "--verbose", help="Enable verbose output.", action="store_true"
    )
    parser.add_argument(
        "-w",
        "--webhook",
        help="The URL of a WebHook instance in Slack.",
        required=False,
    )

    return parser.parse_args()


def main(argv):

    args = parse_args()

    webhook_url = args.webhook
    if not webhook_url:
        webhook_url = os.environ.get("SLACK_WEBHOOK_URL")

    if args.verbose:
        print(f"[VERBOSE] Report Path: {args.reports}")
        print(f"[VERBOSE] Success flag: {args.success}")
        print(f"[VERBOSE] Deployment Date: {args.date}")
        print(f"[VERBOSE] Deployment ID: {args.id}")
        print(f"[VERBOSE] Deployed By: {args.user}")
        print(f"[VERBOSE] Branch: {args.branch}")
        print(f"[VERBOSE] Webhook URL: {webhook_url}")

    if not webhook_url:
        print(
            "❌ 'SLACK_WEBHOOK_URL' is either not set as an environment variable or was not passed via the '--webhook' parameter."
        )
        sys.exit(1)

    # Ensure we have either a report path or a message:
    if not args.reports and not args.message:
        print(
            "❌ Neither 'REPORT_PATH' nor 'MESSAGE' were specified. Please use the '-r' or '--reports' parameters to provide a valid path to a JUnit test results file, or the '-m' or '--message' parameter to provide a custom message to send to Slack."
        )
        sys.exit(1)

    slack = SlackWebhookBot(webhook_url)

    if args.reports:
        test_results = parse_junit_results(args.reports)
        slack.send_report_message(args, test_results)
    elif args.message:
        message_json = {"text": args.message}
        slack.send(message_json)
    else:
        print("❌ Either '--reports' or '--message' must be provided.")
        sys.exit(1)

def parse_junit_results(path) -> Dict:
    import xml.etree.ElementTree as ET

    try:
        tree = ET.parse(path)
        root = tree.getroot()

        ra = root.attrib
        if root.tag == "testsuites" and len(root):
            if not ra.get("tests") and root[0].tag == "testsuite":
                ra = root[0].attrib

        total = int(ra.get("tests", 0))
        failures = int(ra.get("failures", 0))
        errors = int(ra.get("errors", 0))
        skipped = int(ra.get("skipped", 0))
        passed = total - failures - errors - skipped

        pass_rate = round((passed / total) * 100, 2) if total > 0 else 0.0

        return {
            "total": total,
            "passed": passed,
            "failures": failures,
            "errors": errors,
            "skipped": skipped,
            "pass_rate": pass_rate,
        }
    except ET.ParseError as e:
        print(f"Failure while parsing the test results XML file: {e}")
    except FileNotFoundError:
        print(f"Test results not found at '{path}'")
    except Exception as e:
        print(
            f"An unexpected error occurred while parsing the test results XML file: {e}"
        )

    return {
        "total": 0,
        "passed": 0,
        "failures": 0,
        "errors": 0,
        "skipped": 0,
        "pass_rate": 0.0,
    }


if __name__ == "__main__":
    main(sys.argv[1:])
