# GitHub Personal Access Token (PAT)

The `git.env` file mentioned in README.md requires you to have a GitHub Personal Access Token (PAT) in order to interface with GitHub's API.

To create your PAT:

1. Go to your own GitHub settings page.

2. Click _Developer Settings_ then _Personal Access Tokens > Fine Grained Tokens_.

3. The default "Resource Owner" is yourself, change this to **Blueboard** -- i.e. you are creating a token to aceess Blueboard's GitHub account.

Note that if you are not a GitHub Administrator, you must enter a small form to request that your PAT be permitted to be used.  A GitHub Administrator will then have to manually approve that request under _Blueboard > Personal access tokens > Pending requests_.

5. Add the repos you need access to, e.g.

```
blueboard/blueboard
blueboard/ado_api
blueboard/milestones_api
blueboard/docker-shared
blueboard/survey_api
blueboard/yass
...
```

Grant the token the following permissions.

### Repository Permissions

- **Administration** Read and Write
- **Environments** Read and Write
- **Metadata** Read Only (this is a default)
- **Secrets** Read and Write

If you are a GitHub Admin (Owner) and want to write Organization secrets (e.g. the highest level), the PAT will also need:

### Organization Permissions

- **Administration** Read and Write
- **Secrets** Read and Write

Click Generate new token.  Again, if you are not a GitHub Administrator, an admin must approve the token before it can be used.
