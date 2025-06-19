
get_github_release_version() {
    local repo=$1
    if [[ $repo =~ releases/latest ]]; then
        local url="https://api.github.com/repos/$repo"
    else
        local url="https://api.github.com/repos/$repo/releases/latest"
    fi
    echo $(curl -sfL $url | grep -oE '"tag_name": "[^"]+"' | head -n1 | cut -d'"' -f4)
}
export PROXY_CR_VERSION=$(get_github_release_version "DaoCloud/crproxy")