# Set GitHub Secrets

This project is a small Python script that reads secrets from 1Password, and pushes them into GitHub as either a) environment secrets within a project, b) repoistory secrets, or c) organization secrets.

There are 2 ways to use this project, either as a GitHub Action or as a command line tool.

For everything except organization secrets, you should use the GitHub Action.  That action uses a PAT (for the BlueboardBot GitHub user) to authenticate with GitHub and requires no setup on your localhost.

However, that Personal Access Token (PAT) does not have permission to set organization secrets, so for those, you must be a GitHub Administrator and run this from your localhost.  Note that additional setup is required.  You must have a PAT for youself and intall the 1Passowrd command line tools on your localhost.

## Conventions Used, Important!  Must read!

The following naming convention is used, which is:  the name of the Secure Note in 1Password as `<repo name>_<env>`.  Repository secrets use the `repo` suffix.  Organization secrets are simply named `organiation_secrets`.

Examples:

- The name of the Secure Note that contains the secrets for the `dev` environment of the Rails API (GitHub project is `blueboard`) is named `blueboard_dev`
- The name of the Secure Note that contains the secrets for the `prod` environment of the Send application (GitHub project is `send`) is named `send_prod`
- The name of the Secure Note that contains the secrets Milestones API repository is named `milestones_api_repo`
- The name of the Secure Note that contains organization secrets is named simply `organization_secrets`

## Usage 1 - GitHub Action

The functionality in this project is now available as a GitHub Action!  It can be used to set environment and repository secrets.  **It does not have permission to set Organization secrets.**

The GHA:

- Uses a service account (`BlueboardBot`) to interact with 1Password
- Uses BlueboardBot's PAT for GitHub, that user is an admin on relevant repos, and the token has permissions to create environments and write secrets

BlueboardBot's tokens are set as Organization secrets.

## Usage 2 - Command Line

This is a command line tool -- a bash script that calls a Python script -- which is to be used to set secrets in GitHub.  It evolved over time to meet Blueboard's needs.

It can be used to set:

- Environment secrets -- e.g. `dev`, `staging` or `prod`, which are environments within a repo
- Repository secrets -- repo level secrets are available to any environment
- Oregnization secrets -- org level secrets are available to any repo

The "source of truth" for these secrets are Secure Notes in the `set-github-secrets` vault in 1Password.

The basic workflow is:
- A bash script runs everything, and is used to determine what secrets to pull down and where to push them
- The bash script uses the 1Password command line tools to interface with the 1Password client
- Secure notes are exported to a `.env` file in a simple `foo=bar` format
- A Python script reads these files and pushes them up to GitHub

### Pre-Requisites

#### Install 1Password Command Line Tools

The following assumes that you have 1Password installed and access to the `set-github-secrets` vault.

1. Install the 1Password command line tools:

```
brew install 1password-cli
```

2. Turn on the 1Password desktop app integration in the 1Password desktop application.

- Open and unlock the 1Password app.
- Click your account or collection at the top of the sidebar.
- Navigate to Settings > Developer.
- Select "Integrate with 1Password CLI".
- If you want to authenticate 1Password CLI with your fingerprint, turn on Touch ID in the app.

3. Verify

Go to your shell -- this command should return something:

```
op vault list
```

For more information or help:

- https://developer.1password.com/docs/cli/get-started

#### Create a GitHub PAT (PAT)

1. Steps on how to create a [GitHub PAT (PAT)](GITHUB-PAT.md).

2. Create a `git.env` file at the root of this project.  **This file should not be comitted to GitHub!!!** (It should already be excluded by the `.gitignore`.)

```
GITHUB_ACCESS_TOKEN=github_pat_XXX
GITHUB_REPO_OWNER=blueboard
```

The command syntax to read a Secure Note from a 1Password vault is:

```
op read op://<VAULT>/<NOTE_TITLE>/notesPlain
```

For example, to read the note named `ado_api_dev` in the vault named `set-github-secrets` you would:

```
op read op://set-github-secrets/ado_api_dev/notesPlain
```

Note the use of `--out-file` in `runs.sh`, which is simply an argument for a file to save the results in, otherwise the output goes to STDOUT.

- 1Password documentation:  https://developer.1password.com/docs/cli/reference/commands/read

### Usage

This project is menu driven and relies on the existance of a Secire Note -- which is functionally equivalent to a `.env` file -- in the 1Password vault named as per the simple convnetion explained above.

Example usage:

```
❯ ./run.sh
This script retrieves env vars from 1PW notes and creates them as GitHub secrets.

This workflow DOES NOT remove old values from GitHub!  That is important.

1PW is our source of truth.

Some env vars are can be problematic -- specifically if they contain JSON, XML, have
line breaks, are certificates, and/or just have other special characters. The best
workaround here is to simply Base64 encode the values before you upload them to
GitHub.  Please name these with a _B64 suffix, e.g. FOO_B64.

These can also be ignored, see the array VARS_TO_SKIP array in main.py.

Select the GitHub repository to use, or choose organization.

1) Account		    9) Organization
2) ADO API		   10) Run
3) Blueboard (Rails API)   11) Send
4) Docker Shared	   12) Survey
5) GSD			   13) Wellness
6) Menu			   14) YASS
7) Milestones API	   15) Quit
8) Monofront

Your choice: 7

Select the scope -- i.e. environment (dev, staging, prod) or create repository or organization secrets.

1) dev		 3) prod	  5) organization
2) staging	 4) repository	  6) quit

Your choice: 2

The contents of the Secure Note named milestones_api_staging are:

AWS_ACCESS_KEY_ID=xxx
AWS_BUCKET_NAME=xxx
AWS_ROLE_ARN=xxx
AWS_SECRET_ACCESS_KEY=xxx
FERNET_KEY=xxx
JOB_QUEUE_HOST=xxx
MYSQL_HOSTNAME=xxx
MYSQL_PASSWORD=xxx
RAILS_API=xxx
SECRET_KEY=xxx


   _______________  ____         ____  _________    ____         ________  _______   ____ __
  / ___/_  __/ __ \/ __ \       / __ \/ ____/   |  / __ \       /_  __/ / / /  _/ | / / //_/
  \__ \ / / / / / / /_/ /      / /_/ / __/ / /| | / / / /        / / / /_/ // //  |/ / ,<
 ___/ // / / /_/ / ____/      / _, _/ /___/ ___ |/ /_/ /        / / / __  // // /|  / /| |_
/____//_/  \____/_/   (_)    /_/ |_/_____/_/  |_/_____(_)      /_/ /_/ /_/___/_/ |_/_/ |_(_)

Review the contents above.  Press Y to push these values to GitHub milestones_api/staging.  Are you sure?  y
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

## Edge Cases To Be Aware Of

Long strings, JSON, YAML, SSL certificats, things with carriage returns (`\n` or `\r`), etc. should be Base64 encoded when they are set in 1Password.

Please use the `_B64` suffix!

For example, a private key looks like this, which has `\n` characters on each line.  It is **not valid** when it is one single string.

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

Note that in YAML, you may need to add leading spaces to make it format right.

```
foo:
  bar:
    moo: |
      ${MOO}
```

The value of MOO might need to be like this **before you Base 64 encode it**.  Note there are 6 leading spaces so that it aligns with the YAML template above.

```
      -----BEGIN OPENSSH PRIVATE KEY-----
      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      -----END OPENSSH PRIVATE KEY-----
```

We do this so that the YAML Ends up like this.  This is valid YAML:

```
foo:
  bar:
    moo: |
      -----BEGIN OPENSSH PRIVATE KEY-----
      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      -----END OPENSSH PRIVATE KEY-----
```

This is invalid YAML:

```
foo:
  bar:
    moo: |
-----BEGIN OPENSSH PRIVATE KEY-----
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-----END OPENSSH PRIVATE KEY-----
```

## Multiline YAML

See link for the various ways to do multi-line values in YAML.

- https://stackoverflow.com/questions/3790454/how-do-i-break-a-string-in-yaml-over-multiple-lines

## If You Screw Up

If you meess up or just want to start over, you can always fully **delete** an environment in GitHub, the script will re-create it.
