#!/bin/zsh

SVNURL="https://netoffice.svn.codeplex.com/svn"

svn log -r 89448:106580 $SVNURL > netoffice1.log
svn log -r 74699:89430  $SVNURL > netoffice2.log
svn log -r 72739:74689  $SVNURL > netoffice3.log

svn log -r 89448:106580 --xml $SVNURL > netoffice1.xml
svn log -r 74699:89430  --xml $SVNURL > netoffice2.xml
svn log -r 72739:74689  --xml $SVNURL > netoffice3.xml
