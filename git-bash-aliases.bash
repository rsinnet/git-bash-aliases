#!/bin/bash
# @name git-bash-aliases
# @brief Short aliases for commonly used git commands.
# @description
# These aliases allow you to quickly perform everyday commands with git.

# @description `git reset` the current branch to the one of the same name on `origin`
#
# Mnemonic: *git reset origin*
#
# For a local branch named `branch`, this script performs:
# ```
# git reset --hard origin/branch
# ```
#
# Arguments are forwarded to `git reset`.
#
# @example
#     gro
#
# @exitcode 0 Successful.
# @exitcode 1 Unable to read current branch.
# @exitcode 2 Unable to read user input.
# @exitcode 3 Operation canceled by user.
gro() {
  local -r RED=1
  local -r BLUE=4
  LOCAL_BRANCH="$(git branch --show-current 2>/dev/null)"
  if [ $? -ne 0 ] ; then
    >&2 echo "Failed to read current branch. Are you in a git repository with the HEAD pointing to a local branch?"
    return 1
  fi

  ORIGIN_BRANCH="origin/${LOCAL_BRANCH}"
  echo "This operation will $(tput setaf ${RED})hard-reset$(tput sgr0) the current branch to the origin:
  $(tput setaf ${BLUE})Current branch$(tput sgr0):          ${LOCAL_BRANCH}
  $(tput setaf ${BLUE})Reset to$(tput sgr0):         ${ORIGIN_BRANCH}"

  if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]] ; then
    echo "$(tput smso)$(tput setaf ${RED})PROCEED WITH CAUTION:$(tput sgr0)$(tput smso) The current worktree has uncommitted changes.$(tput sgr0)"
  fi

  PROMPT_MESSAGE="Do you wish to continue? [yN] "
  read -n 1 -p "${PROMPT_MESSAGE}"
  READ_ERROR="$?"

  echo
  if [ ${READ_ERROR} = 0 ] ; then
    case ${REPLY} in
      Y|y)
        git reset --hard ${ORIGIN_BRANCH}
        return 0
        ;;
      *)
    esac
  else
    >&2 echo "Reset operation canceled. Reason: Failed to read input; error code: $?."
    return 2
  fi
  >&2 echo "Reset operation canceled. Reason: User input '${REPLY}'."
  return 3
}

# @description `git log --oneline`
#
# @example
# glo origin/develop
# glo -2
# glo -3 develop
glo() {
  git log --oneline $*
}

# @description `git rebase --interactive --autosquash`
#
#
# Mnemonic: *git rebase interactive autosquash*
#
# @example
#     gr origin/develop
gria() {
  git rebase --interactive --autosquash "$@"
}

# @description `git rebase --interactive --autosquash origin/develop`
#
# @example
#     grod
grod() {
  gria "origin/develop" "$@"
}

# @description `git rebase --interactive --autosquash origin/master`
#
# @example
#     grom
grom() {
  gria "origin/master" "$@"
}

# @description `git rebase --interactive --autosquash` with the current branch onto the branch of the same name on `origin`
#
# @example
#     gro
gro() {
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  ORIGIN_BRANCH="origin/${LOCAL_BRANCH}"

  gria "${ORIGIN_BRANCH}" "$@"
}

# @description `git diff origin/develop`
#
# @example
#     gdod
gdod() {
  git diff origin/develop "$@"
}

# @description `git diff --stat origin/develop`
#
# @example
#     gdsod
gdsod() {
  gdod --stat "$@"
}

# @description `git diff origin/develop`
#
# @example
#     gdom
gdom() {
  git diff origin/master "$@"
}

# @description `git diff --stat origin/master`
#
# @example
#     gdsom
gdsom() {
  gdom --stat "$@"
}

# @description `git diff` with the branch of the same name on `origin`
#
# @example
#     gdo
#
# @exitcode 1 Unable to read current branch.
gdo() {
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  ORIGIN_BRANCH="origin/${LOCAL_BRANCH}"

  git diff "${ORIGIN_BRANCH}" "$@"
}

# @description `git diff --stat` with the branch of the same name on `origin`
#
# @example
#     gdso
#
# @exitcode 1 Unable to read current branch.
gdso() {
  gdo --stat "$@"
}

# @description `git pull --ff-only`
#
# @example
#     gpf
gpf () {
  git pull --ff-only "$@"
}

# @description Push the branch to origin and set the upstream.
#
# @example
#     gposu -f
#
# @exitcode 1 Unable to read current branch.
gposu () {
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  git push --set-upstream origin "${LOCAL_BRANCH}" "$@"
}

# @description `git push --force-with-lease origin` with the current branch to the upstream branch.
#
# If the upstream branch is not set, this command may fail.
#
# @example
#     gpof
#
# @exitcode 1 Unable to read current branch.
gpof () {
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  git push --force-with-lease origin "${LOCAL_BRANCH}" "$@"
}

# @description Download and reinstall bash completion for git.
#
# Periodically, git bash completions seem to stop working. One fix is to
# download the bash script from the public repo and copy it over the
# currently installed file. This command does this, replacing, the
# existing command.
#
# To fix an existing bash session after this command has been run:
#
# ```
#     source ${HOME}/.bashrc
# ```
#
# @example
#     reinstall-git-bash-completion
#     source ${HOME}/.bashrc
reinstall-git-bash-completion () {
  local git_version=$(git --version | sed 's/^.* \([0-9\\.]\+$\)/\1/g')
  rm -f /tmp/git-completion.bash
  wget https://raw.githubusercontent.com/git/git/v${git_version}/contrib/completion/git-completion.bash -O /tmp/git-completion.bash
  sudo mv /tmp/git-completion.bash /etc/bash_completion.d/git-completion.bash
}

# @description Return the current branch of the worktree.
#
# @exitcode 0 Successful.
# @exitcode 1 Unable to read current branch.
__get_local_branch() {
  LOCAL_BRANCH="$(git branch --show-current 2>/dev/null)"
  if [ $? -ne 0 ] ; then
    >&2 echo "Failed to read current branch. Are you in a git repository with the HEAD pointing to a local branch?"
    return 1
  fi
  echo "${LOCAL_BRANCH}"
}

# @description Show a sorted list of objects in the Git database.
#
# @stdout A list of objects sorted by size in descending order
#
# @exitcode 0 Successful.
#
# @see https://stackoverflow.com/a/42544963/2001889
gba-list-objects() {
  local -r batch_check='%(objecttype) %(objectname) %(objectsize) %(rest)'
  git rev-list --objects --all \
    | git cat-file --batch-check="${batch_check}" \
    | sed -n 's/^blob //p' \
    | sort --numeric-sort --key=2 \
    | cut -c 1-12,41- \
    | $(command -v gnumfmt || echo numfmt) \
        --field=2 --to=iec-i --suffix=B \
        --padding=7 --round=nearest
}

# @description Show git commit hash for the specified file path and hash.
#
# Optionally, specificy a hash for a specific version of the file.
#
# @arg $1 The path to the file, relative to the root of the repository.
# @arg $2 (Optional) The has for the version of interest.
#
# @example
#     gba-find-commit path/to.file
#     gba-find-commit path/to.file 21339ea0c4ce
#
# @exitcode 0 Successful.
# @exitcode 1 Incorrect number of arguments.
#
# @see https://stackoverflow.com/a/32611564/2001889
gba-find-commit() {
  [[ $# -lt 1 ]] && (>&2 echo "Too few arguments ($# < 1)") && return 1 || true
  [[ $# -gt 2 ]] && (>&2 echo "Too many arguments ($# > 2)") && return 1 || true

  local -r fpath="$1"
  [[ $# == 2 ]] && hash_filter=( grep -q "$2" ) || hash_filter=( cat )

  local -r gitcmd="git ls-tree % -- \"${fpath}\" | ${hash_filter[@]} && echo %"
  git log --all --pretty=format:%H -- "${fpath}" \
    | xargs -n1 -I% bash -c "${gitcmd}"
}

# @description Show git log for the specified file path and hash.
#
# Optionally, specificy a hash for a specific version of the file.
#
# @arg $1 The path to the file, relative to the root of the repository.
# @arg $2 (Optional) The has for the version of interest.
#
# @example
#     gba-show-commit path/to.file
#     gba-show-commit path/to.file 21339ea0c4ce
#
# @exitcode 0 Successful.
# @exitcode 1 Incorrect number of arguments.
# @exitcode 2 Object not found.
gba-show-commit() {
  local -r commit="$(gba-find-commit "$@")"
  if [[ -z "${commit}" ]] ; then
    (>&2 echo "Object $1 with hash $2 not found")
    return 2
  fi
  git log -n1 "${commit}"
}


# @internal
__glo_complete() {
  __git_complete_refs --cur="${COMP_WORDS[COMP_CWORD]}" --sfx=""
}
complete -F __glo_complete -o default glo
complete -F __glo_complete -o default gria
complete -F __glo_complete -o default gds
