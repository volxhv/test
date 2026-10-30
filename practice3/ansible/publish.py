#!/usr/bin/env python3
"""Publish a snapshot, without changing the user's local Git repository."""
import os
import shutil
import subprocess
import tempfile
from pathlib import Path

source = Path('/project')
env = os.environ.copy()
token = env.pop('GITLAB_TOKEN')
with tempfile.TemporaryDirectory(prefix='practice3-publish-') as directory:
    tmp = Path(directory)
    askpass = tmp / 'askpass.sh'
    askpass.write_text('#!/bin/sh\ncase "$1" in *sername*) printf "%s\n" oauth2 ;; *) printf "%s\n" "$PRACTICE3_TOKEN" ;; esac\n')
    askpass.chmod(0o700)
    env.update(GIT_ASKPASS=str(askpass), PRACTICE3_TOKEN=token, GIT_TERMINAL_PROMPT='0')
    remote = 'http://host.docker.internal:8080/devops/devops-stack.git'
    target = tmp / 'repo'
    def git(*args):
        return subprocess.run(['git', *args], cwd=target if target.exists() else tmp,
                              env=env, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True).stdout
    git('clone', '--branch', 'main', remote, str(target))
    for child in source.iterdir():
        if child.name in {'.git', 'secrets', 'node_modules', 'dist', '.idea', '__pycache__'}:
            continue
        dest = target / child.name
        if child.is_dir():
            shutil.copytree(child, dest, dirs_exist_ok=True,
                ignore=shutil.ignore_patterns('node_modules', 'dist', '__pycache__', '.git', '.idea'))
        elif child.is_file():
            shutil.copy2(child, dest)
    (target / 'secrets').mkdir(exist_ok=True)
    (target / 'secrets' / '.gitkeep').touch()
    git('config', 'user.name', 'Practice 3 Ansible')
    git('config', 'user.email', 'practice3@localhost')
    git('add', '-A')
    if git('status', '--porcelain').strip():
        git('commit', '-m', 'Update practice 3 project')
        git('push', 'origin', 'main')
        print('PUSHED')
    else:
        print('NO_CHANGES')
