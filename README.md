# Incident Lab

Incident Lab is a lightweight infrastructure incident response and troubleshooting training platform.

The project intentionally injects faults into a functioning Linux environment and presents the user with a service ticket. The user must investigate the environment, identify the root cause, restore service, and review the incident.

Unlike deployment-focused homelabs, Incident Lab focuses on operational troubleshooting, evidence gathering, service recovery, and root cause analysis using standard Linux administration tools.

Version 1 intentionally remains small and constrained in order to validate the core troubleshooting loop before expanding into observability, centralized logging, containerization, and more advanced failure scenarios.

---

## Safety Notice

Incident Lab is intended for disposable lab environments only.

The project intentionally modifies service state and configuration files managed by the lab environment.

Do not run Incident Lab on production systems or on machines hosting important workloads.

---

## Learning Objectives

Incident Lab provides hands-on practice with:

* Linux service troubleshooting
* systemd operations
* Log analysis
* Configuration validation
* Reverse proxy troubleshooting
* Root cause analysis
* Service recovery

The project is primarily aimed at:

* Students learning Linux administration
* Junior infrastructure engineers
* Junior DevOps engineers
* SRE candidates
* Anyone seeking practical troubleshooting experience

---

## Environment Architecture

Version 1 uses a deliberately simple environment:

```text
User
 ↓
Nginx
 ↓
FastAPI
```

Components:

* Debian 13
* Nginx
* FastAPI
* Uvicorn
* systemd

The small environment allows users to focus on troubleshooting fundamentals rather than infrastructure complexity.

---

## Incident Workflow

Every incident follows the same lifecycle:

```text
Healthy Environment
       ↓
Inject Random Incident
       ↓
Display Ticket
       ↓
User Investigation
       ↓
User Fixes Issue or Gives Up
       ↓
Incident Review
       ↓
Environment Reset
       ↓
Health Verification
       ↓
Clear Incident State
```

The environment is restored to a known-good state after every exercise.

---

## Requirements

Version 1 was developed and tested on Debian 13.

Required software:

* nginx
* python3
* python3-venv
* curl
* systemd

Required Python packages:

* fastapi
* uvicorn

Prerequisites:

* Nginx configured as a reverse proxy for a FastAPI application
* FastAPI configured as a systemd service
* Functional baseline environment before incident injection
* User capable of executing sudo commands

Incident Lab requires sudo privileges because incidents and recovery operations modify system services and configuration files.

---

## Installation

Clone the repository:

```bash
git clone https://github.com/joaoLustosa/incident-lab.git
cd incident-lab
```

Ensure the scripts are executable:

```bash
chmod +x incident-start incident-reveal incident-reset
```

Incident Lab assumes:

* The scripts are executed from the project root directory
* Nginx and FastAPI are already configured and operational
* The baseline configuration stored in the repository matches the local environment

---

## Usage

Generate an incident:

```bash
./incident-start
```

Example:

```text
Incident created.

TICKET: Users report 502 Bad Gateway responses.
```

Review the active incident:

```bash
./incident-reveal
```

Reset the environment:

```bash
./incident-reset
```

Only one active incident may exist at a time.

Attempting to start a new incident before resetting the environment will result in:

```text
ERROR: Active incident detected.

Run incident-reset before starting a new incident.
```

---

## Incident Catalog

### 001 – FastAPI Service Stopped

Difficulty: Easy

Learning objectives:

* Service status verification
* systemctl usage
* journalctl usage

### 002 – Nginx Service Stopped

Difficulty: Easy

Learning objectives:

* Service availability troubleshooting
* Service recovery procedures

### 003 – Incorrect Nginx Upstream

Difficulty: Medium

Learning objectives:

* Reverse proxy troubleshooting
* Request flow analysis
* Configuration inspection

### 004 – Nginx Syntax Error

Difficulty: Medium

Learning objectives:

* Configuration validation
* nginx -t usage
* Log analysis

---

## Recovery Architecture

Incident Lab does not attempt to reverse individual incidents.

Instead, it restores the environment to a known-good state using:

* Baseline configuration files
* Service restoration
* Health verification

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

* Nginx is active
* FastAPI is active
* Nginx configuration validates successfully
* HTTP requests to the application through Nginx return a successful response

---

## Project Structure

```text
incident-lab/
├── baseline/
│   └── nginx/
│       └── default
│
├── incident-start
├── incident-reveal
├── incident-reset
│
├── incidents/
│   ├── 001-stop-fastapi/
│   │   ├── incident.meta
│   │   └── incident.sh
│   │
│   ├── 002-stop-nginx/
│   │   ├── incident.meta
│   │   └── incident.sh
│   │
│   ├── 003-bad-upstream/
│   │   ├── incident.meta
│   │   └── incident.sh
│   │
│   └── 004-nginx-syntax-error/
│       ├── incident.meta
│       └── incident.sh
│
└── incident-state/
    └── current-incident
```

Each incident is self-contained:

```text
incident-name/
├── incident.sh
└── incident.meta
```

The incident script contains only fault injection logic.

Metadata remains separated from execution logic.

---

## Baseline Ownership Rule

Any resource modified by an incident must have a corresponding healthy version managed by Incident Lab.

The baseline directory serves as the authoritative source of truth for environment recovery.

This guarantees deterministic restoration and prevents configuration drift as the incident catalog grows.

---

## Engineering Decisions

Key Version 1 design decisions:

* Bash-first implementation
* Single-host environment
* Deterministic incidents
* Metadata-driven incident reviews
* Active incident locking
* Authoritative environment reset
* No dependency on VM snapshots

VM snapshots were evaluated and rejected because they reduce portability and introduce hypervisor dependencies.

The current recovery model works entirely from within the operating system.

---

## Roadmap

### Version 2

* Expanded incident catalog
* Automated environment installation
* Improved portability
* Shuffle-bag incident selection

### Version 3

* Docker deployment
* Docker Compose environment provisioning

### Version 4

* Prometheus integration
* Grafana integration
* Observability-focused investigations

### Version 5

* Centralized logging
* Loki
* Promtail

---

## Current Status

Version 1 provides a complete troubleshooting loop:

* Random incident generation
* User investigation
* Incident review
* Automatic environment recovery
* Health verification
* Repeatable execution

The project serves as a practical Linux troubleshooting laboratory focused on operational investigation and service recovery.
