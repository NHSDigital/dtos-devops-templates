import base64
import csv
import gzip
import json
import os

from resource_scanner import ResourceScanner

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

def get_output_folder(source) -> str:
    if os.path.dirname(source):
        output_path = source
    else:
        output_dir = os.path.join(SCRIPT_DIR, "scan-results")
        os.makedirs(output_dir, exist_ok=True)
        output_path = os.path.join(output_dir, source)

    # Ensure the output directory exists
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    return output_path


def to_dict(x):
    return vars(x) if hasattr(x, "__dict__") else x

def build_lines(scanner):
    lines = []
    for name, resource in scanner:
        areas = resource.compliance
        flat_areas = {
            f"{area}_{k}": v
            for area, ns in areas.items()
            for k, v in to_dict(ns).items()
        }
        csv_row = {**vars(resource), **flat_areas}
        lines.append(csv_row)

    return lines

def write_outputs(scanner: ResourceScanner, output_filename):
    """Writes all scanned resources and their complianceCheck status to a comma-separated file"""

    folder = get_output_folder(output_filename)

    if len(scanner) == 0:
        print(f"ℹ️  No outputs saved because either no resources were scanned or the current filter returned no resources.")
        return

    lines = build_lines(scanner)

    csv_header = to_dict(lines[0])
    with open(folder, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=csv_header.keys())
        writer.writeheader()
        writer.writerows(lines)

    # Write skipped log to same directory as output
    skipped_log_path = os.path.join(os.path.dirname(folder), "azure_skipped_items.log")
    with open(skipped_log_path, "w") as f:
        for line in scanner.skipped:
            f.write(line + "\n")

    print(f"✅ Scanned resource outputs saved to '{folder}'. Skipped resource outputs saved to '{skipped_log_path}'")
