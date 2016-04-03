#!/bin/bash
set -e # exit with nonzero exit code if anything fails

#!/bin/bash
echo "Starting deployment"
echo "Target: gh-pages branch"

TEMP_DIRECTORY="/tmp/__temp_static_content"
CURRENT_COMMIT=`git rev-parse HEAD`
ORIGIN_URL=`git config --get remote.origin.url`
ORIGIN_URL_WITH_CREDENTIALS=${ORIGIN_URL/\/\/github.com/\/\/$GITHUB_TOKEN@github.com}

echo "Compiling new static content"
cd harp
mkdir $TEMP_DIRECTORY || exit 1
harp compile . $TEMP_DIRECTORY || exit 1
cd ..
cp .gitignore $TEMP_DIRECTORY || exit 1

echo "Checking out gh-pages branch"
git checkout -B gh-pages || exit 1

echo "Removing old static content"
git rm -rf . || exit 1

echo "Copying newly generated static content"
cp -r $TEMP_DIRECTORY/* . || exit 1
cp $TEMP_DIRECTORY/.gitignore . || exit 1

echo "Pushing new content to $ORIGIN_URL"
git config user.name "Travis-CI" || exit 1
git config user.email "travis@jvandemo.com" || exit 1

git add -A . || exit 1
git commit --allow-empty -m "Regenerated static content for $CURRENT_COMMIT" || exit 1

# Force push from the current repo's master branch to the remote
# repo's gh-pages branch. (All previous history on the gh-pages branch
# will be lost, since we are overwriting it.) We redirect any output to
# /dev/null to hide any sensitive credential data that might otherwise be exposed.
git push --force --quiet "https://${GH_TOKEN}@${GH_REF}" master:gh-pages > /dev/null 2>&1

echo "Cleaning up temp files"
rm -Rf $TEMP_DIRECTORY

echo "Deployed Succesfully"
exit 0
