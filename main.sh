#!/usr/bin/env bash


function init {
  # Create a new bare repository with a main branch and a README.md file
  mkdir "${1}"
  cd "${1}"
  mkdir ".bare"
  cd ".bare"
  git init --bare
  cd ..
  echo "gitdir: .bare" > .git
  git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
  git fetch --prune
  mkdir tmp
  cd tmp
  git clone ../.bare .
  git b -M main
  echo "# ${1}" >  README.md
  git add .
  git commit -m "Initial commit"
  git push origin HEAD
  cd ..
  git worktree add main
  rm -rf tmp
}

function gwt {

  case "${1}" in
    "clone")
      shift
      local git_url="${1}"
      local default_project_name="$(echo "${1}" | grep -oE "[^/]+\.git" | sed -E 's/.git//')"
      local project_name="${2:-${default_project_name}}"

      # Clone a repository and add a worktree for the main branch
      mkdir "${project_name}"
      cd "${project_name}"
      git clone --bare "${git_url}" ".bare"
      echo "gitdir: .bare" > .git
      git config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
      git fetch --prune
      git worktree add main
    ;;
    "init")
      shift
      # Create a new bare repository with a main branch and a README.md file
      init "${@}"
    ;;
    "add_remote")
      shift
      # Add a remote to the current repository
      git remote add "${1}" "${2}"
      git config "remote.${1}.fetch" "+refs/heads/*:refs/remotes/${1}/*"
    ;;
    "add_branch")
      shift
      # Add a worktree for an existing branch
      git worktree add "${1}"
    ;;
    "new_branch")
      shift
      # Create a new branch
      git worktree add -b "${1}" "${1}" "${2:-main}"
    ;;
    "remove_branch")
      shift 
      # Remove a branch and its worktree
      git worktree remove "${1}"
      git branch -D "${1}"
    ;;
    *)
      echo "Unknown command: ${1}"
    ;;
  esac

}