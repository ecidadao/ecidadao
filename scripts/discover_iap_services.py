#!/usr/bin/env python3
"""Read the public iAP catalogue metadata; this does not invoke listed services."""
import json
import sys
from datetime import datetime, timezone
from urllib.request import Request, urlopen

BASE = "https://api.iap.gov.pt/publicapi/api/Service/GetByFilter"


def discover():
    services = {}
    for page in range(1, 101):
        url = f"{BASE}?PageSize=100&PageNumber={page}"
        request = Request(url, headers={"Accept": "application/json", "User-Agent": "eCidadao-catalogue-research/1.0"})
        with urlopen(request, timeout=30) as response:
            payload = json.load(response)
        items, total = payload["items"], payload["totalItems"]
        previous = len(services)
        for item in items:
            service_id = item["serviceId"]
            services[service_id] = {
                "id": service_id,
                "name": item["serviceName"].strip(),
                "provider": item["entityName"],
                "catalogue_url": f"https://www.iap.gov.pt/web/iap/details?id={service_id}",
            }
        if len(services) >= total:
            return {
                "checked_at": datetime.now(timezone.utc).isoformat(),
                "source": BASE,
                "scope": "Catalogue metadata only; access to transactional services is not established.",
                "total": total,
                "services": sorted(services.values(), key=lambda item: item["id"]),
            }
        if len(services) == previous:
            raise ValueError("Catalogue pagination made no progress; refusing an incomplete inventory")
    raise ValueError("Catalogue exceeded the pagination limit")


if __name__ == "__main__":
    json.dump(discover(), sys.stdout, ensure_ascii=False, indent=2)
    print()
