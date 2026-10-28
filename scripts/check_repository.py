#!/usr/bin/env python3
"""Fail CI if version control contains likely Terraform state or sensitive files.

This is an additional hygiene gate, NOT a replacement for a secret scanner.
"""
from __future__ import annotations

import pathlib
import re
import subprocess
import sys

repo = pathlib.Path(__file__).resolve().parent.parent
paths = subprocess.check_output(["git", "ls-files"], cwd=repo, text=True).splitlines()
reasons = []
for raw in paths:
    path = pathlib.PurePosixPath(raw)
    name = path.name.lower()
    if name in {"terraform.tfvars", "backend.hcl", "tfplan", "id_rsa", "id_ed25519", ".env"}:
        reasons.append(f"tracked local credential/config: {raw}")
    if name.endswith((".tfstate", ".tfplan", ".pem", ".p12", ".pfx")) or ".tfstate." in name:
        reasons.append(f"tracked potentially sensitive artifact: {raw}")
    if name.startswith("credentials") and name.endswith(".json"):
        reasons.append(f"tracked credential JSON: {raw}")
    if name.endswith((".tf", ".tfvars", ".yaml", ".yml", ".json")):
        content = (repo / raw).read_text(encoding="utf-8")
        if re.search(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----", content):
            reasons.append(f"possible private key: {raw}")

if reasons:
    print("Repository hygiene check FAILED:\n" + "\n".join(reasons), file=sys.stderr)
    sys.exit(1)
print(f"Repository hygiene check passed ({len(paths)} tracked files).")
