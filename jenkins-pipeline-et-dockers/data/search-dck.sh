#!/usr/bin/env bash

REPOSITORY=${REPOSITORY:-$1}
REGISTRY=${REGISTRY:-docker.io}


#
#  Docker funcs
#
    d__docker_relative_repository_name_from_URL() {
        # given $REGISTRY/repo/path:tag, return the repo/path
        set +o pipefail
        echo ${1-} | sed -e "s|^$REGISTRY/||" | cut -d: -f1
    }

    d___version_sort() {
        # read stdin, sort by version number descending, and write stdout
        # assumes X.Y.Z version numbers

        # this will sort tags like pr-3001, pr-3002 to the END of the list
        # and tags like 2.1.4 BEFORE 2.1.4-gitsha

        sort -s -t- -k 2,2nr |  sort -t. -s -k 1,1nr -k 2,2nr -k 3,3nr -k 4,4nr
    }

    d__basic_auth() {
        #
        # read basic auth credentials from `docker login`
        #
        cat ~/.docker/config.jq | jq '.auths["harbor.x3rus.com"].auth'
    }


    d__registry__tags_list() {

        # return a list of available tags for the given repository sorted
        # by version number, descending
        #
        # Get tags list from dockerhub using v2 api and an auth.docker token


        local rel_repository=$(d__docker_relative_repository_name_from_URL ${1})
        [ -z "$rel_repository" ] && return

        local TOKEN=$(curl -s -H "Authorization: Basic $(d__basic_auth)" \
                       -H 'Accept: application/jq' \
                       "https://harbor.x3rus.com/token?service=harbor-registry&scope=repository:$rel_repository:pull" | jq .token)


        curl -s -H "Authorization: Bearer $TOKEN" -H "Accept: application/jq" \
                "https://harbor.x3rus.com/v2/$rel_repository/tags/list" |
                jq .tags |
                jq -a |
                d___version_sort
    }


d__registry__tags_list $REPOSITORY
