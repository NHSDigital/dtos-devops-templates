from pathlib import Path

from helper_charts import create_pie_chart_base64
from helper_styles import build_html_styles, build_html_scripts
from results_writer import get_output_folder
from template_builder import *

class HtmlReportBuilder:
    """Generates an HTML report based on the provided list of scanned resources"""

    def __init__(self, scanner: ResourceScanner, compliance_areas: ComplianceAreas, compliance_check: ResourceComplianceChecker):
        self.scanner = scanner
        self.areas = compliance_areas
        self.compliance_check = compliance_check
        self.content = ""

    # 'Public' methods
    def generate(self, scan_datetime, scan_user, filter_used: str, scanned_json: str = None):
        self.content = f"""<!DOCTYPE html>
            <html lang="en">
            <head>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
                {build_html_styles()}
                {build_html_scripts()}
            </head>
            <body>
                <div class='title'>
                    <h2>Azure Tag Compliance Scan</h2>
                    <span>
                        Scan completed on: 📅 {scan_datetime} by 👤 {scan_user} and 🔍 filtered by {filter_used}
                    </span>
                </div>
                <div class='container'>
                    {self._generate_sidebar_html()}
                    <div class='main' id='content_area'>
                        {self._generate_summary_html()}
                        {self._generate_subscriptions_html(self.areas.area_names)}
                    </div>
                </div>
            </body>
            </html>
        """

    def save(self, filename):
        """Writes the results of the generated content to the specified output file."""
        if not self.content:
            print("No HTML content has been generated. Please run the 'generate' method with all scanned resources and try again.")
        else:
            output_path = Path(get_output_folder(filename))
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(self.content)

            print(f"✅ HTML report saved to {filename}")

    #-------------------------------------
    # Not intended to be called directly

    def _generate_tag_summary_html(self):
        coverage = self.compliance_check.get_tag_coverage()

        if not coverage.sorted_tags:
            return "<h3>Tag Usage</h3><emphasis>No tags founds on the scanned resources.</emphasis>"

        def build_row(tag, count):
            display = coverage.tag_display_names[tag]
            percentage = 0 if not coverage.total_resources else (count / coverage.total_resources * 100)
            required = " <span title='This tag is required' class='required-tag'>required</span>" if tag in coverage.required_tags else ""
            return f"<tr><td>🏷️ {display}{required}</td><td>{count} ({percentage:.1f}%)</td></tr>"

        tag_rows = "\n".join(build_row(tag, count) for tag, count in coverage.sorted_tags)

        return f"""
                <h3>Tag Usage</h3>
                <table>
                    <thead><tr><th>Tag</th><th>Coverage</th></tr></thead>
                    <tbody>{tag_rows}</tbody>
                </table>
            """

    def _generate_subscriptions_html(self, areas_names: list[str]) -> str:
        sections = []

        for sub in self.scanner.subscriptions:
            groups = self.compliance_check.groups_by_subscription(sub.id)
            tag_areas = self._generate_subscription_tag_summary_html(groups)

            content = build_subscription(sub.id, sub.name, tag_areas, areas_names, groups)

            sections.append(content)

        return "\n".join(sections)



    def _generate_subscription_tag_summary_html(self, groups: CompliantResources) -> str:
        area_compliance = self.compliance_check.count_compliance_by_areas(groups)
        area_tag_compliance = build_subscription_tag_compliance_rows(self.areas, area_compliance)
        return build_subscription_tag_summary(area_tag_compliance)


    def _generate_summary_charts_html(self):
        return build_summary_charts(
            create_pie_chart_base64(
                [res.resourceType for res in self.compliance_check.compliant_resources if res.resourceType],
                "Compliant Resources by Type"),
            create_pie_chart_base64(
                [res.resourceType for res in self.compliance_check.non_compliant_resources if res.resourceType],
                "Non-Compliant Resources by Type"))

    def _generate_summary_html(self) -> str:
        charts_html = self._generate_summary_charts_html()
        cards_html = self._generate_cards_html()
        tags_summary_html = self._generate_tag_summary_html()
        return build_summary(charts_html, cards_html, tags_summary_html)

    def _generate_cards_html(self):
        def render_card(name, tags, compliant, non_compliant):
            total = compliant + non_compliant
            percent = (compliant / total) * 100 if total else 0
            tags_list = build_card_tags(tags)

            return build_cards(name, tags_list, percent, compliant, non_compliant)

        return ''.join(
            render_card(
                area.name,
                self.areas[area.name].required,
                self.compliance_check.count_compliant_resources_by_area(area.name),
                self.compliance_check.count_non_compliant_resources_by_area(area.name)
            )
            for area in self.areas
        )

    def _generate_sidebar_html(self):
        subs = sorted({(sub.name, sub.id) for sub in self.scanner.subscriptions})
        links = build_sidebar_subscription_links(subs)
        return build_sidebar(links)
