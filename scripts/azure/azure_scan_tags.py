import argparse
import base64
from collections import defaultdict
import csv
from datetime import datetime
from io import BytesIO
import json
import sys
from typing import Counter
from azure.identity import AzureCliCredential
from azure.mgmt.resource import SubscriptionClient, ResourceManagementClient
from azure.core.exceptions import HttpResponseError
from matplotlib import pyplot as plt


MAX_PILL_LENGTH = 50

TAG_AREAS = {
    "FinOps": {
        "required": ["TagVersion", "Programme ?? Service ", "Product ?? Project", "Owner", "CostCentre"],
        "optional": ["Customer"]
    },
    "SecOps": {
        "required": ["data_classification", "DataType", "Environment", "ProjectType", "PublicFacing"],
        "optional": []
    },
    "TechOps": {
        "required": ["ServiceCategory", "OnOffPattern"],
        "optional": ["BackupLocal", "BackupRemote"]
    },
    "DevOps": {
        "required": ["ReleaseVersion ?? Version", "BuildDate", "BuildTime", "ApplicationRole", "Name"],
        "optional": ["Stack", "Cluster", "Tool"]
    }
}

def check_area_compliance(tags: dict, area_name: str) -> dict:
    area = TAG_AREAS.get(area_name)
    if not area:
        return {"area": area_name, "error": "Unknown area"}

    required = area["required"]
    optional = area["optional"]

    required_present = []
    required_missing = []

    for req in required:
        if "??" in req:
            options = [r.strip() for r in req.split("??")]
            found = next((opt for opt in options if opt in tags), None)
            if found:
                required_present.append(req)
            else:
                required_missing.append(req)
        else:
            if req in tags:
                required_present.append(req)
            else:
                required_missing.append(req)

    optional_present = [t for t in optional if t in tags]
    optional_missing = [t for t in optional if t not in tags]

    return {
        "area": area_name,
        "required_met": len(required_present),
        "required_total": len(required),
        "optional_met": len(optional_present),
        "optional_total": len(optional),
        "required_missing": required_missing,
        "optional_missing": optional_missing
    }

def compute_compliance(data):
    compliant = 0
    for row in data:
        if all(row[f"{area}_required_met"] >= row[f"{area}_required_total"] for area in TAG_AREAS):
            compliant += 1
    return {
        "total_resources": len(data),
        "compliant_resources": compliant,
        "non_compliant_resources": len(data) - compliant
    }


def generate_html_styles_and_scripts():
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
        .card-compliance{

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
            cursor: hand;
            font-weight: bold;
            position: relative;
        }
        .collapsible-header:hover{
            background: var(--color-bg-hover);
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
        .title h2 { margin: 0; }
    </style>
    <script>
        function showSection(id) {
            window.scrollTo({ top: 0, behavior: 'smooth' });

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


def generate_resources_html(resources):
    html = f"""
     <table>
        <tr>
            <th class='name-area'>Name</th>
    """

    for area in TAG_AREAS:
        html += f"<th class='tag-area'>{area}</th>"
    html += "</tr>"

    for res in resources:
        tags = res["resourceTags"]
        if isinstance(tags, str):
            try:
                tags = json.loads(tags)
            except json.JSONDecodeError:
                tags = {}

        visible_tags = {k: v for k, v in tags.items() if not k.startswith("hidden-link:")}
        tag_pills_html = "".join(format_tag_pill(k, v) for k, v in visible_tags.items())

        html += f"""<tr>
            <td class='has-tooltip'>
                {res['resourceName']}
                <span class='tag-pills'>{tag_pills_html}</span>
                <div class='tooltip-text'>
                    <span><strong>🔖 Resource ID:</strong></span><br>
                    <span style='font-size:0.7rem'> {res['resourceId']}</span>
                </div>
            </td>"""

        for area in TAG_AREAS:
            raw_tags = res.get(f"{area}_required_missing", "")
            missing_tags = [tag.strip() for tag in raw_tags.split(';') if tag.strip()]
            visible_tags = {k for k in missing_tags if not k.startswith("hidden-link:")}
            tag_pills_html = F"""<span class='tag-pills'>{ "".join(format_tag_pill(k, required = True) for k in visible_tags)}</span>"""

            html += f"<td>{tag_pills_html}</td>"

    html += "</tr>"
    html += "</table>"

    return html


def count_all_tags(resources):
    tag_key_counter = Counter()

    for row in resources:
        tags = json.loads(row["resourceTags"])
        for key in tags:
            if not key.startswith("hidden-link:"):
                tag_key_counter[key] += 1

    return tag_key_counter

def generate_tag_summary_html(data):
    tag_key_counter = count_all_tags(data)
    total_resources = len(data)
    tag_rows = ""

    for tag, count in tag_key_counter.most_common():
        percentage = (count / total_resources) * 100
        tag_rows += f"<tr><td>🏷️ {tag}</td><td>{count} ({percentage:.1f}%)</td></tr>"

    return f"""
        <h3>Tag Usage</h3>
        <table>
            <thead><tr><th>Tag</th><th>Coverage</th></tr></thead>
            <tbody>{tag_rows}</tbody>
        </table>
    """

def build_subscriptions_map(data):
    results = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for row in sorted(data, key=lambda subs: (subs['subscriptionName'], subs['resourceGroupName'], subs['resourceName'])):
        subsName = row['subscriptionName']
        rgName = row['resourceGroupName']

        is_compliant = all(row[f"{area}_required_met"] >= row[f"{area}_required_total"] for area in TAG_AREAS)
        compliance = "Compliant" if is_compliant else "Non-Compliant"

        results[subsName][compliance][rgName].append(row)

    return results

def generate_sidebar_html(resources):
    unique_subs = sorted({resource['subscriptionName'] for resource in resources})
    sidebar_links_html = ''.join(f"<a href='javascript:showSection(\"sub-{subs.replace(' ', '-') }\")'>{subs}</a>" for subs in unique_subs)

    return f"""
        <div class='sidebar'>
            <h3>Menu</h3>
            <a href='javascript:showSection("summary")' style='margin-bottom: 10px;'><strong>📊 Summary</strong></a>
            <strong style='display:block;margin-bottom:20px'>Subscriptions</strong>
            {sidebar_links_html}
        </div>"""

def generate_html_report(resources):
    styles_and_scripts = generate_html_styles_and_scripts()
    summary_html = generate_summary_html(resources)
    subscriptions_html = generate_subscriptions_html(resources)
    sidebar_html = generate_sidebar_html(resources)

    now = datetime.now()
    scan_date = now.strftime("%Y-%m-%d %H:%M:%S")

    return f"""
    <html>
        <head>
            <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&display=swap" rel="stylesheet">
            {styles_and_scripts}
        </head>
        <body>
            <div class='title'>
                <h2>Azure Tag Compliance Scan</h2>
                <span>Scan completed on: 📅 {scan_date} by 👤 ???</span>
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

def generate_subscriptions_html(data):
    # The format of the data is [subscription_name][compliance][resource_group_name][resource]
    subscriptions = build_subscriptions_map(data)

    html = ""
    for subsName, compliance in subscriptions.items():
        sub_id = f"sub-{subsName.replace(' ', '-')}"
        html += f"""
            <div id='{sub_id}' class='content-section' style='display:none;'>\n
                <div class='subs-header'>
                    <h2>🗂️ {subsName}</h2>
                </div>
            """
        tag_areas_html = generate_subscription_tag_areas_html(compliance)
        compliant_res_html = generate_subscription_compliant_res_html(compliance)

        html += f"{tag_areas_html} {compliant_res_html}</div>"

    return html

def generate_subscription_compliant_res_html(compliance):
    html = ""
    for category in ["Compliant", "Non-Compliant"]:
        if category in compliance:
            html += f"<div><h3>{category}</h3>"

            for resource_group, resources in compliance[category].items():
                tag_pills_html = generate_tag_pills_html(resources, "resourceGroupTags")
                count_html = generate_compliance_count_html(category, resources)
                resource_table_html = generate_resources_html(resources)

                html += f"""
                    <div class='collapsible'>
                        <div class='collapsible-header'>📦{resource_group}
                            <span style="margin-left: 10px; font-weight: normal;">{count_html}</span>
                            <span class='tag-pills'>{tag_pills_html}</span>
                        </div>
                        <div class='collapsible-body'>{resource_table_html}</div>
                    </div>"""

            html += "</div>"

    return html

def generate_tag_pills_html(resources, key):
    tags = resources[0].get(key) or {}
    if isinstance(tags, str):
        try:
            tags = json.loads(tags)
        except json.JSONDecodeError:
            tags = {}

    visible_tags = {k: v for k, v in tags.items() if not k.startswith("hidden-link:")}
    return "".join(format_tag_pill(k, v) for k, v in visible_tags.items())

def generate_compliance_count_html(category, resources):
    compliant = sum(
                        all(res[f"{area}_required_met"] >= res[f"{area}_required_total"] for area in TAG_AREAS)
                        for res in resources
                    )
    non_compliant = len(resources) - compliant

    if category == "Compliant":
        return f"""(<span style="color:green">{compliant}</span>)"""

    return f"""(<span style="color:red">{non_compliant}</span>)"""

def generate_subscription_tag_areas_html(compliance):
    html = "<table><tr><th>Tag Area</th><th>Compliant</th><th>Non-Compliant</th></tr>"

    for area in TAG_AREAS:
        # compliance.values() will contains the list of resource_groups
        compliant = sum(1 for groups in compliance.values()
                        for group in groups.values()
                        for res in group if res[f'{area}_required_met'] >= res[f'{area}_required_total'])
        non_compliant = sum(1 for groups in compliance.values()
                            for group in groups.values()
                            for res in group if res[f'{area}_required_met'] < res[f'{area}_required_total'])

        html += f"<tr><td>{area}</td><td style='color:green'>{compliant}</td><td style='color:red'>{non_compliant}</td></tr>"

    html += "</table>"

    return html

def create_pie_chart_base64(resource_data, title):
    type_counts = defaultdict(int)
    for row in resource_data:
        type_counts[row['resourceType']] += 1
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

def generate_summary_charts_html(data):
    compliant_data = [row for row in data if all(row[f"{area}_required_met"] >= row[f"{area}_required_total"] for area in TAG_AREAS)]
    non_compliant_data = [row for row in data if row not in compliant_data]

    compliant_pie = create_pie_chart_base64(compliant_data, "Compliant Resources by Type")
    non_compliant_pie = create_pie_chart_base64(non_compliant_data, "Non-Compliant Resources by Type")

    return f"""
        <div><h4>Compliant</h4><img class='responsive-chart' src='data:image/png;base64,{compliant_pie}'/></div>
        <div><h4>Non-Compliant</h4><img class='responsive-chart' src='data:image/png;base64,{non_compliant_pie}'/></div>
    """

def generate_summary_html(data):
    charts_html = generate_summary_charts_html(data)
    cards_html = generate_cards_html(data)
    tags_summary_html = generate_tag_summary_html(data)

    return f"""
        <div id='summary' class='content-section'>
            <div class='card-grid'>{cards_html}</div>
            <div class='flex-charts'>{charts_html}</div>
            <div class="tag-usage">{tags_summary_html}</div>
        </div>"""

def generate_cards_html(data):
    card_summary = {area: {"required": TAG_AREAS[area]["required"], "compliant": 0, "non_compliant": 0} for area in TAG_AREAS}
    for row in data:
        for area in TAG_AREAS:
            if row[f"{area}_required_met"] >= row[f"{area}_required_total"]:
                card_summary[area]["compliant"] += 1
            else:
                card_summary[area]["non_compliant"] += 1

    return "".join(f"""
        <div class='card'>
            <h3>{area}</h3>
            <ul>{''.join(f'<li>{tag}</li>' for tag in values['required'])}</ul>
            <span class='card-compliance'>{(values['compliant']/values['non_compliant'])*100}%</span>
            <p class='card-summary'>(Compliant/Non-compliant):
                <span style='color:green'>{values['compliant']}</span> /
                <span style='color:red'>{values['non_compliant']}</span>
            </p>
        </div>
    """ for area, values in card_summary.items())

def get_flattened_resource_data():
    credential = AzureCliCredential()
    subscription_client = SubscriptionClient(credential)

    flat_data = []
    skipped_items = []

    for sub in subscription_client.subscriptions.list():
        sub_id = sub.subscription_id
        sub_name = sub.display_name
        print(f"\n🔍 Scanning subscription: {sub_name} ({sub_id})")

        try:
            resource_client = ResourceManagementClient(credential, sub_id)
        except Exception as e:
            skipped_items.append(f"Subscription: {sub_id} - ERROR: {e}")
            continue

        try:
            resource_groups = list(resource_client.resource_groups.list())
        except HttpResponseError as e:
            skipped_items.append(f"Subscription: {sub_id} - Resource Groups - ERROR: {e.message}")
            continue

        for rg in resource_groups:
            rg_name = rg.name
            rg_location = rg.location
            rg_tags = rg.tags or {}
            print(f"  - Resource Group: {rg_name}")

            try:
                resources = list(resource_client.resources.list_by_resource_group(rg_name))
            except HttpResponseError as e:
                skipped_items.append(f"Subscription: {sub_id} - Resource Group: {rg_name} - Resources - ERROR: {e.message}")
                continue

            for resource in resources:
                tags = resource.tags or {}
                resource_record = {
                    "subscriptionId": sub_id,
                    "subscriptionName": sub_name,
                    "resourceGroupName": rg_name,
                    "resourceGroupLocation": rg_location,
                    "resourceGroupTags": json.dumps(rg_tags),
                    "resourceId": resource.id,
                    "resourceName": resource.name,
                    "resourceType": resource.type,
                    "resourceLocation": resource.location,
                    "resourceTags": json.dumps(tags)
                }

                for area in TAG_AREAS:
                    result = check_area_compliance(tags, area)

                    resource_record[f"{area}_required_met"] = result["required_met"]
                    resource_record[f"{area}_required_total"] = result["required_total"]
                    resource_record[f"{area}_optional_met"] = result["optional_met"]
                    resource_record[f"{area}_optional_total"] = result["optional_total"]
                    resource_record[f"{area}_required_missing"] = "; ".join(result["required_missing"])
                    resource_record[f"{area}_optional_missing"] = "; ".join(result["optional_missing"])

                flat_data.append(resource_record)

    return flat_data, skipped_items

def write_outputs(data, skipped):
    with open("azure_resource_compliance_detailed.csv", mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=data[0].keys())
        writer.writeheader()
        writer.writerows(data)

    with open("azure_skipped_items.log", "w") as f:
        for line in skipped:
            f.write(line + "\n")

    print("✅ Outputs saved: azure_resource_compliance_detailed.csv and azure_skipped_items.log")

def load_scan_file(filename):
    try:
        with open(filename, mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            return [
                row for row in reader
                if not args.filter or args.filter.lower() in row['resourceName'].lower()
            ]
    except FileNotFoundError:
        print(f"[ERROR] File not found: {filename}")
        sys.exit(1)


def write_report(content, filename):
    with open(filename, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"✅ HTML report saved to {filename}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate Azure tag compliance report.")
    parser.add_argument("-i", "--input", required=False, help="Specifies the input CSV file generated by a previous scan. Using this flag will not perform a new scan against the cloud provider resources.")
    parser.add_argument("-f", "--filter", help="Optional filter to only include resources whose name contains this substring.")

    args = parser.parse_args()

    if args.input:
        resources = load_scan_file(args.input)
    else:
        resources, skipped = get_flattened_resource_data()
        write_outputs(resources, skipped)

    html = generate_html_report(resources)
    write_report(html, "scan_results.html")
