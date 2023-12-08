# GitHub Personal Access Token (PAT)

The `git.env` file mentioned in README.md requires you to have a GitHub Personal Access Token (PAT) in order to interface with GitHub's API.

To create your PAT:

1. Go to your own GitHub settings page.

2. Click Developer Settings, then Personal Access Tokens > Fine Grained Tokens.

<<<<<<< HEAD
3. Create a token with access to Blueboard and whatever repos you need access to, e.g.
=======
3. Resource Owner is Blueboard.

4. If you are not a GitHub Administrator, you must enter a form to request that a PAT be created.  Admins will then have to approve it in (Blueboard > Personal access tokens > Pending requests).

Add the repos:
>>>>>>> 8734914 (more updates)

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

- *Repository permissions:* Read and Write access to organization administration and organization secrets

If you are a GitHub Admin (Owner) and want to write Organization secrets (e.g. the highest level), the PAT will also need:
*Repository permissions*
- Administration, read and write
- Environmenbt,s read and write
Metadata, read only (this isa default)
- Secrets Read and wrute

If you are a GitHib Administrator, you will also need:

*Organization permissions*

- Administration, read and write
- Secrets, read and write

Click Generate new token.


Read and Write access to organization administration and organization secrets

If you are a GitHub Admin and want to write Organization secrets (the highest level), you'll also need:



- *Organization permissions:* Read and Write access to administration, environments, and secrets
