from argparse import Namespace
import logging
import requests
from SlackMessages import *

logger = logging.getLogger()
logger.setLevel(logging.INFO)


class SlackWebhookBot:
    def __init__(self, webhook_url: str, timeout: int = 15):
        self.webhook_url = webhook_url
        self.timeout = timeout
        self.headers = {
            "Content-Type": "application/json",
        }


    def send_report_message(self, args: Namespace, test_results) -> bool:
        try:

            header_b1 = slack_message_style1_heading(args.pipeline)
            header_b2 = slack_message_style1_subheading(test_results, args.url)
            header_b1.extend(header_b2)
            body = slack_message_style1_content(
                test_results,
                args.env,
                args.date,
                args.user,
                args.id,
                args.branch,
            )

            border_color = (
                "#2eb886" if test_results["pass_rate"] == 100 else
                "#e01e5a" if test_results["failures"] > 0 else
                "#ecb22e"
            )

            message = slack_message(header_b1, body, None, border_color)

            return self.send(message)
        except Exception as e:
            logger.error(f"Error reading or sending file content: {e}")
            return False


    def send(self, message) -> bool:
        success = False
        try:
            r = requests.post(
                self.webhook_url,
                headers=self.headers,
                json=message,
                timeout=self.timeout,
            )
            if r.status_code == 200:
                success = True
                logger.info("Message sent successfully to Slack endpoint.")
            else:
                logger.error(
                    f"Failed to send message to Slack endpoint. Status code: {r.status_code}, response: {r.text}"
                )
        except requests.Timeout:
            logger.error(
                "Timeout occurred while trying to send message to Slack endpoint."
            )
        except requests.RequestException as e:
            logger.error(f"Error occurred while communicating with Slack: {e}.")
        else:
            success = False
            logger.info("Another error occurred while sending the message to Slack endpoint.")

        return success
