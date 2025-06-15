import base64
import json
from collections import defaultdict
from io import BytesIO
from pathlib import Path

from matplotlib import pyplot as plt

from resource_compliance_areas import COMPLIANT, NON_COMPLIANT
from resource_compliance_checker import ComplianceAreas, ResourceComplianceChecker
from resource_scanner import ResourceScanner, ResourceRecord
from results_writer import get_output_folder

MAX_PILL_LENGTH = 50


def _generate_html_styles_and_scripts() -> str:
    return """
    <style>
        /* We globalise colour to ensure consistency across the page */
        :root {
        --color-bg-main: #f9f9f9;
        --color-bg-sidebar: #f4f4f4;
        --color-bg-hover: #a2c7ff;
        --color-bg-header: #eee;
        --color-bg-pill: #e0f0ff;
        --color-bg-pill-required: lightcoral;
        --color-bg-selected: #d0e3ff;
        --color-bg-tooltip: white;

        --color-border-light: #f7f7f7;
        --color-border-medium: #ccc;
        --color-border-pill: #c8e1ff;

        --color-text-main: #333;
        --color-text-pill: #0366d6;
        --color-text-pill-required: #fff;
        --color-text-tooltip: #333;

        --box-shadow-hover: 0 4px 12px rgba(0,0,0,0.15);
        --box-shadow-title: 0px 2px 6px rgba(0, 0, 0, 0.1);
        --box-shadow-tooltip: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
            margin: 0;
            padding: 0;
        }
        .container { max-width: 80vw; margin: auto; display: flex; }

        .main {
            flex: 1;
            padding: 0 20px 20px 20px;
            max-width: 80vw;
            box-sizing: border-box;
        }

        .card-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 30px; }
        .card {
            background: var(--color-bg-main);
            border: 1px solid var(--color-border-light);
            border-radius: 12px;
            padding: 16px;
            position: relative;
            transition: box-shadow 0.1s;
            flex-basis: 320px;
            flex-grow: 1;
            flex-shrink: 0;
            flex-wrap: wrap;
            display: flex;
            flex-direction: column;
            align-items: stretch;
        }
        .card:hover {
            box-shadow: var(--box-shadow-hover);
        }
        .card-complianceCheck{

            font-size: 3.0rem;
            text-align: center;
            display: block;
        }
        .card-summary {
            margin-top: 10px;
            font-size: 0.7rem;
            text-align: center;
        }
        .card li::marker { content: "🏷️ "; }
        .card ul { flex-grow: 1; }

        .collapsible { border: 1px solid #ccc; margin: 10px 0; border-radius: 6px; overflow: hidden; }
        .collapsible-header {
            background: var(--color-bg-header);
            padding: 10px;
            cursor: pointer;
            font-weight: bold;
            position: relative;
        }
        .collapsible-header:hover{
            background: var(--color-bg-hover);
            cursor: pointer;
        }
        .collapsible-header::after {
            display: inline-block;
            content: "⏵";
            position: absolute;
            right: 20px;
            top: 50%;
            transform: translateY(-50%);
            transition: transform 0.3s ease;
        }
        .collapsible.open .collapsible-header::after {
            transform: translateY(-50%) rotate(90deg);
        }
        .collapsible-body { display: none; padding: 10px; background: #fff; }
        .collapsible.open .collapsible-body { display: block; }

        .flex-charts { display: flex; flex-direction: column; justify-content: space-between; margin: 30px 0; gap: 20px; }
        .flex-charts div { flex: 1; text-align: center; border: 1px solid grey; border-radius: 6px; }

        .has-tooltip {
            position: relative;
            cursor: help;
        }
        .has-tooltip:hover {
            visibility: visible;
            opacity: 1;
        }
        .pill {
            background-color: var(--color-bg-pill);
            color: var(--color-text-pill);
            border: 1px solid var(--color-border-pill);
            border-radius: 12px;
            padding: 2px 8px;
            font-size: 0.85em;
            line-height: 1.5;
            white-space: normal;
            font-weight: bold;
            font-size: 0.7rem;
            word-break: auto-phrase;
        }
        .pill.required {
            background-color: var(--color-bg-pill-required);
            color: var(--color-text-pill-required);
        }
        .responsive-chart {
            max-width: 100%;
            height: auto;
            max-height: 400px;
            object-fit: contain;
            display: block;
            margin: auto;
        }
        .required-tag{
            background-color: var(--color-bg-pill);
            border-radius: 5px;
            border: 1px solid #d1d1d1;
            font-size: 0.6rem;
            font-weight: bold;
            padding: 2px 4px;
            margin: 5px;
            display: inline-block;
        }
        .sidebar {
            background: var(--color-bg-sidebar);
            color: var(--color-text-main);
            min-width: 230px;
            max-width: 230px;
            padding: 16px;
            height: 100vh;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            position: sticky;
            top: 20px;
            align-self: flex-start;
            margin-right: 20px;
            overflow-y: auto;
            word-wrap: break-word;
            white-space: normal;
        }
        .sidebar h3 { margin-top: 0; }
        .sidebar a {
            display: block;
            padding: 6px;
            color: #333;
            text-decoration: none;
            border: 1px solid transparent;
            font-size: 0.85rem;
            overflow-wrap: break-word;
            word-break: break-word;
            white-space: normal;
        }
        .sidebar a:hover {
            text-decoration: none;
            background-color: var(--color-bg-hover);
            border: 1px solid #f6f6f6;
            border-radius: 6px;
        }
        .sidebar a.selected {
            background-color: var(--color-bg-selected);
            font-weight: bold;
            border-radius: 6px;
            border: 1px solid #7aa8e6;
        }
        .subs-header{
            position: sticky;
            top: 0;
            z-index: 10;
            padding: 10px 16px;
            border-bottom: 1px solid var(--color-border-light);
            font-weight: bold;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            opacity: 0.97;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            table-layout: auto;
            word-break: break-word;
            max-width: 100%;
        }
        td.has-tooltip {
            font-size: 0.9rem;
            font-weight: bold;
        }
        td.has-tooltip:hover {
            background-color: var(--color-bg-hover);
        }
        th.tag-area {
            max-width: 150px;
            white-space: normal;
            overflow-wrap: break-word;
            word-break: break-word;
            text-overflow: ellipsis;
            vertical-align: top;
        }
    th.name-area {
            min-width: 150px;
            max-width: 150px;
            white-space: normal;
            overflow-wrap: break-word;
            word-break: break-word;
            text-overflow: ellipsis;
            vertical-align: top;
        }
        th {
            background: var(--color-bg-table-header);
        }
        th, td {
            border: 1px solid #ccc;
            padding: 8px; text-align: left;
        }

        .tag-pills {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            padding-top: 4px;
            padding-bottom: 4px;
            flex-direction: row;
            justify-content: flex-start;
        }
        .tag-usage {
            font-size: 0.9em;
            margin-top: 20px;
        }
        .tag-usage table {
            width: 100%;
            border-collapse: collapse;
        }
        .tag-usage td {
            border-bottom: 1px solid #ddd;
            padding: 4px 6px;
        }
        .tooltip-float {
            background: var(--color-bg-tooltip);
            color: var(--color-text-tooltip);
            box-shadow: var(--box-shadow-tooltip);
            position: absolute;
            pointer-events: none;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 0.9em;
            max-width: 300px;
            white-space: normal;
            word-break: break-word;
            z-index: 9999;
            opacity: 0;
            transition: opacity 0.2s ease;
            display: block;
        }
        .tooltip-text {
            display: block;
            visibility: hidden;
            background-color: var(--color-bg-tooltip);
            color: var(--color-text-tooltip);
            padding: 6px 10px;
            border-radius: 6px;
            position: absolute;
            z-index: 9999;
            max-width: 250px;
            bottom: 125%; /* position above the element */
            left: 50%;
            transform: translateX(-50%);
            white-space: normal;
            word-break: break-word;
            opacity: 0;
            transition: opacity 0.3s;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }
        .title {
            background: white;
            box-shadow: var(--box-shadow-title);
            display: flex;
            flex-direction: column;
            align-items: center;
            height: 70px;
            width: 100%;
            border-bottom: 1px solid lightgrey;
            margin-bottom: 16px;
            padding: 20px;
        }
        .title h2 { margin: 0 0 10px 0; }
    </style>
    <script>
        function showSection(id) {
            // window.scrollTo({ top: 0, behavior: 'smooth' });

            const sections = document.querySelectorAll('.content-section');
            sections.forEach(sec => sec.style.display = 'none');

            const selected = document.getElementById(id);
            if (selected) selected.style.display = 'block';

            // Remove "selected" class from all links
            var links = document.querySelectorAll('.sidebar a');
            links.forEach(link => {
                if (link.getAttribute('href').includes(id))
                    link.classList.add('selected');
                else
                    link.classList.remove('selected');
            });
        };
        document.addEventListener('DOMContentLoaded', () => {
            document.querySelectorAll('.collapsible-header').forEach(header => {
                header.addEventListener('click', () => {
                    const parent = header.parentElement;
                    parent.classList.toggle('open');
                });
            });
            showSection('summary');
        });

        document.addEventListener("DOMContentLoaded", () => {
            const tooltip = document.createElement("div");
            tooltip.className = "tooltip-float";
            document.body.appendChild(tooltip);

            document.querySelectorAll(".has-tooltip").forEach(cell => {
                const inner = cell.querySelector(".tooltip-text");
                if (!inner) return;

                cell.addEventListener("mouseenter", () => {
                    tooltip.innerHTML = inner.innerHTML;
                    tooltip.style.opacity = "1";

                    const rect = cell.getBoundingClientRect();
                    const scrollY = window.scrollY || document.documentElement.scrollTop;
                    const scrollX = window.scrollX || document.documentElement.scrollLeft;

                    tooltip.style.left = `${scrollX + rect.left + rect.width / 2 - tooltip.offsetWidth / 2}px`;
                    tooltip.style.top = `${scrollY + rect.top - tooltip.offsetHeight - 10}px`;

                    // Wait until tooltip renders to adjust final horizontal alignment
                    requestAnimationFrame(() => {
                        tooltip.style.left = `${scrollX + rect.left + rect.width / 2 - tooltip.offsetWidth / 2}px`;
                    });
                });

                cell.addEventListener("mouseleave", () => {
                    tooltip.style.opacity = "0";
                });
            });
        });
    </script>
    """

def format_tag_pill(key, value: any = None, required: bool = False):
    if value is None:
        value_str = key
    else:
        value_str = f"{key}={value}"

    style  = "pill"
    if required:
        style += " required"

    if len(value_str) > MAX_PILL_LENGTH:
        display_text = value_str[:MAX_PILL_LENGTH - 3] + "..."
        return f"<span class='{style}' title='{value_str}'>{display_text}</span>"
    else:
        return f"<span class='{style}'>{value_str}</span>"

def generate_tag_pills_html(tags, required: bool = False):
    res_tags = {}
    if isinstance(tags, str):
        try:
            res_tags = json.loads(tags)
        except json.JSONDecodeError:
            res_tags = {part.strip(): None for part in tags.split(",") if part.strip()}

    visible_tags = {key: val for key, val in res_tags.items() if not key.startswith("hidden-link:")}
    html = "".join(format_tag_pill(key, val, required) for key, val in sorted(visible_tags.items()))
    return f"""<span class='tag-pills'>{html}</span>"""

def create_pie_chart_base64(data: list[ResourceRecord], title) -> str:
    type_counts = defaultdict(int)
    for resource in data:
        # get the resource type from the resource that was scanned
        if resource.resourceType:
            type_counts[resource.resourceType] += 1

    sorted_types = sorted(type_counts.items(), key=lambda x: x[1], reverse=True)
    top = sorted_types[:5]
    other_count = sum(x[1] for x in sorted_types[5:])

    labels = [x[0] for x in top] + (["Other"] if other_count else [])
    sizes = [x[1] for x in top] + ([other_count] if other_count else [])

    fig, ax = plt.subplots()
    ax.pie(sizes, labels=labels, autopct='%1.1f%%')
    ax.axis('equal')
    plt.title(title)

    buf = BytesIO()
    plt.savefig(buf, format="png")
    plt.close(fig)
    buf.seek(0)

    return base64.b64encode(buf.read()).decode("utf-8")

def generate_compliance_count_html(compliance_type, resources: list[ResourceRecord]):
    compliant = sum(1 for item in resources if item.is_fully_compliant)
    non_compliant = len(resources) - compliant

    if compliance_type == COMPLIANT:
        return f"""(<span style="color:green">{compliant}</span>)"""

    return f"""(<span style="color:red">{non_compliant}</span>)"""


class HtmlReportBuilder:
    """Generates an HTML report based on the provided list of scanned resources"""

    def __init__(self, scanner: ResourceScanner, compliance_areas: ComplianceAreas, compliance_check: ResourceComplianceChecker):
        self.scanner = scanner
        self.areas = compliance_areas
        self.compliance_check = compliance_check
        self.content = ""

    # 'Public' methods
    def generate(self, scan_datetime, scan_user, filter_used: str):
        styles_and_scripts = _generate_html_styles_and_scripts()
        summary_html = self._generate_summary_html()
        subscriptions_html = self._generate_subscriptions_html()
        sidebar_html = self._generate_sidebar_html()

        self.content = f"""
        <!DOCTYPE html>
        <html lang="en">
            <head>
                <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
                {styles_and_scripts}
            </head>
            <body>
                <div class='title'>
                    <h2>Azure Tag Compliance Scan</h2>
                    <span>Scan completed on: 📅 {scan_datetime} by 👤 {scan_user} and 🔍 filtered by {filter_used}<span>
                </div>
                <div class='container'>
                    {sidebar_html}
                    <div class='main' id='content_area'>
                        {summary_html}
                        {subscriptions_html}
                    </div>
                </div>
            </body>
        </html>
        """

    def save(self, filename):
        """Writes the results of the generated content to the specified output file."""
        if not self.content:
            print("No HTML content has yet been generated. Please ensure to run the 'generate' method with all scanned resources, and try again.")
        else:
            output_path = Path(get_output_folder(filename))
            with open(output_path, "w", encoding="utf-8") as f:
                f.write(self.content)

            print(f"✅ HTML report saved to {filename}")

    #-------------------------------------
    # Not intended to be called directly

    def _generate_resource_rows_html(self, resources: list[ResourceRecord]) -> str:
        html = f"""
        <table>
            <tr>
                <th class='name-area'>Name</th>
        """

        for area in self.areas:
            html += f"<th class='tag-area'>{area.name}</th>"
        html += "</tr>"

        added = 0
        for resource in resources:
            added += 1
            tag_pills_html=""
            if resource.tags:
                tag_pills_html = generate_tag_pills_html(resource.tags)

            html += f"""<tr>
                <td class='has-tooltip'>
                    {resource.name}
                    <span class='tag-pills'>{tag_pills_html}</span>
                    <div class='tooltip-text'>
                        <span><strong>🔖 Resource ID:</strong></span><br>
                        <span style='font-size:0.7rem'> {resource.id}</span>
                    </div>
                </td>"""

            for area in self.areas:
                compliance = resource.compliance[area.name]
                tag_pills_html = generate_tag_pills_html(compliance.required_missing, True)

                html += f"<td>{tag_pills_html}</td>"

        html += "</tr></table>"

        if added == 0:
            return f"""
                <span>No resources for this group.</span>
            """

        return html

    def _generate_tag_summary_html(self):
        res_tag_counter, display_names = self.scanner.count_all_resource_tags()
        total_resources = len(self.scanner)
        tag_rows = ""

        # add compliance tags too, but exclude them if they already in the counter
        required_tag_set = {req.lower() for area in self.areas for req in area.required}
        res_tag_counter.update({tag: 0 for tag in required_tag_set - res_tag_counter.keys()})

        display_names.update({req.lower(): req for area in self.areas for req in area.required})

        # we want to sort the counted tags by count, then name so's it's easier to read for the
        # same count value. item[1] is the count value, and item[0] is the name
        sorted_tags = sorted(
            res_tag_counter.items(),
            key=lambda item: (-item[1], item[0])
        )

        for lower_tag, count in sorted_tags:
            display = display_names[lower_tag]
            percentage = 0 if not total_resources else (count / total_resources * 100)
            info_icon = "" if lower_tag not in required_tag_set else " <span title='This tag is required' class='required-tag'>required</span>"
            tag_rows += (
                f"<tr><td>🏷️ {display}{info_icon}</td>"
                f"<td>{count} ({percentage:.1f}%)</td></tr>"
            )

        if not tag_rows:
            return f"""
                <h3>Tag Usage</h3>
                <emphasis>No tags founds on the scanned resources.</emphasis>
            """

        return f"""
            <h3>Tag Usage</h3>
            <table>
                <thead><tr><th>Tag</th><th>Coverage</th></tr></thead>
                <tbody>{tag_rows}</tbody>
            </table>
        """

    def _generate_subscriptions_html(self) -> str:

        html = ""
        for subscription in self.scanner.subscriptions:
            sub_id = subscription.id

            compliant_groups = self.compliance_check.compliant_groups_by_subscription(sub_id)
            compliant_res_html = self._generate_groups_html(COMPLIANT, compliant_groups)

            non_compliant_groups = self.compliance_check.non_compliant_groups_by_subscription(sub_id)
            non_compliant_res_html = self._generate_groups_html(NON_COMPLIANT, non_compliant_groups)

            tag_areas_html = self._generate_subscription_tag_areas_html(compliant_groups, non_compliant_groups)

            html += f"""
                <div id='sub-{sub_id}' class='content-section' style='display:none;'>\n
                    <div class='subs-header'>
                        <h2>🗂️ {subscription.name}</h2>
                    </div>
                    {tag_areas_html}
                    {compliant_res_html}
                    {non_compliant_res_html}
                </div>
                """

        return html

    def _generate_groups_html(self, compliance_status, groups):
        html = f"<div><h3>{compliance_status} ({len(groups)})</h3>"

        if not groups:
            return f"""
                {html}
                No matching items for this status.
                </div>
                """

        for group in groups:
            tag_pills_html = generate_tag_pills_html(group.tags)

            resources = self.scanner.get_resources_by_group(group.id)
            resource_table_html = self._generate_resource_rows_html(resources)
            count_html = generate_compliance_count_html(compliance_status, resources)

            html += f"""
                <div class='collapsible'>
                    <div class='collapsible-header'>📦{group.name}
                        <span style="margin-left: 10px; font-weight: normal;">{count_html}</span>
                        {tag_pills_html}
                    </div>
                    <div class='collapsible-body'>{resource_table_html}</div>
                </div>"""

        html += "</div>"

        return html

    def _generate_subscription_tag_areas_html(self, compliant_tags: list[ResourceRecord], non_compliant_tags: list[ResourceRecord]):
        html = "<table><tr><th>Tag Area</th><th>Compliant</th><th>Non-Compliant</th></tr>"

        for area in self.areas:
            compliant = sum(
                self.scanner.count_compliant_for_area(area.name, res.id)
                for res in compliant_tags
            )

            non_compliant = sum(
                self.scanner.count_non_compliant_for_area(area.name, res.id)
                for res in non_compliant_tags
            )

            html += f"<tr><td>{area.name}</td><td style='color:green'>{compliant}</td><td style='color:red'>{non_compliant}</td></tr>"

        html += "</table>"

        return html

    def _generate_summary_charts_html(self):
        compliant_pie = create_pie_chart_base64(self.compliance_check.compliant_resources, "Compliant Resources by Type")
        non_compliant_pie = create_pie_chart_base64(self.compliance_check.non_compliant_resources, "Non-Compliant Resources by Type")

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
        html = ""
        for area in self.areas:
            compliant_count = self.compliance_check.count_compliant_resources_by_area(area.name)
            non_compliant_count = self.compliance_check.count_non_compliant_resources_by_area(area.name)

            area_tags = self.areas[area.name].required
            html += "".join(f"""
                <div class='card'>
                    <h3>{area.name}</h3>
                    <ul>{''.join(f'<li>{tag}</li>' for tag in area_tags)}</ul>
                    <span class='card-complianceCheck'>{(compliant_count/non_compliant_count)*100}%</span>
                    <p class='card-summary'>(Compliant/Non-compliant):
                        <span style='color:green'>{compliant_count}</span> /
                        <span style='color:red'>{non_compliant_count}</span>
                    </p>
                </div>
            """)

        return html

    def _generate_sidebar_html(self):
        unique_subs = sorted({(sub.name, sub.id) for sub in self.scanner.subscriptions})
        sidebar_links_html = ''.join(f"<a href='javascript:showSection(\"sub-{subs_id}\")'>{subs_name}</a>"
                                     for subs_name, subs_id in unique_subs)

        return f"""
            <div class='sidebar'>
                <h3>Menu</h3>
                <a href='javascript:showSection("summary")' style='margin-bottom: 10px;'><strong>📊 Summary</strong></a>
                <strong style='display:block;margin-bottom:20px'>Subscriptions</strong>
                {sidebar_links_html}
            </div>"""
