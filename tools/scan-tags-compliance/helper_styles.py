def build_html_styles() -> str:
    with open('assets/scan_report.css', 'r', encoding='utf-8') as file:
        content = file.read()
    return f"""<style>
        {content}
        </style>"""

def build_html_scripts():
    with open('assets/scan_report.js', 'r', encoding='utf-8') as file:
        content = file.read()
    return f"""
        <script>
        {content}
        </script>"""

