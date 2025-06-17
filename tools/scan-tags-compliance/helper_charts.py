import base64
from collections import Counter
from io import BytesIO

from matplotlib import pyplot as plt


def create_pie_chart_base64(points, title: str) -> str:
    type_counts = Counter(points)
    top = type_counts.most_common(5)
    other_count = sum(count for _, count in type_counts.most_common()[5:])

    labels = [label for label, _ in top] + (["Other"] if other_count else [])
    sizes = [count for _, count in top] + ([other_count] if other_count else [])

    fig, ax = plt.subplots()
    ax.pie(sizes, labels=labels, autopct='%1.1f%%')
    ax.axis('equal')
    plt.title(title)

    buf = BytesIO()
    plt.savefig(buf, format="png")
    plt.close(fig)
    buf.seek(0)

    return base64.b64encode(buf.read()).decode("utf-8")
