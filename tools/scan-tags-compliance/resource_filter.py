from collections import defaultdict

class ResourceFilter:
    def __init__(self, filter_str: str = ""):
        self._data = defaultdict(list)
        self._parse(filter_str)

    def _parse(self, filter_str: str):
        if not filter_str:
            return

        for pair in filter_str.strip().split():
            if '=' in pair:
                key, value = pair.split('=', 1)
                key = key.strip().lower()
                if not key in ['sub', 'group', 'res']:
                    print(f"Unknown filter category '{key}'. Will not be added to the filter")
                    continue

                value = value.strip()
                self._data[key].append(value)
            else:
                self._data["any"].append(pair)

    def any_subscription(self, item):
        """Returns True if the specified item is in the subscriptions filter or there are no subscription filters specified."""
        return self._any_in(item, "sub")

    def _any_in(self, item, key):
        items = self._data.get(key, [])
        return not items or any(s.lower() in item.lower() for s in items)

    def any_group(self, item):
        """Returns True if the specified item is in the groups filter or there are no group filters specified."""
        return self._any_in(item, "group")

    def any_resource(self, item):
        """Returns True if the specified item is in the resource filter or there are no resource filters specified."""
        return self._any_in(item, "res")

    def any_text(self, item):
        """Returns True if the specified item contains any text or there are no any_text filters specified."""
        return self._any_in(item, "any")

    def any(self, item):
        """Returns True if the specified item is in any filterable set."""
        return any(item in values for values in self._data.values())

    def to_friendly(self):
        """Returns a human-readable summary of the active filters."""
        if not any(self._data.values()):
            return "No filters applied"

        parts = []
        for key, values in self._data.items():
            if values:
                label = {
                    "sub": "Subscriptions",
                    "group": "Resource Groups",
                    "res": "Resources",
                    "any": "Any text"
                }.get(key, key.capitalize())
                parts.append(f"{label} containing {', '.join([f'\"{v}\"' for v in values])}")

        return " | ".join(parts)
