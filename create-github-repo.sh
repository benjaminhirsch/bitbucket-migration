#!/usr/bin/env bash

# Create github repository

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
# shellcheck disable=SC1090
source "$DIR/utils.sh"

createrepo() {
    repo="$1"
    CREATEREPO="{\"name\": \"${repo}\", \"private\": true}"

    is_git "${sourcedir}/${repo}" && {
        echo "Create ${repo} repo for ${organization} organization"
        [[ $DRYRUN != "yes" ]] && {
            curl --user "${USERNAME}:${PASSWORD}" \
                --header "Content-Type: application/json" \
                --data "${CREATEREPO}" \
                "https://api.github.com/orgs/${organization}/repos"
        }
    }
}

process_directory() {
    for dir in "${sourcedir}"/*; do
        repo=$(basename "$dir")
        createrepo "${repo}"
    done
}

usage() {
    echo "$0 --organization ORGANIZATION --source-dir SOURCEDIR [--dry-run] [--help]"
    echo "Create one github repository per each direcotry in source"
    echo
}


DRYRUN=no
while [[ $1 ]]; do
    case "$1" in
        --dry-run)
            DRYRUN=yes
            ;;
        --organization|--org)
            organization="$2"
            ;;
        --source-dir)
            sourcedir="$2"
            ;;
        --help|-h)
            usage
            exit 0
            ;;
    esac
    shift
done


[[ -z $organization ]] || [[ -z $sourcedir ]] && { usage; exit 1; }

read_credentials .github-credentials
process_directory "${sourcedir}" "${organization}"
