from collections import defaultdict

from resource_compliance_areas import ComplianceAreas, ComplianceValues
from resource_scanner import ResourceScanner

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
        self.compliance_data = defaultdict(dict)

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

                resource.compliance[area.name] = ComplianceValues (
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

