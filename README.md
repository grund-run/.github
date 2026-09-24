# grund/.github

Organisation-level files for **grund**.

| Path | What it is |
|---|---|
| `profile/README.md` | The org's front page on GitHub (`github.com/grund-run`) |
| `scripts/mirror.sh` | Keeps every public repo in `git.kjuulh.io/grund` push-mirrored to `github.com/grund-run` |

## How mirroring works

**git.kjuulh.io is the source of truth.** GitHub is a read-only public face.

- **Creating a repo:** create it in the `grund` org on git.kjuulh.io, then run
  `scripts/mirror.sh`. It creates `grund-run/<repo>` on GitHub, copying the
  description and setting the homepage to grund.run, and attaches a Gitea
  push mirror with `sync_on_commit`.
- **After that:** every push to Gitea reaches GitHub within seconds, with a
  full sync every 8 hours as a backstop.
- **Only public Gitea repos are mirrored.** A private repo in the org is
  skipped and never published. To publish one, make it public on Gitea
  first. That is a deliberate step, not an accident.
- **The script is idempotent.** Run it as often as you like. It never deletes
  anything on either side.
- **Pull requests opened on GitHub** have to be applied on Gitea by a
  maintainer, because the next mirror push would overwrite them. Say so in
  each repo's README.

## Automation

`.woodpecker/mirror.yaml` runs the script on
[ci.git.kjuulh.io](https://ci.git.kjuulh.io):

- **When:** hourly (cron `mirror`), on a manual run, and on every push to this
  repo. A new repo in the org reaches GitHub within the hour, or immediately
  via "Run pipeline".
- **Secrets it needs** (repo secrets, available to `cron`, `manual` and
  `push` events only, never pull requests):

  | Secret | What it is |
  |---|---|
  | `gitea_token` | git.kjuulh.io token with `read:organization` + `write:repository` |
  | `github_admin_token` | fine-grained PAT on `grund-run`: Administration + Contents read/write, Metadata read (creates repos) |
  | `github_mirror_token` | fine-grained PAT on `grund-run`: Contents read/write, Metadata read (stored in each Gitea push mirror) |

  One PAT with Administration + Contents can serve as both GitHub secrets.
  Two keeps the credential Gitea stores narrower.

## Running it by hand

```sh
export GITEA_TOKEN=...          # git.kjuulh.io token with write:repository (read org + manage push mirrors)
export GITHUB_TOKEN=...         # used to create repos in grund-run (e.g. `gh auth token` as an org owner)
export GITHUB_MIRROR_TOKEN=...  # stored in Gitea for pushing; see below
scripts/mirror.sh               # or: DRY_RUN=1 scripts/mirror.sh
```

**About `GITHUB_MIRROR_TOKEN`:** Gitea stores this token and uses it on every
push. Make it a **fine-grained personal access token** with:

- resource owner `grund-run`;
- all repositories;
- permissions **Contents: read and write** and **Metadata: read**.

It is not your general `gh` token. If Gitea is ever compromised, only the
grund-run repos are exposed. Give it an expiry and a calendar reminder.
Rotating it means re-running the script with `ROTATE=1`, which replaces the
stored credential on every mirror.
