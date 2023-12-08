# Set GitHub Secrets

This is a command line tool -- a bash script that wraps a Python script -- which is to be used to set secrets in GitHub.

It can be used to set:

- Environment secrets -- e.g. `dev`, `staging` or `prod`, which are environments within a repo
- Repository secrets -- repo level secrets are available to any environment
- Oregnization secrets -- org level secrets are available to any repo

The "source of truth" for these secrets are Secure Notes in the `set-github-secrets` vault in 1Password.

The basic workflow is:
- A bash script runs everything, and is used todetermine what secrets to pull down and where to push them
- The bash script uses the 1Password command line tools to interface with the 1Password client
- Secure notes are exported to a `.env` file in a simple `foo=bar` format
- A Python script reads these files and pushes them up to GitHub

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

2. Create a `git.env` file at the root of this project.  **This file should not be comitted to GitHub** (It should already be excluded by the `.gitignore`.)

```
GITHUB_ACCESS_TOKEN=github_pat_XXX
GITHUB_REPO_OWNER=blueboard
ENVIRONMENT=DEV
```

## Convention

The convention that is used for the name of the Secure Note in 1Password is:  `<repo name>_<env>`.  Repository secrets use the `repo` suffix.  Organization secrets are simply named `organiation_secrets`.

Examples:

- The name of the Secure Note that contains the secrets for the dev environment of the Rails API is named `blueboard_dev`
- The name of the Secure Note that contains the secrets for the prod environment of the Send application is named `send_prod`
- The name of the Secure Note that contains the secrets Milestones API repository is named `milestones_api_repo`

The command syntax to read a Secure Note from a 1Password vault is:

```
op read op://<VAULT>/<NOTE_TITLE>/notesPlain
```

For example, to read the note named `ado_api_dev` in the vault named `set-github-secrets` you would:

```
op read op://set-github-secrets/ado_api_dev/notesPlain
```

Note the use of `--out-file`, which is simply an argument for a file to save the results in, otherwise the output goes to STDOUT.

- 1Password documentation:  https://developer.1password.com/docs/cli/reference/commands/read

Repository

## Usage

This project is menu driven and relies on the existance of a Secire Note -- which is functionally equivalent to a `.env` file -- in the 1Password vault named as per the simple convnetion explained above.

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

In this example, by selecting option 4 (`ado_api`) then option 1 (`dev`), the script will try to fetch a secure note from the `set-github-secrets` vault in 1PW named in 1PW `ado_api_dev`.

If successful, that file is then passed to `main.py` which sets the values in GitHub.

## Caveats

Caveat 1 -- Error handling (if any) is likely poor.  In the example above, expect there to be generally poor error handling.  For example, the case where a secure note maybe does not exist in 1Password, that will probably result in some big error.  Or if the user lacks permissions to access that vault, the GitHub repo, etc.  If the note is formatted as `foo: bar` instead of `foo=bar`, and so on.

Caveat 2 -- Secrets are written and updated, but they are not removed.

For example, if you were to set:
```
FOO=foo
BAR=bar
```

Then later, you decide to set:
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

## Problems

Long strings, JSON, YAML, SSL certificats, things with carriage returns, etc. should be Base64 encoded when they are set in 1Password.

Please use the `_B64` suffix!

For example, this is a private key, which has `\n` characters.  It is not valid when one single string.

```
-----BEGIN OPENSSH PRIVATE KEY-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END OPENSSH PRIVATE KEY-----
```

You would:

```
cat my_key | base64
```

...which produces one big string, e.g. `LS0tLS1CRUdJTiBPUEV...` -- then set that in 1PW as `MY_KEY_B64=LS0tLS1CRUdJTiBPUEV...`.

When you use the secret, just decode it, for example in a GitHub Action you would:

```
echo ${{ secrets.MY_KEY_B64 }} | base64 --decode > my_key
```
