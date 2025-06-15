
import csv
import json
import sys
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import datetime
from typing import Iterator, Counter, DefaultDict

from azure.core.exceptions import HttpResponseError
from azure.identity import AzureCliCredential
from azure.mgmt.resource import SubscriptionClient, ResourceManagementClient

from resource_compliance_areas import ComplianceValues
from resource_filter import ResourceFilter


@dataclass
class ResourceRecord:
    id: str
    name: str
    location: str = ""
    tags: str = ""
    resourceType: str = ""
    parent_id: str = ""
    group_id: str = ""
    subscription_id: str = ""
    # Ensure we default instantiate this property when accessed
    compliance: DefaultDict[str, ComplianceValues] = field(default_factory=lambda: defaultdict(ComplianceValues))

    @property
    def is_group(self) -> bool:
        return bool(self.subscription_id and not self.group_id and self.id)

    @property
    def is_resource(self) -> bool:
        return bool(self.subscription_id and self.group_id and self.id)

    @property
    def is_fully_compliant(self) -> bool:
        """Returns true if this resource is compliant to all compliance areas, False otherwise."""
        if not self.compliance:
            return False

        return all(values.is_compliant for area_name, values in self.compliance.items())

    def is_compliant_for_area(self, area_name: str) -> bool:
        """Returns True if this resource is compliant for a given area, False otherwise."""
        if not self.compliance:
            return False
        return area_name in self.compliance and self.compliance[area_name].is_compliant


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

class ResourceScanner:
    def __init__(self, res_filter: ResourceFilter):
        self.filter = res_filter
        self._subscriptions: defaultdict[str, ResourceRecord] = defaultdict(ResourceRecord)
        self._groups: defaultdict[str, ResourceRecord] = defaultdict(ResourceRecord)
        self._resources: defaultdict[str, ResourceRecord] = defaultdict(ResourceRecord)
        self.skipped = []
        self.scan_datetime = datetime.now()
        self.scan_user = "(not known)"

    def scan_resources(self) -> None:
        credential = AzureCliCredential()
        subscription_client = SubscriptionClient(credential)

        for sub in subscription_client.subscriptions.list():
            sub_id = sub.subscription_id
            sub_name = sub.display_name

            if not self.filter.any_subscription(sub_name) or not self.filter.any_text(sub_name):
                continue

            print(f"\n🔍 Scanning subscription: {sub_name} ({sub_id})")

            try:
                resource_client = ResourceManagementClient(credential, sub_id)
            except Exception as e:
                self.skipped.append(f"Subscription: {sub_id} - ERROR: {e}")
                continue

            try:
                resource_groups = list(resource_client.resource_groups.list())
            except HttpResponseError as e:
                self.skipped.append(f"Subscription: {sub_id} - Resource Groups - ERROR: {e.message}")
                continue

            for rg in resource_groups:
                rg_name = rg.name
                rg_location = rg.location
                rg_tags = rg.tags or {}

                if not self.filter.any_group(rg_name) or not self.filter.any_text(rg_name):
                    continue

                print(f"  - Resource Group: {rg_name}")

                try:
                    resources = list(resource_client.resources.list_by_resource_group(rg_name))
                except HttpResponseError as e:
                    self.skipped.append(f"Subscription: {sub_id} - Resource Group: {rg_name} - Resources - ERROR: {e.message}")
                    continue

                if not sub_id in self._subscriptions:
                    self._subscriptions[sub_id] = ResourceRecord(
                        id=sub_id,
                        name=sub_name
                    )

                if not rg.id in self._groups:
                    self._groups[rg.id] = ResourceRecord(
                        id=rg.id,
                        name=rg_name,
                        location=rg_location,
                        tags=json.dumps(rg_tags),
                        subscription_id=sub_id
                    )

                for resource in resources:
                    if not self.filter.any_resource(resource.name) or not self.filter.any_text(resource.name):
                        continue

                    tags = resource.tags or {}
                    self._resources[resource.id] = ResourceRecord(
                        id = resource.id,
                        name = resource.name,
                        location = rg.location,
                        tags = json.dumps(tags),
                        resourceType=resource.type,
                        group_id=rg.id,
                        subscription_id=sub_id
                    )

    @property
    def resources(self) -> Iterator[ResourceRecord]:
        return iter(self._resources.values())

    @property
    def groups(self) -> Iterator[ResourceRecord]:
        return iter(self._groups.values())

    @property
    def subscriptions(self) -> Iterator[ResourceRecord]:
        return iter(self._subscriptions.values())

    def load_from_file(self, filename):
        """Load a previous scan's results into this instance."""
        try:
            with open(filename, mode='r', encoding='utf-8') as file:
                reader = csv.DictReader(file)
                self._resources = [
                    row for row in reader
                    if self.filter.any(row['resourceName'].lower())
                ]
        except FileNotFoundError:
            print(f"[ERROR] File not found: {filename}")
            sys.exit(1)

    def get_resource(self, resource_id) -> ResourceRecord:
        return next((item for key, item in self._resources.items() if item.id == resource_id), None)

    def count_all_resource_tags(self) -> tuple[Counter, dict[str, str]]:
        """Counts tags applied to groups and resources, case-insensitively,
        and returns display mapping for original casing."""
        counter = Counter()
        display_names = {}

        for res in (self._groups | self._resources).values():
            for tag in get_tags_dict(res.tags):
                lower_tag = tag.lower().strip()
                counter[lower_tag] += 1
                if lower_tag not in display_names:
                    display_names[lower_tag] = tag

        return counter, display_names

    def count_compliant_for_area(self, area_name, group_id):
        resources = self.get_resources_by_group(group_id)
        return sum(1 for res in resources.values() if res.is_compliant_for_area(area_name))

    def count_non_compliant_for_area(self, area_name, group_id):
        resources = self.get_resources_by_group(group_id)
        return sum(1 for res in resources if not res.is_compliant_for_area(area_name))

    def get_resources_by_area(self, area_name):
        return [
            item for item in (self._groups | self._resources).values()
            if item.compliance and area_name in item.compliance
        ]

    def get_resources_by_group(self, group_id: str) -> list[ResourceRecord]:
        return [
            item for res_id, item in self._resources.items()
            if item.group_id == group_id
        ]

    def is_fully_compliant_for_area(self, group_resource: ResourceRecord, area_name)-> bool:
        """Returns True is this resource is compliant with the specified area,
        or if this is a group, both it and its containing resources are compliant to the specified area, False otheriwse
        """
        # This is either a group or a subscription
        if group_resource.is_group:
            members = [res for res in self._resources.values() if res.group_id == group_resource.id]
            return all(member.is_compliant_for_area(area_name) for member in members)

        return group_resource.is_compliant_for_area(area_name)


    def is_fully_compliant_for_group(self, group_id) -> bool:
        """Returns True if all resources contained by this group are fully compliant for all compliance areas, False otherwise."""
        return all(record for record in (self._groups | self._resources).values()
                   if record.group_id == group_id and record.is_fully_compliant)

    def __iter__(self):
        return iter((self._groups | self._resources).items())

    def __getitem__(self, index) -> ResourceRecord:
        return self._resources[index]

    def __len__(self) -> int:
        return len(self._subscriptions) + len(self._groups) + len(self._resources)
