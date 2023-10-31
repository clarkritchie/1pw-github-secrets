# GitHub Personal Access Token (PAT)

The `git.env` file mentioned in README.md requires you to have a GitHub Personal Access Token (PAT) in order to interface with GitHub's API.

To create your PAT:

1. Go to your own GitHub settings page.

2. Click Developer Settings, then Personal Access Tokens > Fine Grained Tokens.

3. Create a token with access to Blueboard and these repos:

```
blueboard/blueboard
blueboard/ado_api
blueboard/milestones_api
blueboard/docker-shared
blueboard/survey_api
blueboard/yass
...
```

The PAT will need:

*Repository permissions* -- Read and Write access to organization administration and organization secrets

If you are a GitHub Admin and want to write Organization secrets (the highest level), you'll also need:

*Organization permissions* -- Read and Write access to administration, environments, and secrets

