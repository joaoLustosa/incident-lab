# Incident Lab

Incident Lab is a lightweight infrastructure troubleshooting platform that injects controlled failures into a Linux environment and challenges users to diagnose and restore service.

The platform provides repeatable incident-response exercises focused on service recovery, root cause analysis, and operational troubleshooting using standard Linux administration tools.

Incident Lab manages its own application, service configuration, incident catalog, recovery assets, and runtime state, allowing users to install a fully functional troubleshooting environment on a clean Debian system.

---

## Safety Notice

Incident Lab intentionally modifies services and configuration files managed by the platform.

Use only in disposable lab environments.

Do not install on production systems or systems hosting important workloads.

---

## Architecture

```text
User
  ↓
Nginx
  ↓
FastAPI
```

Components:

- Debian 13
- Nginx
- FastAPI
- Uvicorn
- systemd

---

## Demo

Terminal recording:

https://asciinema.org/a/0ETbpW4vQ36xKYkI

---

## Installation

Clone the repository and run the installer:

```bash
git clone https://github.com/joaoLustosa/incident-lab.git

cd incident-lab

sudo ./install.sh
```

The installer automatically:

- Installs required packages
- Creates the runtime environment
- Creates the service account
- Deploys the FastAPI application
- Deploys the systemd service
- Deploys the Nginx configuration
- Deploys the incident catalog
- Deploys recovery assets
- Creates operational commands
- Validates environment health

---

## Usage

Create an incident:

```bash
sudo incident-start
```

Review the active incident:

```bash
incident-reveal
```

Reset the environment:

```bash
sudo incident-reset
```

Remove Incident Lab:

```bash
sudo incident-lab-uninstall
```

Only one active incident may exist at a time.

Attempting to start a new incident while another is active will result in:

```text
ERROR: Active incident detected.

Run incident-reset before starting a new incident.
```

---

## Runtime Layout

Incident Lab is installed as a self-contained application:

```text
/opt/incident-lab
├── app
├── baseline
├── config
├── incidents
├── incident-state
├── logs
└── venv
```

Global commands are exposed through `/usr/local/bin`:

```text
incident-start
incident-reveal
incident-reset
incident-lab-uninstall
```

The source repository may be removed after installation.

---

## Configuration

Incident Lab uses a centralized configuration file located at:

```text
/opt/incident-lab/config/lab.conf
```

The current configuration defines shared runtime values including:

- FastAPI service name
- FastAPI port
- Nginx site name
- Health check URL
- Incident selection mode

Operational scripts read this file at runtime, reducing hardcoded environment values. Incident selection mode currently only allows for "random". Shuffle-bag mode will be implemented in a future version.

---

## Incident Workflow

Every incident follows the same lifecycle:

```text
Healthy Environment
       ↓
Inject Incident
       ↓
Display Ticket
       ↓
Investigation
       ↓
Incident Review
       ↓
Environment Reset
       ↓
Health Verification
```

The environment is restored to a known-good state after every exercise.

---

## Incident Catalog

| ID | Title | Category | Difficulty |
|----|-------------------------------|---------------|------------|
|001|FastAPI Service Stopped|Service|Easy|
|002|Nginx Service Stopped|Service|Easy|
|003|Incorrect Nginx Upstream|Configuration|Medium|
|004|Nginx Syntax Error|Configuration|Medium|
|005|FastAPI Syntax Error|Application|Medium|
|006|Incorrect FastAPI Port|Configuration|Easy|
|007|Incorrect systemd WorkingDirectory|Systemd|Medium|
|008|Missing Application File|Application|Medium|
|009|Invalid systemd ExecStart|Systemd|Medium|
|010|Nginx Default Site Enabled|Configuration|Easy|

---

## Recovery Model

Incident Lab uses baseline-driven recovery.

Environment restoration does not depend on incident-specific rollback logic.

Recovery workflow:

```text
Restore Baseline
       ↓
Validate Configuration
       ↓
Restart Services
       ↓
Verify Health
       ↓
Clear Incident State
```

The environment is considered healthy only when:

- Nginx is active
- FastAPI is active
- Nginx configuration passes validation
- HTTP requests succeed through Nginx

If recovery validation fails, the active incident remains locked and new incidents cannot be started until the environment is repaired.

---

## Project Structure

Repository structure:

```text
incident-lab/
├── baseline/
│   ├── app/
│   ├── nginx/
│   └── systemd/
├── config/
├── incidents/
├── INCIDENT_AUTHORING.md
├── incident-start
├── incident-reset
├── incident-reveal
├── healthcheck.sh
├── install.sh
├── uninstall.sh
└── README.md
```

Each incident follows a standardized structure:

```text
incident-name/
├── incident.sh
└── incident.meta
```

`incident.sh` contains the fault injection logic.

`incident.meta` defines:

- ID
- TITLE
- CATEGORY
- DIFFICULTY
- TICKET
- ROOT_CAUSE
- EXPECTED_FINDINGS
- EXPECTED_COMMANDS

---

## Baseline Ownership

Any resource modified by an incident must have a corresponding healthy version managed by Incident Lab.

The baseline directory is the authoritative source of truth for environment recovery.

Current managed resources:

```text
baseline/
├── app/main.py
├── nginx/incident-lab.conf
└── systemd/fastapi.service
```

This model provides deterministic recovery and prevents configuration drift as the incident catalog grows.

---

## Engineering Principles

Incident Lab is built around several core design decisions:

- Bash-first implementation
- Single-host architecture
- Metadata-driven incident reviews
- Standardized incident contract
- Centralized configuration
- Deterministic recovery
- Active incident locking
- Runtime self-containment
- Repository-independent operation
- Baseline-driven restoration

---

## Roadmap

Planned improvements include:

- Cloud deployment using Terraform
- Multi-node troubleshooting environments
- Shuffle-bag incident selection
- Category-based incident filtering
- Manual incident selection
- Expanded incident catalog
- Automated regression testing
- Support for additional Linux distributions

---

## Current Status

Incident Lab currently provides:

- Automated installation on Debian 13
- Self-contained runtime environment
- Centralized configuration
- Ten troubleshooting incidents
- Metadata-driven incident reviews
- Baseline-driven recovery
- Health verification
- Standardized incident authoring
- Repository-independent operation
- Clean uninstallation
