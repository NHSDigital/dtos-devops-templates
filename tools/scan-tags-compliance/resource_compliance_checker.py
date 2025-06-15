from collections import defaultdict
from typing import Any

from resource_compliance_areas import ComplianceAreas, ComplianceValues
from resource_scanner import ResourceScanner, ResourceRecord


def classify_tags(tag_list, resource, required_missing, required_present):
    """Determines the number of required and missing tags from the specified resource's 'tags' property."""
    for tag in tag_list:
        if "??" in tag:
            options = [r.strip() for r in tag.split("??")]
            found = next((opt for opt in options if opt in resource.tags), None)
            if found:
                required_present.append(tag)
            else:
                required_missing.append(tag)
        else:
            if tag in resource.tags:
                required_present.append(tag)
            else:
                required_missing.append(tag)

class ResourceComplianceChecker:
    """Checks each resource's tags for complianceCheck to the tag strategies provided."""

    def __init__(self):
        self.compliant_resources = []
        self.non_compliant_resources = []
        self.compliant_areas = defaultdict(list)
        self.non_compliant_areas = defaultdict(list)

    def check_compliance(self, scanner: ResourceScanner, areas: ComplianceAreas):
        for area in areas:
            required = area.required
            optional = area.optional

            for name, resource in scanner:
                required_present = []
                required_missing = []
                optional_present = []
                optional_missing = []

                classify_tags(required, resource, required_missing, required_present)
                classify_tags(optional, resource, optional_missing, optional_missing)

                if not resource.compliance:
                    resource.compliance = defaultdict(dict)

                value = ComplianceValues (
                    required_present = ", ".join(required_present),
                    required_missing = ", ".join(required_missing),
                    required_missed = len(required_missing),
                    required_met = len(required_present),
                    optional_present = ", ".join(optional_present),
                    optional_missing = ", ".join(optional_missing),
                    optional_missed = len(optional_missing),
                    optional_met = len(optional_present),
                    total_required = len(required),
                    is_compliant = len(required_present) >= len(required)
                )

                resource.compliance[area.name] = value

                if value.is_compliant:
                    self.compliant_resources.append(resource)
                    self.compliant_areas[area.name].append(resource)
                else:
                    self.non_compliant_resources.append(resource)
                    self.non_compliant_areas[area.name].append(resource)


    def compliant_groups_by_subscription(self, subscription_id):
        non_compliant_group_ids = {
            res.group_id for res in self.non_compliant_resources if res.group_id
        }

        return [group
                for group in self.compliant_resources
                if group.is_group and group.subscription_id == subscription_id and group.id not in non_compliant_group_ids
        ]

    def non_compliant_groups_by_subscription(self, subscription_id):
        compliant_group_ids = {
            res.group_id for res in self.compliant_resources if res.group_id
        }

        return [group
                for group in self.non_compliant_resources
                if group.is_group and group.subscription_id == subscription_id and group.id not in compliant_group_ids
        ]

    def count_compliant_resources_by_area(self, area_name) -> int:
        return len(self.compliant_areas[area_name])

    def count_non_compliant_resources_by_area(self, area_name) -> int:
        return len(self.non_compliant_areas[area_name])

    def get_resources_by_area(self, area_name: str) -> list[ResourceRecord]:
        return [item for item in (self.compliant_areas[area_name] + self.non_compliant_areas[area_name]).values()]

