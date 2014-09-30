#!/bin/bash

quiet_git() {
    stdout=git_stdout.txt
    stderr=git_stderr.txt

    if ! git "$@" </dev/null >$stdout 2>$stderr; then
        cat $stderr >&2
        rm -f $stdout $stderr
        exit 1
    fi

    rm -f $stdout $stderr
}

SVN_URL="https://netoffice.svn.codeplex.com/svn"

GIT_DIR=git
SVN_DIR=wrapper_r$REVISION
REVISION_LOG=revisions.log
LAST_REVISION=$(cat last_revision.txt)

#rm -rf $GIT_DIR
#mkdir $GIT_DIR
#quiet_git init $GIT_DIR

echo "Importing SVN repository to Git"
echo "SVN URL: $SVN_URL"
echo "Continuing after revision $LAST_REVISION"
echo

while read p; do
  IFS='|' read -ra INFO <<< "$p"

  REVISION=${INFO[0]}
  AUTHOR=${INFO[1]}
  DATE=${INFO[2]}
  MESSAGE_FILE=log/message_r$REVISION.txt

  if [ "$REVISION" -le "$LAST_REVISION" ]; then
    echo "Skipping revision $REVISION..."
    continue
  fi

  SVN_DIR=svn_r$REVISION

  echo "Exporting revision r$REVISION"
  svn export --force -r $REVISION --quiet $SVN_URL $SVN_DIR
  
  rm -rf $SVN_DIR/.git
  mv $GIT_DIR/.git $SVN_DIR
  cd $SVN_DIR

  echo "Committing new revision to Git"
  echo "    details: author=$AUTHOR date=$DATE"
  quiet_git add -A
  quiet_git commit --author="$AUTHOR" --date="$DATE" -F "../$MESSAGE_FILE"
  
  cd ..
  mv $SVN_DIR/.git $GIT_DIR
  rm -rf $SVN_DIR
  
  echo "$REVISION" > last_revision.txt
  echo "Done importing revision r$REVISION"
  echo
done < $REVISION_LOG

