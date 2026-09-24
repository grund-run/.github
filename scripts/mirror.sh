#!/usr/bin/env bash
# Mirror every public repo in git.kjuulh.io/grund to github.com/grund-run.
# Idempotent; never deletes. See README.md.
set -euo pipefail

GITEA_URL="${GITEA_URL:-https://git.kjuulh.io}"
GITEA_ORG="${GITEA_ORG:-grund}"
GITHUB_ORG="${GITHUB_ORG:-grund-run}"
HOMEPAGE="${HOMEPAGE:-https://grund.run}"
INTERVAL="${INTERVAL:-8h0m0s}"
DRY_RUN="${DRY_RUN:-}"
ROTATE="${ROTATE:-}"

: "${GITEA_TOKEN:?set GITEA_TOKEN}"
: "${GITHUB_TOKEN:?set GITHUB_TOKEN}"
: "${GITHUB_MIRROR_TOKEN:?set GITHUB_MIRROR_TOKEN (fine-grained PAT scoped to $GITHUB_ORG)}"

gitea() { curl -fsS -H "Authorization: token $GITEA_TOKEN" -H 'Content-Type: application/json' "$@"; }
github() { curl -fsS -H "Authorization: Bearer $GITHUB_TOKEN" -H 'Accept: application/vnd.github+json' \
  -H 'X-GitHub-Api-Version: 2022-11-28' "$@"; }
run() {
  if [[ -n "$DRY_RUN" ]]; then
    local line="$*"
    echo "  (dry run) ${line//"$GITHUB_MIRROR_TOKEN"/***}"   # never print the stored credential
  else
    "$@"
  fi
}

github_user=$(github https://api.github.com/user | jq -r .login)

page=1
while :; do
  repos=$(gitea "$GITEA_URL/api/v1/orgs/$GITEA_ORG/repos?limit=50&page=$page")
  [[ $(jq length <<<"$repos") -eq 0 ]] && break

  while read -r repo; do
    name=$(jq -r .name <<<"$repo")
    if [[ $(jq -r .private <<<"$repo") == "true" ]]; then
      echo "skip  $name (private on gitea; never published)"
      continue
    fi
    if [[ $(jq -r .mirror <<<"$repo") == "true" ]]; then
      echo "skip  $name (is itself a pull mirror)"
      continue
    fi
    description=$(jq -r '.description // ""' <<<"$repo")

    # 1. The GitHub repository.
    if github -o /dev/null "https://api.github.com/repos/$GITHUB_ORG/$name" 2>/dev/null; then
      echo "ok    github.com/$GITHUB_ORG/$name exists"
    else
      echo "new   github.com/$GITHUB_ORG/$name"
      body=$(jq -n --arg n "$name" --arg d "$description" --arg h "$HOMEPAGE" \
        '{name:$n, description:$d, homepage:$h, private:false, has_wiki:false, has_projects:false}')
      run github -o /dev/null -X POST "https://api.github.com/orgs/$GITHUB_ORG/repos" -d "$body"
    fi

    # 2. The Gitea push mirror.
    remote="https://github.com/$GITHUB_ORG/$name.git"
    mirrors=$(gitea "$GITEA_URL/api/v1/repos/$GITEA_ORG/$name/push_mirrors")
    existing=$(jq -r --arg r "$remote" '.[] | select(.remote_address==$r) | .remote_name' <<<"$mirrors")
    if [[ -n "$existing" && -z "$ROTATE" ]]; then
      echo "ok    push mirror $name -> $remote"
      continue
    fi
    if [[ -n "$existing" ]]; then
      echo "rot   push mirror $name (replacing stored credential)"
      run gitea -o /dev/null -X DELETE "$GITEA_URL/api/v1/repos/$GITEA_ORG/$name/push_mirrors/$existing"
    else
      echo "new   push mirror $name -> $remote"
    fi
    body=$(jq -n --arg r "$remote" --arg u "$github_user" --arg p "$GITHUB_MIRROR_TOKEN" --arg i "$INTERVAL" \
      '{remote_address:$r, remote_username:$u, remote_password:$p, interval:$i, sync_on_commit:true}')
    run gitea -o /dev/null -X POST "$GITEA_URL/api/v1/repos/$GITEA_ORG/$name/push_mirrors" -d "$body"
    # Kick an immediate sync. Gitea answers 422 while a sync is already running
    # (sync_on_commit may have started one), which is fine: don't abort the run.
    run gitea -o /dev/null -X POST "$GITEA_URL/api/v1/repos/$GITEA_ORG/$name/push_mirrors-sync" \
      || echo "note  $name: sync already in progress"
  done < <(jq -c '.[]' <<<"$repos")

  page=$((page + 1))
done
