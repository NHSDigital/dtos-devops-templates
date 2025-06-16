from dataclasses import dataclass
from types import SimpleNamespace
from typing import Iterator

TAG_AREAS = {
    "FinOps": {
        "required": ["TagVersion", "Programme ?? Service ", "Product ?? Project", "Owner", "CostCentre"],
        "optional": ["Customer"]
    },
    "SecOps": {
        "required": ["data_classification", "DataType", "Environment", "ProjectType", "PublicFacing"],
        "optional": []
    },
    "TechOps": {
        "required": ["ServiceCategory", "OnOffPattern"],
        "optional": ["BackupLocal", "BackupRemote"]
    },
    "DevOps": {
        "required": ["ReleaseVersion ?? Version", "BuildDate", "BuildTime", "ApplicationRole", "Name"],
        "optional": ["Stack", "Cluster", "Tool"]
    }
}

@dataclass
class ComplianceValues:
    required_present: str
    required_missing: str
    required_missed: int
    required_met: int
    optional_present: str
    optional_missing: str
    optional_missed: int
    optional_met: int
    total_required: int
    is_compliant: bool

class ComplianceAreas:
    @property
    def area_names(self) -> list[str]:
        return [item for item in self._areas]

    def __init__(self):
        self._areas = TAG_AREAS
        pass

    def __iter__(self) -> Iterator[SimpleNamespace]:
        return (
            SimpleNamespace(name=key, **value)
            for key, value in self._areas.items()
        )

    def __len__(self) -> int:
        return len(self._areas)

    def __getitem__(self,key) -> SimpleNamespace:
        return SimpleNamespace(name=key, **self._areas[key])
