# git-bash-aliases

Short aliases for commonly used git commands.

## Overview

These aliases allow you to quickly perform everyday commands with git.

## Index

* [gro()](#gro)
* [glo()](#glo)
* [gria()](#gria)
* [grod()](#grod)
* [grom()](#grom)
* [gro()](#gro)
* [gdod()](#gdod)
* [gdsod()](#gdsod)
* [gdom()](#gdom)
* [gdsom()](#gdsom)
* [gdo()](#gdo)
* [gdso()](#gdso)
* [gpf()](#gpf)
* [gposu()](#gposu)
* [gpof()](#gpof)
* [reinstall-git-bash-completion()](#reinstall-git-bash-completion)
* [__get_local_branch()](#__get_local_branch)

### gro()

`git reset` the current branch to the one of the same name on `origin`

Mnemonic: *git reset origin*

For a local branch named `branch`, this script performs:
```
git reset --hard origin/branch
```

Arguments are forwarded to `git reset`.

#### Example

```bash
gro
```

#### Exit codes

* **0**: Successful.
* **1**: Unable to read current branch.
* **2**: Unable to read user input.
* **3**: Operation canceled by user.

### glo()

`git log --oneline`

#### Example

```bash
glo origin/develop
glo -2
glo -3 develop
```

### gria()

`git rebase --interactive --autosquash`


Mnemonic: *git rebase interactive autosquash*

#### Example

```bash
gr origin/develop
```

### grod()

`git rebase --interactive --autosquash origin/develop`

#### Example

```bash
grod
```

### grom()

`git rebase --interactive --autosquash origin/master`

#### Example

```bash
grom
```

### gro()

`git rebase --interactive --autosquash` with the current branch onto the branch of the same name on `origin`

#### Example

```bash
gro
```

### gdod()

`git diff origin/develop`

#### Example

```bash
gdod
```

### gdsod()

`git diff --stat origin/develop`

#### Example

```bash
gdsod
```

### gdom()

`git diff origin/develop`

#### Example

```bash
gdom
```

### gdsom()

`git diff --stat origin/master`

#### Example

```bash
gdsom
```

### gdo()

`git diff` with the branch of the same name on `origin`

#### Example

```bash
gdo
```

#### Exit codes

* **1**: Unable to read current branch.

### gdso()

`git diff --stat` with the branch of the same name on `origin`

#### Example

```bash
gdso
```

#### Exit codes

* **1**: Unable to read current branch.

### gpf()

`git pull --ff-only`

#### Example

```bash
gpf
```

### gposu()

Push the branch to origin and set the upstream.

#### Example

```bash
gposu -f
```

#### Exit codes

* **1**: Unable to read current branch.

### gpof()

`git push --force-with-lease origin` with the current branch to the upstream branch.

If the upstream branch is not set, this command may fail.

#### Example

```bash
gpof
```

#### Exit codes

* **1**: Unable to read current branch.

### reinstall-git-bash-completion()

Download and reinstall bash completion for git.

Periodically, git bash completions seem to stop working. One fix is to
download the bash script from the public repo and copy it over the
currently installed file. This command does this, replacing, the
existing command.

To fix an existing bash session after this command has been run:

```
source ${HOME}/.bashrc
```

#### Example

```bash
reinstall-git-bash-completion
source ${HOME}/.bashrc
```

### __get_local_branch()

Return the current branch of the worktree.

#### Exit codes

* **0**: Successful.
* **1**: Unable to read current branch.

