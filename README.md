# clusters-config
Configuration for engineering's ephemeral clusters

## Pre-Commit hooks

This repository uses [pre-commit hooks](https://pre-commit.com/) to run quick
checks against it. They can be installed and run using:

```bash
$ pip3 install pre-commit
# or
$ brew install pre-commit
# Then
$ pre-commit install
# The hooks can be run with
$ pre-commit run --all
# Otherwise they'll run automatically on commit
# they can be skipped with
$ git commit -n
```
