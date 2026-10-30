#!/usr/bin/env python3
"""Create secrets once, without printing them."""
import os
import secrets
from pathlib import Path

folder = Path('/project/secrets')
folder.mkdir(mode=0o700, exist_ok=True)
for name, value in [('gitlab_api_token', 'glpat-' + secrets.token_hex(24)),
                    ('db_password', secrets.token_hex(24))]:
    path = folder / name
    try:
        fd = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    except FileExistsError:
        continue
    with os.fdopen(fd, 'w') as out:
        out.write(value + '\n')
