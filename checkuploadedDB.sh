read -p 'input github token: ' github_token
user_name="astanabe"
repo_name="ClaidentDB"
date="YYYY.MM.DD"
tag_name=`echo "${date}" | perl -npe 's/(\d{4})\.(\d\d)\.(\d\d)/v0.9.$1.$2.$3/'`
buildno=`echo "${date}" | perl -npe 's/(\d{4})\.(\d\d)\.(\d\d)/0.9.$1.$2.$3/'`
NCPU=`grep -c processor /proc/cpuinfo`

# Get a release by tag name
response=`curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${github_token}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/${user_name}/${repo_name}/releases/tags/${tag_name}`

# Prepare checksums
checksums=`echo "${response}" | jq -r '.assets[] | "\(.digest | split(":")[1])  \(.name)"'`

# Perform checking
echo "${checksums}" | xargs -P $NCPU -I {} sh -c 'echo "{}" | sha256sum -c'
ERR=$?
if test $ERR -ne 0; then
echo 'ERROR!: Checksum does not match! Please delete erroneous file(s) from repository and reupload those file(s).' >&2
exit $ERR
fi
