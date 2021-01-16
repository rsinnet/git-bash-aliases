# Reset the current branch to the one of the same name on the origin.
#
# Mnemonic: 'git reset origin'
#
# For a local branch named `branch`, this script performs:
#   git reset --hard origin/branch
function gro
{
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

# Show the one-line git log for the specified number of entries.
#
# Args:
#   -r (optional)
#     A git refspec.
#
# Usage:
#   glo origin/develop
#   glo -2
#   glo -3 develop
function glo
{
  git log --oneline $*
}

# Rebase the current branch onto origin/develop with interactive autosquash.
function grod
{
  git rebase --interactive --autosquash origin/develop
}

# Rebase the current branch onto the origin.
function gro
{
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  ORIGIN_BRANCH="origin/${LOCAL_BRANCH}"

  git rebase --interactive --autosquash ${ORIGIN_BRANCH} "$@"
}

# Show the git diff with origin/develop
function gdod
{
  git diff origin/develop "$@"
}

# Show the git diff --stat with origin/develop
function gdsod
{
  gdod --stat "$@"
}

# Show the git diff --stat with the origin.
function gdso
{
  gdso --stat "$@"
}

# Show the git diff with the origin.
function gdo
{
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  ORIGIN_BRANCH="origin/${LOCAL_BRANCH}"

  git diff ${ORIGIN_BRANCH} "$@"
}

# Pull from the remote with git pull --ff-only
function gpf {
  git pull --ff-only "$@"
}

# Push the branch to origin and set the upstream.
function gposu {
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  git push --set-upstream origin ${LOCAL_BRANCH} "$@"
}

# Force-push the branch to origin.
function gpof {
  LOCAL_BRANCH=$(__get_local_branch)
  [ $? -ne 0 ] && return 1
  git push --force-with-lease origin ${LOCAL_BRANCH} "$@"
}

function reinstall-git-bash-completion {
  local git_version=$(git --version | sed 's/^.* \([0-9\\.]\+$\)/\1/g')
  rm -f /tmp/git-completion.bash
  wget https://raw.githubusercontent.com/git/git/v${git_version}/contrib/completion/git-completion.bash -O /tmp/git-completion.bash
  sudo mv /tmp/git-completion.bash /etc/bash_completion.d/git-completion.bash
}

# Return the current branch of the worktree.
function __get_local_branch
{
  LOCAL_BRANCH="$(git branch --show-current 2>/dev/null)"
  if [ $? -ne 0 ] ; then
    >&2 echo "Failed to read current branch. Are you in a git repository with the HEAD pointing to a local branch?"
    return 1
  fi
  echo "${LOCAL_BRANCH}"
}

function __glo_complete
{
  __git_complete_refs --cur="${COMP_WORDS[COMP_CWORD]}" --sfx=""
}
complete -F __glo_complete -o default glo
