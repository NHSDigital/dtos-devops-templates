import json
from collections import defaultdict
from dataclasses import dataclass
from typing import Counter

from resource_compliance_areas import ComplianceAreas, ComplianceValues
from resource_scanner import ResourceScanner, ResourceRecord

COMPLIANT = "Compliant"
NON_COMPLIANT = "Non-Compliant"

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

@dataclass
class ComplianceCount:
    compliant: int
    non_compliant: int

class Group:
    resource: ResourceRecord
    children: list[ResourceRecord]

    def __init__(self, resource: ResourceRecord, children: list[ResourceRecord]):
        self.resource = resource
        self.children = children

    @property
    def compliant_count(self)->int:
        return len([item for item in self.children if item.is_fully_compliant])

    @property
    def non_compliant_count(self)->int:
        return len([item for item in self.children if not item.is_fully_compliant])

@dataclass
class CompliantResources:
    compliant: list[Group]
    non_compliant: list[Group]

    def count_compliance_for_area(self, area_name: str) -> tuple[int, int]:
        compliant = 0
        non_compliant = 0

        for grp in (self.compliant + self.non_compliant):
            for child in grp.children:
                if child.is_compliant_for_area(area_name):
                    compliant += 1
                else:
                    non_compliant += 1

        return compliant, non_compliant

@dataclass
class TagCoverage:
    stats_counter: Counter
    tag_display_names: dict
    sorted_tags : list
    required_tags: set
    total_resources: int


class ResourceComplianceChecker:
    """Checks each resource's tags for complianceCheck to the tag strategies provided."""

    def __init__(self, areas: ComplianceAreas):
        self.compliant_resources = []
        self.non_compliant_resources = []
        self.compliant_areas = defaultdict(list)
        self.non_compliant_areas = defaultdict(list)
        self.areas = areas

    def check_compliance(self, scanner: ResourceScanner):
        for name, resource in scanner:
            if not resource.compliance:
                resource.compliance = defaultdict(dict)

            for area in self.areas:
                required = area.required
                optional = area.optional

                required_present = []
                required_missing = []
                optional_present = []
                optional_missing = []

                classify_tags(required, resource, required_missing, required_present)
                classify_tags(optional, resource, optional_missing, optional_missing)

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
                    self.compliant_areas[area.name].append(resource)
                else:
                    self.non_compliant_areas[area.name].append(resource)

            if resource.is_fully_compliant:
                self.compliant_resources.append(resource)
            else:
                self.non_compliant_resources.append(resource)

    def get_resources_by_group(self, id):
        return [item
                for item in (self.compliant_resources + self.non_compliant_resources)
                if item.group_id == id]

    def groups_by_subscription(self, subscription_id) -> CompliantResources:
        non_compliant = [
            Group(resource=group, children=self.get_resources_by_group(group.id))
            for group in self.non_compliant_resources
            if group.is_group and group.subscription_id==subscription_id
        ]

        compliant = [
            Group(resource=group, children=self.get_resources_by_group(group.id))
            for group in self.compliant_resources
            if group.is_group and group.subscription_id == subscription_id
        ]

        return CompliantResources(compliant=compliant, non_compliant=non_compliant)

    def non_compliant_groups_by_subscription(self, subscription_id):
        compliant_group_ids = {
            res.group_id for res in self.compliant_resources if res.group_id and res.subcription_id == subscription_id
        }

        return [group
                for group in self.non_compliant_resources
                if group.is_group and group.subscription_id == subscription_id and group.id not in compliant_group_ids
        ]

    def count_compliance_by_areas(self, groups: CompliantResources = None)->dict[ComplianceCount]:
        compliance = defaultdict(ComplianceCount)

        if groups is None:
            for area in self.areas:
                cc = ComplianceCount(
                    compliant = sum(self.count_compliant_resources_by_parent(area.name, res.id) for res in self.compliant_resources),
                    non_compliant = sum(self.count_non_compliant_resources_by_parent(area.name, res.id) for res in self.non_compliant_resources)
                )
                compliance[area.name] = cc
        else:
            for area in self.areas:
                compliant, non_compliant = groups.count_compliance_for_area(area.name)
                compliance[area.name] = ComplianceCount(
                    compliant=compliant,
                    non_compliant=non_compliant
                )

        return compliance


    def count_compliant_resources_by_area(self, area_name) -> int:
        return len(self.compliant_areas[area_name])

    def count_non_compliant_resources_by_area(self, area_name) -> int:
        return len(self.non_compliant_areas[area_name])

    def count_compliant_resources_by_parent(self, area_name, res_id):
        return len([res for res in self.compliant_areas[area_name] if res.group_id == res_id])

    def count_non_compliant_resources_by_parent(self, area_name, res_id):
        return len([res for res in self.non_compliant_areas[area_name] if res.group_id == res_id])

    def get_resources_by_area(self, area_name: str) -> list[ResourceRecord]:
        return [item for item in (self.compliant_areas[area_name] + self.non_compliant_areas[area_name])]

    def get_tag_coverage(self) -> TagCoverage:

        def get_tags_dict(tags) -> dict:
            """Ensures the supplied tags is returned as a dictionary."""
            if isinstance(tags, str):
                try:
                    return json.loads(tags)
                except json.JSONDecodeError:
                    return {}
            elif isinstance(tags, dict):
                return tags
            else:
                return {}

        """Counts tags applied to groups and resources, case-insensitively,
        and returns display mapping for original casing."""
        tag_counter = Counter()
        display_names = {}

        resources = (self.compliant_resources + self.non_compliant_resources)
        for res in resources:
            for tag in get_tags_dict(res.tags):
                lower_tag = tag.lower().strip()
                tag_counter[lower_tag] += 1
                if lower_tag not in display_names:
                    display_names[lower_tag] = tag

        # add compliance tags too, but exclude them if they already in the counter
        required_tags = {req.lower() for area in self.areas for req in area.required}
        tag_counter.update({tag: 0 for tag in required_tags - tag_counter.keys()})

        display_names.update({req.lower(): req for area in self.areas for req in area.required})

        # we want to sort the counted tags by count, then name so's it's easier to read for the
        # same count value. item[1] is the count value, and item[0] is the name
        sorted_tags = sorted(
            tag_counter.items(),
            key=lambda item: (-item[1], item[0])
        )

        return TagCoverage(
            stats_counter=tag_counter,
            tag_display_names=display_names,
            sorted_tags = sorted_tags,
            required_tags = required_tags,
            total_resources = len(resources)
        )
