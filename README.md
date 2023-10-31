# Set GitHub Secrets

This is a command line tool for use in setting secrets in GitHub from a "source of truth" .env file in 1Password.

It can be used to set:

- Environment secrets
- Repository secrets
- Oregnization secrets

## Pre-Requisites

### Install 1Password Command Line Tools

The following assumes that you have 1Password installed and access to the `set-github-secrets` vault.

1. Install the 1Password command line tools:

```
brew install 1password-cli
```

2. Turn on the 1Password desktop app integration

- Open and unlock the 1Password app.
- Click your account or collection at the top of the sidebar.
- Navigate to Settings > Developer.
- Select "Integrate with 1Password CLI".
- If you want to authenticate 1Password CLI with your fingerprint, turn on Touch ID in the app.

3. Verify

This command should return something:

```
op vault list
```

For more information or help:

- https://developer.1password.com/docs/cli/get-started

### GitHub PAT

1. Create a [GitHub Personal Access Token (PAT)](GITHUB-PAT.md)

2. Create a `git.env` file at the root of this project.  *Do not commit this to GitHub* (it should already be excluded by the `.gitignore`).

```
GITHUB_ACCESS_TOKEN=github_pat_XXX
GITHUB_REPO_OWNER=blueboard
ENVIRONMENT=DEV
```

## Usage

This project is menu driven and relies on the existance of a `.env` file in the 1Password vault named `set-github-secrets` that follows a simple convention: `[github_repo]-[env].env`.

Example usage:

```
❯ ./run.sh                                                                                                                         1pw_env

Remember, some env vars are may be problematic as they are known to contain JSON or XML, may
contain line breaks or have other special spacing requirements, such as certificates.

These should be base64 encoded.

See also the array VARS_TO_SKIP in main.py

1) blueboard	   3) milestones_api  5) survey_api	 7) organization
2) docker-shared   4) ado_api	      6) yass		 8) quit

Select the repository to push secrets into, or choose organizaiton: 4
1) dev		 3) prod	  5) organization
2) staging	 4) repo	  6) quit

Select the ENVIRONMENT, or create a REPOSITORY or ORGANIZATION secret: 1
```

In this example, by selecting option 4 (`ado_api`) then option 1 (`dev`), the script will try to fetch a file named `ado_api-dev.env` from the `set-github-secrets` vault in 1Password.

If successful, that file is then passed to `main.py` which sets the values in GitHub.

## Caveats

Caveat 1 -- Error handling (if any) is likely poor.  In the example above, how graceful this handles things if, for example, the file `ado_api-dev.env` does not exist in 1Password, or if the user lacks permissions to view it, etc.

Caveat 2 -- Secrets are written or or updated, but they are not removed.

e.g. if you set:
```
FOO=foo
BAR=bar
```

Then you set:
```
FOO=bar
COW=cow
```

You will end up with this -- e.g. `FOO` was updated, `COW` was added, and `BAR` was left as-is:
```
FOO=bar
BAR=bar
COW=cow
```

To workaround this, just fully delete an environment in GitHub then re-create it from scratch.

Caveat 3 -- Long strings, JSON, YAML, SSL certificats, things with carriage returns, etc. should be Base64 encoded.
