from pathlib import Path

from helper_tags import generate_tag_pills_html
from resource_compliance_checker import *


def load_template(template_name: str) -> str:
    path = Path("templates") / template_name
    return path.read_text(encoding="utf-8")

def build_cards(name: str, tags_list: str, percent: float, compliant: int, non_compliant: int) -> str:
    return load_template('card_template.html').format(card_name=name, tag_list=tags_list, percent=percent, compliant=compliant, non_compliant=non_compliant)

def build_card_tags(tags)-> str:
    if not tags:
        return ""
    return "".join(f"<li>{tag}</li>" for tag in tags)

def build_sidebar_subscription_links(source: list[tuple[str, str]])->str:
    return "".join(
        [
            f"<a href='javascript:showSection(\"sub-{sub_id}\")'>{sub_name}</a>"
            for sub_name, sub_id in source
        ])

def build_sidebar(links)->str:
    return load_template('sidebar_template.html').format(links=links)

def build_summary(charts_html:str, cards_html:str, tags_summary_html:str):
    return load_template('summary_template.html').format(charts=charts_html, cards=cards_html, tags_summary=tags_summary_html)

def build_summary_charts(compliant_chart, non_compliant_chart) -> str:
    return load_template('summary_charts_template.html').format(compliant_chart=compliant_chart, non_compliant_chart=non_compliant_chart)

def build_subscription_tag_compliance_rows(area_names:list[str], area_compliance)->str:
    return "".join(
        f"<tr><td>{area}</td>"
        f"<td style='color:green'>{area_compliance[area].compliant}</td>"
        f"<td style='color:red'>{area_compliance[area].non_compliant}</td></tr>"
        for area in area_names
    )

def build_subscription_tag_summary(area_tag_compliance)->str:
    return load_template('subs_tags_area_template.html').format(area_tag_compliance=area_tag_compliance)

def generate_compliance_count_html(compliance_type, compliant_count, non_compliant_count):
    if compliance_type == COMPLIANT:
        return f"""(<span style="color:green">{compliant_count}</span>)"""
    return f"""(<span style="color:red">{non_compliant_count}</span>)"""

def build_resource_tooltip(res_id:str) -> str:
    return load_template('resource_tooltip_template.html').format(resource_id=res_id)

def build_group_resources(children, area_names: list[str]) -> str:
    sorted_areas = sorted(area_names, key=lambda area: area)
    areas_header = "".join(f"<th class='tag-area'>{area}</th>" for area in sorted_areas)

    rows = []
    for resource in children:
        tag_pills_html = generate_tag_pills_html(resource.tags)
        tooltip = build_resource_tooltip(resource.id)

        row = [f"""<tr>
            <td class='has-tooltip'>{resource.name}{tag_pills_html}{tooltip}</td>
        """]

        for area in sorted_areas:
            missing = "" if not resource.compliance else resource.compliance[area].required_missing
            area_tags_html = generate_tag_pills_html(missing, True)
            row.append(f"<td>{area_tags_html}</td>")

        row.append("</tr>")

        rows.append("".join(row))

    return load_template('subs_group_children_template.html').format(areas_header=areas_header, resource_rows="".join(rows))

def build_subscription_groups(title:str, groups: list[Group], area_names: list[str])-> str:
    if not groups:
        return f"<div><h3>{title} (0)</h3>No matching items found.</div>"

    content = load_template('subs_group_template.html')

    html_parts = [f"<div><h3>{title} ({len(groups)})</h3>"]

    for group in sorted(groups, key=lambda grp: grp.resource.name.lower().strip()):
        tag_pills_html = generate_tag_pills_html(group.resource.tags)

        count_html = generate_compliance_count_html(title, group.compliant_count, group.non_compliant_count)

        sorted_children = sorted(group.children, key=lambda res: res.name.lower().strip())
        children_html = build_group_resources(sorted_children, area_names)

        html_parts.append(content.format(
            group_name=group.resource.name,
            group_count=count_html,
            group_tags=tag_pills_html,
            group_children=children_html))

    html_parts.append("</div>")
    return "".join(html_parts)

def build_subscription(subscription_id:str, subscription_name:str, area_tag_compliance, area_names: list[str], groups: CompliantResources)->str:
    compliant_html = build_subscription_groups(COMPLIANT, groups.compliant, area_names)
    non_compliant_html = build_subscription_groups(NON_COMPLIANT, groups.non_compliant, area_names)

    return load_template('subs_template.html').format(sub_id=subscription_id,
                          sub_name=subscription_name,
                          area_tag_compliance=area_tag_compliance,
                          compliant_groups=compliant_html,
                          non_compliant_groups=non_compliant_html)

def build_landing_page(scan_date:str, scan_user:str, filter_used:str, styles:str, scripts:str, sidebar:str, summary:str, subscriptions:str):
    return load_template('landing_page_template.html').format(
        scan_datetime=scan_date,
        scan_user=scan_user,
        filter_used=filter_used,
        stylesheets=styles,
        scripts=scripts,
        sidebar=sidebar,
        overall_summary=summary,
        subscriptions=subscriptions)
