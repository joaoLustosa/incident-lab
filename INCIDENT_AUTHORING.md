# Incident Authoring Guide

This document defines the standards and requirements for creating incidents in Incident Lab.

All incidents must follow the same structure, metadata format, behavioral rules, and difficulty classification system.

The goal is to ensure consistency across the incident catalog and guarantee compatibility with the Incident Lab runtime and recovery mechanisms.

---

# Incident Structure

Every incident must be self-contained and stored in its own directory.

Example:

```text
001-stop-fastapi/
├── incident.sh
└── incident.meta
```

## incident.sh

Contains the fault injection logic.

Responsibilities:

- Introduce a specific fault into the environment
- Exit successfully when the fault is injected
- Return a non-zero exit code on failure

Example:

```bash
#!/bin/bash

systemctl stop fastapi
```

---

## incident.meta

Contains metadata used by Incident Lab to generate tickets and incident reviews.

Example:

```bash
TITLE="FastAPI Service Stopped"

CATEGORY="service"

DIFFICULTY="Easy"

TICKET="Users report the application is unavailable."

ROOT_CAUSE="The FastAPI service was stopped."

EXPECTED_FINDINGS="fastapi service inactive"

EXPECTED_COMMANDS="systemctl status fastapi,journalctl -u fastapi"
```

---

# Required Metadata Fields

Every incident must define all of the following fields.

## TITLE

Human-readable incident name.

Example:

```bash
TITLE="Nginx Syntax Error"
```

---

## CATEGORY

Category of the incident.

Allowed values:

```text
service
configuration
application
network
systemd
```

Example:

```bash
CATEGORY="service"
```

Categories are used to group incidents by troubleshooting domain and may be used by future incident selection modes.

### Category Guidelines

| Category | Description |
|-----------|-------------|
| service | Service state problems such as stopped or disabled services |
| configuration | Invalid or incorrect configuration files |
| application | Application-level failures and runtime errors |
| network | Connectivity and request routing issues |
| systemd | Service unit configuration and startup failures |

---

## DIFFICULTY

Incident difficulty classification.

Allowed values:

```text
Easy
Medium
Hard
```

---

## TICKET

Problem statement presented to the user when the incident is generated.

Example:

```bash
TICKET="Users report 502 Bad Gateway responses."
```

---

## ROOT_CAUSE

Short explanation of the actual failure introduced by the incident.

Example:

```bash
ROOT_CAUSE="Nginx was configured with an invalid upstream port."
```

---

## EXPECTED_FINDINGS

Evidence a user should discover during investigation.

Example:

```bash
EXPECTED_FINDINGS="Nginx upstream points to localhost:9000"
```

---

## EXPECTED_COMMANDS

Commands likely to assist in diagnosis.

Multiple commands should be comma-separated.

Example:

```bash
EXPECTED_COMMANDS="nginx -t,cat /etc/nginx/sites-available/incident-lab.conf"
```

---

# Incident Requirements

Every incident must satisfy the following requirements.

## Self-Contained

An incident must contain everything required for fault injection and review.

Dependencies on external incident files are not permitted.

---

## Deterministic

The same incident must always produce the same failure condition.

Avoid behavior that depends on timing, randomness, or environmental variability.

---

## Recoverable

Every incident must be fully recoverable through:

```bash
incident-reset
```

No manual intervention should be required.

---

## Incident Lab Ownership Rule

An incident may only modify resources owned and managed by Incident Lab.

Examples:

```text
/opt/incident-lab
/etc/nginx/sites-available/incident-lab.conf
/etc/systemd/system/fastapi.service
```

Avoid modifying unrelated operating system resources.

---

## Failure Handling

An incident script must return a non-zero exit code if injection fails.

Example:

```bash
if ! systemctl stop fastapi; then
    exit 1
fi
```

---

# Difficulty Standards

Difficulty classifications should remain consistent across the catalog.

---

## Easy

Characteristics:

- Single-component failure
- Single root cause
- Can typically be diagnosed using one or two commands
- Minimal configuration analysis required

Examples:

- Service stopped
- Service disabled
- Process not running

Typical investigation commands:

```text
systemctl status
journalctl
```

---

## Medium

Characteristics:

- Requires configuration inspection
- Requires understanding of service interactions
- Multiple investigative steps
- Root cause not immediately visible from service status alone

Examples:

- Incorrect reverse proxy configuration
- Invalid service configuration
- Broken application settings

Typical investigation commands:

```text
systemctl status
journalctl
cat
less
grep
nginx -t
```

---

## Hard

Characteristics:

- Multiple components involved
- Root cause may span services
- Requires correlation of logs, configuration, and system state
- Requires reasoning about request flow or service dependencies

Examples:

- Cascading failures
- Multi-service misconfiguration
- Failures requiring evidence from multiple sources

Typical investigation commands:

```text
systemctl
journalctl
curl
ss
cat
grep
nginx -t
```

---

# Baseline Ownership Rule

Any resource modified by an incident must have a corresponding healthy baseline managed by Incident Lab.

Examples:

```text
baseline/app/main.py
baseline/nginx/incident-lab.conf
baseline/systemd/fastapi.service
```

The baseline directory is the authoritative source of truth for environment recovery.

---

# Incident Testing Procedure

Before adding a new incident to the catalog:

1. Install Incident Lab on a clean environment.
2. Execute the incident.
3. Verify the expected fault occurs.
4. Verify the ticket displays correctly.
5. Verify the review displays correctly.
6. Execute:

```bash
incident-reset
```

7. Verify health checks succeed.
8. Verify incident state is cleared.
9. Repeat the process at least once.

An incident should not be added to the catalog until the complete lifecycle has been validated.

---

# Incident Lifecycle

Every incident is expected to follow the same operational flow.

```text
Healthy Environment
       ↓
Inject Incident
       ↓
Display Ticket
       ↓
User Investigation
       ↓
Incident Review
       ↓
Environment Reset
       ↓
Health Verification
       ↓
Clear Incident State
```

All incidents must remain compatible with this lifecycle.
