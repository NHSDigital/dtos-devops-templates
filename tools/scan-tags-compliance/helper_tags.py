import json

MAX_PILL_LENGTH = 50

def format_tag_pill(key, value: any = None, required: bool = False):
    value_str = f"{key}={value}" if value is not None else key
    style = "pill required" if required else "pill"

    if len(value_str) > MAX_PILL_LENGTH:
        return f"<span class='{style}' title='{value_str}'>{value_str[:MAX_PILL_LENGTH - 3]}...</span>"

    return f"<span class='{style}'>{value_str}</span>"

def generate_tag_pills_html(tags, required: bool = False):
    if not tags:
        return ""

    res_tags = {}
    if isinstance(tags, str):
        try:
            res_tags = json.loads(tags)
        except json.JSONDecodeError:
            res_tags = {part.strip(): None for part in tags.split(",") if part.strip()}

    visible_tags = {key: val for key, val in res_tags.items() if not key.startswith("hidden-link:")}
    html = "".join(format_tag_pill(key, val, required) for key, val in sorted(visible_tags.items()))
    return f"""<span class='tag-pills'>{html}</span>"""

