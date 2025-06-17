from pathlib import Path

from helper_tags import generate_tag_pills_html
from resource_compliance_checker import *


@dataclass
class SummaryChart:
    title: str
    data: str

@dataclass
class SummaryCard:
    title: str
    required: list[str]
    compliant_count: int
    non_compliant_count: int

def load_template(template_name: str) -> str:
    path = Path("templates") / template_name
    return path.read_text(encoding="utf-8")

def build_tags_list(tags: list[str])->str:
    return "<ul>" + "".join(["<li class='tag'><div class='aztag'></div>{tag}</li>".format(tag=tag) for tag in tags]) + "</ul>"

def build_cards(cards: list[SummaryCard]) -> str:
    content = load_template('card_template.html')

    return "".join([content.format(card_name=card.title,
                                     tag_list=build_tags_list(card.required),
                                     percent=card.compliant_count/card.non_compliant_count*100,
                                     compliant=card.compliant_count,
                                     non_compliant=card.non_compliant_count)
     for card in cards])


def build_tag_coverage(coverage: TagCoverage)-> str:
    if not coverage.sorted_tags:
        return "<h3>Tag Usage</h3><emphasis>No tags founds on the scanned resources.</emphasis>"

    content = load_template('tag_coverage_template.html')
    cov_required = load_template('tag_coverage_required_template.html')

    rows = "".join(
        ["<tr><td><div class='aztag'></div>{display}{required}</td><td>{total_count} ({percentage:.1f}%)</td></tr>"
        .format(
            total_count=coverage.stats_counter[key],
            display = coverage.tag_display_names[key],
            percentage = coverage.stats_counter[key] / coverage.total_resources * 100,
            required = cov_required if key in coverage.required_tags else "")
            for key, display_name in coverage.sorted_tags
        ])
    return content.format(tag_rows=rows,
                          total_count=len(coverage.sorted_tags),
                          total_resources=coverage.total_resources)


def build_sidebar_subscription_links(source: list[tuple[str, str]])->str:
    return "".join(
        [
            f"<a href='javascript:showSection(\"sub-{sub_id}\")'>{sub_name}</a>"
            for sub_name, sub_id in source
        ])

def build_sidebar(links)->str:
    return load_template('sidebar_template.html').format(links=links)

def build_summary(pie_charts: list[SummaryChart], cards: list[SummaryCard], coverage: TagCoverage) -> str:
    return (load_template('summary_template.html')
    .format(
        charts=build_summary_charts(pie_charts[0], pie_charts[1]),
        cards=build_cards(cards),
        tags_summary=build_tag_coverage(coverage)))

def build_summary_charts(chart_1: SummaryChart, chart_2: SummaryChart) -> str:
    return load_template('summary_charts_template.html').format(
        chart_title_1=chart_1.title,
        chart_data_1=chart_1.data,
        chart_title_2=chart_2.title,
        chart_data_2=chart_2.data)

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
    def parse_resource_id_tree(resource_id: str) -> list[dict]:
        """Parses an Azure resource ID into a list of dicts representing each hierarchical level."""
        parts = [p for p in resource_id.strip("/").split("/")]
        colors = [
            "#0057b7",  # blue
            "#2a9d8f",  # green
            "#e76f51",  # red-orange
            "#264653",  # dark teal
            "#8d99ae",  # slate
            "#f4a261",  # orange
            "#e9c46a",  # yellow
        ]

        html_lines = []
        indent = "  "

        html_lines.append('<ul class="resource-id-tree">')
        for i in range(0, len(parts), 2):
            key = parts[i]
            value = parts[i + 1] if i + 1 < len(parts) else ""
            color = colors[(i // 2) % len(colors)]

            html_lines.append(f'{indent * (i + 1)}<li>')
            html_lines.append(f'{indent * (i + 2)}<span style="color:{color}"><strong>{key}/</strong></span> {value}')
            if i + 2 < len(parts):
                html_lines.append(f'{indent * (i + 2)}<ul>')

        # close open <ul> tags
        for i in reversed(range(0, len(parts), 2)):
            if i + 2 < len(parts):
                html_lines.append(f'{indent * (i + 2)}</ul>')
            html_lines.append(f'{indent * (i + 1)}</li>')

        html_lines.append('</ul>')
        html_lines.append(f'<span>{resource_id}>')

        return "\n".join(html_lines)

    sorted_areas = sorted(area_names, key=lambda area: area)
    areas_header = "".join(f"<th class='tag-area'>{area}</th>" for area in sorted_areas)

    rows = []
    for resource in children:
        tag_pills_html = generate_tag_pills_html(resource.tags)
        tooltip = build_resource_tooltip(parse_resource_id_tree(resource.id))

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
