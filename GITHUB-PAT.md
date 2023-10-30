# GitHib PAT

Go to your own GitHub settings page.

Click Developer Settings, then Personal Access Tokens > Fine Grained Tokens.

Create a token with access to:

```
blueboard/blueboard
blueboard/ado_api
blueboard/milestones_api
blueboard/docker-shared
blueboard/survey_api
blueboard/yass
...

- Repository permissions:  Read and Write access to organization administration and organization secrets

If you are a GitHub Admin and want to write Organization secrets, you'll also need:

- Organization permissions:  Read and Write access to administration, environments, and secrets

