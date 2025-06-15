from pathlib import Path

from helper_charts import create_pie_chart_base64
from helper_styles import build_html_styles, build_html_scripts
from helper_tags import generate_tag_pills_html
from resource_compliance_areas import COMPLIANT, NON_COMPLIANT
from resource_compliance_checker import ComplianceAreas, ResourceComplianceChecker
from resource_scanner import ResourceScanner, ResourceRecord
from results_writer import get_output_folder


def generate_compliance_count_html(compliance_type, compliant_count, non_compliant_count):
    if compliance_type == COMPLIANT:
        return f"""(<span style="color:green">{compliant_count}</span>)"""

    return f"""(<span style="color:red">{non_compliant_count}</span>)"""

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
                        {self._generate_subscriptions_html()}
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

    def _generate_resource_rows_html(self, resources: list[ResourceRecord]) -> str:
        if not resources:
            return "<span>No resources for this group.</span>"

        header = "".join(f"<th class='tag-area'>{area.name}</th>" for area in self.areas)

        rows = []
        for resource in resources:
            tag_pills_html = generate_tag_pills_html(resource.tags)
            tooltip = f"""
                <div class='tooltip-text'>
                    <span><strong>🔖 Resource ID:</strong></span><br>
                    <span style='font-size:0.75rem'>{resource.id}</span>
                </div>
            """

            row = [f"""<tr>
                <td class='has-tooltip'>{resource.name}{tag_pills_html}{tooltip}</td>
            """]

            for area in self.areas:
                compliance = resource.compliance.get(area.name)
                missing = "" if not compliance else compliance.required_missing
                area_tags_html = generate_tag_pills_html(missing, True)

                row.append(f"<td>{area_tags_html}</td>")

            row.append("</tr>")
            rows.append("".join(row))

        return f"""
            <table>
                <tr><th class='name-area'>Name</th>{header}</tr>
                {''.join(rows)}
            </table>
        """

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

    def _generate_subscriptions_html(self) -> str:
        sections = []

        for sub in self.scanner.subscriptions:
            sub_id = f"sub-{sub.id}"

            compliant = self.compliance_check.compliant_groups_by_subscription(sub.id)
            non_compliant = self.compliance_check.non_compliant_groups_by_subscription(sub.id)

            content = "\n".join([
                f"<div id='{sub_id}' class='content-section' style='display:none;'>",
                f"<div class='subs-header'><h2>🗂️ {sub.name}</h2></div>",
                self._generate_subscription_tag_areas_html(compliant, non_compliant),
                self._generate_groups_html(COMPLIANT, compliant),
                self._generate_groups_html(NON_COMPLIANT, non_compliant),
                "</div>"
            ])

            sections.append(content)

        return "\n".join(sections)

    def _generate_groups_html(self, compliance_status, groups):
        if not groups:
            return f"<div><h3>{compliance_status} (0)</h3>No matching items for this status.</div>"

        html_parts = [f"<div><h3>{compliance_status} ({len(groups)})</h3>"]

        for group in sorted(groups, key=lambda grp: grp.name.lower().strip()):
            tag_pills_html = generate_tag_pills_html(group.tags)
            resources = self.scanner.get_resources_by_group(group.id)

            compliant_count = sum(item.is_fully_compliant for item in resources)
            non_compliant_count = len(resources) - compliant_count

            count_html = generate_compliance_count_html(compliance_status, compliant_count, non_compliant_count)
            resource_table_html = self._generate_resource_rows_html(resources)

            html_parts.append(f"""
                       <div class='collapsible'>
                           <div class='collapsible-header'>📦{group.name}
                               <span style="margin-left: 10px; font-weight: normal;">{count_html}</span>
                               {tag_pills_html}
                           </div>
                           <div class='collapsible-body'>{resource_table_html}</div>
                       </div>
                   """)

        html_parts.append("</div>")
        return "".join(html_parts)

    def _generate_subscription_tag_areas_html(self, compliant_tags: list[ResourceRecord], non_compliant_tags: list[ResourceRecord]) -> str:
        rows = "".join(
            f"<tr><td>{area.name}</td>"
            f"<td style='color:green'>{sum(self.compliance_check.count_compliant_resources_by_parent(area.name, res.id) for res in compliant_tags)}</td>"
            f"<td style='color:red'>{sum(self.compliance_check.count_non_compliant_resources_by_parent(area.name, res.id) for res in non_compliant_tags )}</td></tr>"
            for area in self.areas
        )
        return f"<table><tr><th>Tag Area</th><th>Compliant</th><th>Non-Compliant</th></tr>{rows}</table>"


    def _generate_summary_charts_html(self):
        compliant_pie = create_pie_chart_base64([res.resourceType for res in self.compliance_check.compliant_resources if res.resourceType], "Compliant Resources by Type")
        non_compliant_pie = create_pie_chart_base64([res.resourceType for res in self.compliance_check.non_compliant_resources if res.resourceType], "Non-Compliant Resources by Type")

        return f"""
            <div><h4>Compliant</h4><img class='responsive-chart' src='data:image/png;base64,{compliant_pie}'/></div>
            <div><h4>Non-Compliant</h4><img class='responsive-chart' src='data:image/png;base64,{non_compliant_pie}'/></div>
        """

    def _generate_summary_html(self):
        charts_html = self._generate_summary_charts_html()
        cards_html = self._generate_cards_html()
        tags_summary_html = self._generate_tag_summary_html()

        return f"""
            <div id='summary' class='content-section'>
                <div class='card-grid'>{cards_html}</div>
                <div class='flex-charts'>{charts_html}</div>
                <div class="tag-usage">{tags_summary_html}</div>
            </div>"""

    def _generate_cards_html(self):
        def render_card(name, tags, compliant, non_compliant):
            total = compliant + non_compliant
            percent = (compliant / total) * 100 if total else 0
            tag_list = ''.join(f'<li>{tag}</li>' for tag in tags)

            return f"""
            <div class='card'>
                <h3>{name}</h3>
                <ul>{tag_list}</ul>
                <span class='card-complianceCheck'>{percent:.1f}%</span>
                <p class='card-summary'>(Compliant/Non-compliant):
                    <span style='color:green'>{compliant}</span> /
                    <span style='color:red'>{non_compliant}</span>
                </p>
            </div>
            """

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

        links = [
            f"<a href='javascript:showSection(\"sub-{sub_id}\")'>{sub_name}</a>"
            for sub_name, sub_id in subs
        ]

        return f"""
            <div class='sidebar'>
                <h3>Menu</h3>
                <a href='javascript:showSection("summary")' style='margin-bottom: 10px;'><strong>📊 Summary</strong></a>
                <strong style='display:block;margin-bottom:20px'>Subscriptions</strong>
                {''.join(links)}
            </div>
        """
