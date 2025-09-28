read -p 'input github token: ' github_token
user_name="astanabe"
repo_name="ClaidentDB"
date="YYYY.MM.DD"
tag_name=`echo "${date}" | perl -npe 's/(\d{4})\.(\d\d)\.(\d\d)/v0.9.$1.$2.$3/'`
buildno=`echo "${date}" | perl -npe 's/(\d{4})\.(\d\d)\.(\d\d)/0.9.$1.$2.$3/'`
NCPU=`grep -c processor /proc/cpuinfo` || exit $?

# Make download scripts
rm -f downloadDB-${buildno}.sh || exit $?
for asset_file in install*-${buildno}.sh *.sha256 *.xz
do echo "aria2c -c https://github.com/${user_name}/${repo_name}/releases/download/${tag_name}/${asset_file}" >> downloadDB-${buildno}.sh
done

# Get release list
response=`curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases`

# Check tag and create release if not exist
if test `echo ${response} | jq '.[] | .tag_name' | grep -c "${tag_name}"` -eq 0; then
curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases \
  -d "{\"tag_name\":\"${tag_name}\",\"name\":\"${repo_name} ${tag_name}\",\"body\":\"BLAST DBs and Taxonomy DBs generated from NCBI nt downloaded on YYYY-MM-DD and UCHIME DBs generated from INSD on YYYY-MM-DD.\",\"draft\":false,\"prerelease\":true,\"generate_release_notes\":false,\"make_latest\":\"true\"}"
fi

# Get a release by tag name
response=`curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases/tags/${tag_name}`

# Prepare upload URL
upload_url=`echo "${response}" | jq '. | .upload_url' | tr -d '"'`
upload_url="${upload_url%%\{*}?name="

# Perform upload
for asset_file in downloadDB-${buildno}.sh install*-${buildno}.sh *.sha256 *.xz
do curl -L \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  -H "Content-Type: application/octet-stream" \
  "${upload_url}${asset_file}" \
  -T "${asset_file}"
done
