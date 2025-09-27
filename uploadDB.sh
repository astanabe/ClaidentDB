read -p 'input github token: ' github_token
user_name="astanabe"
repo_name="ClaidentDB"
date=`TZ=JST-9 date +%Y.%m.%d`
NCPU=`grep -c processor /proc/cpuinfo` || exit $?

# Make package

# Make check/cat/extraction scripts

# Make download scripts


# Get release list
response=`curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases`

# Check tag and create release if not exist
if test `echo ${response} | jq '.[] | .tag_name' | grep -c "${date}"` -eq 0; then
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases \
  -d "{\"tag_name\":\"${date}\",\"name\":\"${repo_name} ${date}\",\"body\":\"BLAST DBs, Taxonomy DBs and UCHIME DBs generated from dump data of NCBI nt and converter script (version of ${date}).\",\"draft\":false,\"prerelease\":true,\"generate_release_notes\":false,\"make_latest\":\"true\"}"
fi

# Get a release by tag name
response=`curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases/tags/${date}`

# Prepare upload URL
upload_url=`echo "${response}" | jq '. | .upload_url' | tr -d '"'`
upload_url="${upload_url%%\{*}?name="

# Perform upload
