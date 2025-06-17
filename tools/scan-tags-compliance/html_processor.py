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
        self.content = build_landing_page(
            scan_datetime, scan_user, filter_used,
            styles=build_html_styles(),
            scripts=build_html_scripts(),
            sidebar=self._generate_sidebar_html(),
            summary=self._generate_summary_html(),
            subscriptions=self._generate_subscriptions_html(self.areas.area_names))

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
        area_tag_compliance = build_subscription_tag_compliance_rows(self.areas.area_names, area_compliance)
        return build_subscription_tag_summary(area_tag_compliance)

    def _generate_summary_html(self) -> str:
        pie_charts = [
            SummaryChart(
                title = "Compliant Resources",
                data = create_pie_chart_base64(
                    [res.resourceType for res in self.compliance_check.compliant_resources if res.resourceType],
                    "Resources grouped by Resource Type")
            ),
            SummaryChart (
                title ="Non-Compliant Resources",
                data = create_pie_chart_base64(
                    [res.resourceType for res in self.compliance_check.non_compliant_resources if res.resourceType],
                    "Resources grouped by Resource Type")
            )
        ]

        cards = [
            SummaryCard(
                title = area.name,
                required = self.areas[area.name].required,
                compliant_count = self.compliance_check.count_compliant_resources_by_area(area.name),
                non_compliant_count = self.compliance_check.count_non_compliant_resources_by_area(area.name)
            )
            for area in sorted(self.areas, key=lambda k: k.name)
        ]

        coverage = self.compliance_check.get_tag_coverage()
        return build_summary(pie_charts, cards, coverage)


    def _generate_sidebar_html(self):
        subs = sorted({(sub.name, sub.id) for sub in self.scanner.subscriptions})
        entries = [SummarySubscription(
                id=id,
                name=name,
                total_resources=self.compliance_check.count_resources_by_subscription(id)
            )
            for name, id in subs]

        links = build_sidebar_subscription_links(entries)
        return build_sidebar(links)
