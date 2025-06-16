from helper_tags import generate_tag_pills_html
from resource_compliance_checker import *


def build_cards(name, tags_list, percent, compliant, non_compliant):
    with open('templates/card_template.html', 'r', encoding='utf-8') as file:
        content = file.read()
    return content.format(card_name=name, tag_list=tags_list, percent=percent, compliant=compliant, non_compliant=non_compliant)

def build_card_tags(tags)-> str:
    if not tags:
        return ""
    return "".join(f"<li>{tag}</li>" for tag in tags)

def build_sidebar_subscription_links(source)->str:
    return "".join(
        [
            f"<a href='javascript:showSection(\"sub-{sub_id}\")'>{sub_name}</a>"
            for sub_name, sub_id in source
        ])

def build_sidebar(links)->str:
    with open('templates/sidebar_template.html', 'r', encoding='utf-8') as file:
        content = file.read()
    return content.format(links=links)

def build_summary(charts_html, cards_html, tags_summary_html):
    with open('templates/summary_template.html', 'r', encoding='utf-8') as file:
        content = file.read()
    return content.format(charts=charts_html, cards=cards_html, tags_summary=tags_summary_html)

def build_summary_charts(compliant_chart, non_compliant_chart) -> str:
    with open('templates/summary_charts_template.html', 'r', encoding='utf-8') as file:
        content = file.read()
    return content.format(compliant_chart=compliant_chart, non_compliant_chart=non_compliant_chart)

def build_subscription_tag_compliance_rows(areas, area_compliance)->str:
    return "".join(
        f"<tr><td>{area.name}</td>"
        f"<td style='color:green'>{area_compliance[area.name].compliant}</td>"
        f"<td style='color:red'>{area_compliance[area.name].non_compliant}</td></tr>"
        for area in areas
    )

def build_subscription_tag_summary(area_tag_compliance)->str:
    with open('templates/subs_tags_area_template.html', 'r', encoding='utf-8') as file:
        content = file.read()
    return content.format(area_tag_compliance=area_tag_compliance)

def generate_compliance_count_html(compliance_type, compliant_count, non_compliant_count):
    if compliance_type == COMPLIANT:
        return f"""(<span style="color:green">{compliant_count}</span>)"""

    return f"""(<span style="color:red">{non_compliant_count}</span>)"""


def build_resource_tooltip(res_id) -> str:
    with open('templates/resource_tooltip_template.html', 'r', encoding='utf-8') as file:
        content = file.read()
    return content.format(resource_id=res_id)

def build_group_resources(children, area_names: list[str]) -> str:
    with open('templates/subs_group_children_template.html', 'r', encoding='utf-8') as file:
        content = file.read()

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

    return content.format(areas_header=areas_header, resource_rows="".join(rows))

def build_subscription_groups(title, groups: list[Group], area_names: list[str])-> str:
    if not groups:
        return f"<div><h3>{title} (0)</h3>No matching items found.</div>"

    with open('templates/subs_group_template.html', 'r', encoding='utf-8') as file:
        content = file.read()

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

def build_subscription(subscription_id, subscription_name, area_tag_compliance, area_names: list[str], groups: CompliantResources)->str:
    with open('templates/subs_template.html', 'r', encoding='utf-8') as file:
        content = file.read()

    compliant_html = build_subscription_groups(COMPLIANT, groups.compliant, area_names)
    non_compliant_html = build_subscription_groups(NON_COMPLIANT, groups.non_compliant, area_names)

    return content.format(sub_id=subscription_id,
                          sub_name=subscription_name,
                          area_tag_compliance=area_tag_compliance,
                          compliant_groups=compliant_html,
                          non_compliant_groups=non_compliant_html)
