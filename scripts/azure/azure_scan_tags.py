import json
import csv
from azure.identity import AzureCliCredential
from azure.mgmt.resource import SubscriptionClient, ResourceManagementClient
from azure.core.exceptions import HttpResponseError

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

    required_present = [t for t in required if t in tags]
    required_missing = [t for t in required if t not in tags]
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
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; }
        .container { max-width: 80vw; margin: auto; display: flex; }
        .sidebar {
            min-width: 200px;
            max-width: 200px;
            padding: 20px;
            background: #f4f4f4;
            height: 100vh;
            box-shadow: 2px 0 5px rgba(0,0,0,0.1);
            position: sticky;
            top: 20px;
            align-self: flex-start;
            margin-right: 20px;
            overflow-y: auto;
        }
        .sidebar h3 { margin-top: 0; }
        .sidebar a { display: block; padding: 6px 0; color: #333; text-decoration: none; }
        .sidebar a:hover { text-decoration: underline; }
        .main { flex: 1; padding: 0 20px 20px 20px; max-width: 80vw; overflow-x: auto; box-sizing: border-box; }

        .card-grid { display: flex; flex-wrap: wrap; gap: 20px; margin-bottom: 30px; }
        .card {
            background: #f9f9f9;
            border: 1px solid #f7f7f7;
            border-radius: 12px;
            padding: 16px;
            position: relative;
            transition: box-shadow 0.3s;
            flex-basis: 320px;
            flex-grow: 1;
            flex-shrink: 0;
            flex-wrap: wrap;
            display: flex;
            flex-direction: column;
            align-items: stretch;
        }
        .card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
        .card-summary { margin-top: 10px; }
        .card li::marker { content: "🏷️ "; }
        .card li { flex-grow: 2; }

        .collapsible { border: 1px solid #ccc; margin: 10px 0; border-radius: 6px; overflow: hidden; }
        .collapsible-header {
            background: #eee;
            padding: 10px;
            cursor: pointer;
            font-weight: bold;
            position: relative;
        }
        .collapsible-header::after {
            content: "▶";
            position: absolute;
            right: 20px;
            transition: transform 0.3s ease;
        }
        .collapsible.open .collapsible-header::after {
            transform: rotate(90deg);
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

        .tag-pills {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            padding-top: 4px;
            padding-bottom: 4px;
            flex-direction: row;
            justify-content: flex-start;
        }

        .pill {
            background-color: #e0f0ff;
            color: #0366d6;
            border: 1px solid #c8e1ff;
            border-radius: 12px;
            padding: 2px 8px;
            font-size: 0.85em;
            line-height: 1.5;
            white-space: normal;
            font-weight: bold;
            font-size: 0.7rem;
            word-break: auto-phrase;
        }
        .tooltip-text {
            display: none;
            visibility: hidden;
            background-color: #333;
            color: #fff;
            text-align: center;
            padding: 6px 10px;
            border-radius: 6px;
            position: absolute;
            z-index: 9999;
            max-width: 250px;
            word-break: break-word;
            bottom: 125%; /* position above the element */
            left: 50%;
            transform: translateX(-50%);
            white-space: normal;
            opacity: 0;
            transition: opacity 0.3s;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }



        table { width: 100%; border-collapse: collapse; margin-top: 10px; table-layout: auto; word-break: break-word; max-width: 100%; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: left; }
        th { background: #f2f2f2; }

        .tooltip-float {
            position: absolute;
            pointer-events: none;
            background: #333;
            color: #fff;
            padding: 6px 10px;
            border-radius: 6px;
            font-size: 0.9em;
            max-width: 300px;
            white-space: normal;
            word-break: break-word;
            z-index: 9999;
            opacity: 0;
            transition: opacity 0.2s ease;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.3);
        }

        .title {
            display: flex;
            flex-direction: column;
            align-items: center;
            height: 80px;
            width: 100%;
            background: white;
            border-bottom: 1px solid lightgrey;
            margin-bottom: 16px;
            box-shadow: 0px 2px 6px rgba(0, 0, 0, 0.1);
            padding: 20px;
        }

        .title h2 { margin: 0; }
    </style>
    <script>
        function showSection(id) {
            const container = document.getElementById('content_area');
            const sections = document.querySelectorAll('.content-section');
            sections.forEach(sec => sec.style.display = 'none');
            const selected = document.getElementById(id);
            if (selected) selected.style.display = 'block';
        }
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
                    tooltip.textContent = inner.textContent;
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

def generate_res_table_html(resources):
    html = f"""
     <table>
        <tr>
            <th>Name</th>
    """

    for area in TAG_AREAS:
        html += f"<th>{area}</th>"
    html += "</tr>"

    for res in resources:
        tags = res["resourceTags"]
        if isinstance(tags, str):
            try:
                tags = json.loads(tags)
            except json.JSONDecodeError:
                tags = {}

        visible_tags = {k: v for k, v in tags.items() if not k.startswith("hidden-link:")}
        tag_pills_html = "".join(f"<span class='pill'>{k}={v}</span>" for k, v in visible_tags.items())

        html += f"""<tr>
            <td class='has-tooltip'>
                {res['resourceName']}
                <span class='tag-pills'>{tag_pills_html}</span>
                <span class='tooltip-text'>
                    Resource ID: {res['resourceId']}
                </span>
            </td>"""

        for area in TAG_AREAS:
            html += f"<td>{res[f'{area}_required_missing']}</td>"

    html += "</tr>"
    html += "</table>"

    return html

def generate_html_report(data, output_html):
    from collections import defaultdict
    import matplotlib.pyplot as plt
    import base64
    from io import BytesIO

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

    compliant_data = [row for row in data if all(row[f"{area}_required_met"] >= row[f"{area}_required_total"] for area in TAG_AREAS)]
    non_compliant_data = [row for row in data if row not in compliant_data]

    compliant_pie = create_pie_chart_base64(compliant_data, "Compliant Resources by Type")
    non_compliant_pie = create_pie_chart_base64(non_compliant_data, "Non-Compliant Resources by Type")

    area_summary = {area: {"required": TAG_AREAS[area]["required"], "compliant": 0, "non_compliant": 0} for area in TAG_AREAS}
    for row in data:
        for area in TAG_AREAS:
            if row[f"{area}_required_met"] >= row[f"{area}_required_total"]:
                area_summary[area]["compliant"] += 1
            else:
                area_summary[area]["non_compliant"] += 1

    subs = defaultdict(lambda: defaultdict(lambda: defaultdict(list)))
    for row in sorted(data, key=lambda x: (x['subscriptionName'], x['resourceGroupName'], x['resourceName'])):
        subscription = row['subscriptionName']
        resource_group = row['resourceGroupName']
        is_compliant = all(row[f"{area}_required_met"] >= row[f"{area}_required_total"] for area in TAG_AREAS)
        key = "Compliant" if is_compliant else "Non-Compliant"
        subs[subscription][key][resource_group].append(row)

    styles_and_scripts = generate_html_styles_and_scripts()
    menu_links = ''.join(f"<a href='javascript:showSection(\"sub-{sub.replace(' ', '-') }\")'>{sub}</a>" for sub in subs)

    cards_html = "".join(f"""
        <div class='card'>
            <h3>{area}</h3>
            <ul>{''.join(f'<li>{tag}</li>' for tag in values['required'])}</ul>
            <p class='card-summary'>(Compliant/Non-compliant):
                <span style='color:green'>{values['compliant']}</span> /
                <span style='color:red'>{values['non_compliant']}</span>
            </p>
        </div>
    """ for area, values in area_summary.items())

    summary_html = f"""
    <div id='summary' class='content-section'>
        <div class='card-grid'>{cards_html}</div>
        <div class='flex-charts'>
            <div><h4>Compliant</h4><img src='data:image/png;base64,{compliant_pie}'/></div>
            <div><h4>Non-Compliant</h4><img src='data:image/png;base64,{non_compliant_pie}'/></div>
        </div>
    </div>
    """

    sub_sections = ""
    for subscription, compliance in subs.items():
        sub_id = f"sub-{subscription.replace(' ', '-')}"
        sub_sections += f"""
            <div id='{sub_id}' class='content-section' style='display:none;'>\n
                <h2>🗂️ {subscription}</h2>
            """

        sub_sections += "<table><tr><th>Tag Area</th><th>Compliant</th><th>Non-Compliant</th></tr>"

        for area in TAG_AREAS:
            compliant = sum(1 for cat in compliance.values()
                            for rgs in cat.values()
                            for r in rgs if r[f'{area}_required_met'] >= r[f'{area}_required_total'])
            non_compliant = sum(1 for cat in compliance.values()
                                for rgs in cat.values()
                                for r in rgs if r[f'{area}_required_met'] < r[f'{area}_required_total'])

            sub_sections += f"<tr><td>{area}</td><td style='color:green'>{compliant}</td><td style='color:red'>{non_compliant}</td></tr>"

        sub_sections += "</table>"

        for category in ["Compliant", "Non-Compliant"]:
            if category in compliance:
                sub_sections += f"<h3>{category}</h3>"

                for resource_group, resources in compliance[category].items():
                    compliant = sum(
                        all(r[f"{area}_required_met"] >= r[f"{area}_required_total"] for area in TAG_AREAS)
                        for r in resources
                    )
                    non_compliant = len(resources) - compliant

                    resource_table_html = generate_res_table_html(resources)

                    tags = resources[0].get("resourceGroupTags") or {}
                    if isinstance(tags, str):
                        try:
                            tags = json.loads(tags)
                        except json.JSONDecodeError:
                            tags = {}

                    visible_tags = {k: v for k, v in tags.items() if not k.startswith("hidden-link:")}
                    tag_pills_html = "".join(f"<span class='pill'>{k}={v}</span>" for k, v in visible_tags.items())

                    sub_sections += f"""
                        <div class='collapsible'>
                            <div class='collapsible-header'>📦{resource_group}
                                <span style="margin-left: 10px; font-weight: normal;">
                                    (<span style="color:green">{compliant}</span> / <span style="color:red">{non_compliant}</span>)
                                </span>
                                <span class='tag-pills'>
                                    {tag_pills_html}
                                </span>
                            </div>
                            <div class='collapsible-body'>
                                {resource_table_html}
                            </div>
                        </div>"""

        sub_sections += "</div>"

    html = f"""
    <html>
        <head>{styles_and_scripts}</head>
        <body>
            <div class='title'>
                <h2>Azure Tag Compliance Scan</h2>
                <span>Scan completed on: </span>
            </div>
            <div class='container'>
                <div class='sidebar'>
                    <h3>Menu</h3>
                    <a href='javascript:showSection("summary")'>Summary</a>
                    {menu_links}
                </div>
                <div class='main' id='content_area'>
                    {summary_html}
                    {sub_sections}
                </div>
            </div>
        </body>
    </html>
    """

    with open(output_html, "w", encoding="utf-8") as f:
        f.write(html)

    print(f"✅ HTML report saved to {output_html}")


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


if __name__ == "__main__":
    results, skipped = get_flattened_resource_data()
    write_outputs(results, skipped)
    generate_html_report(results, "scan_results.html")
