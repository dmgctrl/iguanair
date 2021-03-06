#!/bin/bash
# File: make_version.sh (based on make_version.bat)
# What: Create version.h and load up with SVN build version numbers.
#
# svnversion switches:
#   -n Omit the usual trailing newline from the output.
#
# Set paths for Visual Studio "Build Events > Pre-Build Event"
# If no path defined, assume current dir.
# (Allow running outside Visual Studio.)

# Determine the bin path from the $0 argument
BINPATH=$(dirname $(readlink -f $0))

SRCPATH=$(dirname $BINPATH)

# if the SRCPATH is passed use it, otherwise generate a dummy
if [ "$SRCPATH" == "" ]; then
  if [ -e $BINPATH/VERSION_H_GENERATED.txt ]; then
    exit
  fi
  SVNPATH=REM
else
  SVNPATH=$(which svnversion)
  date > $BINPATH/VERSION_H_GENERATED.txt
fi

# the output is a temporary file that will be moved later
OUTPUT=version.h.new

echo "#ifndef _VERSION_H_"  > $OUTPUT
echo "#define _VERSION_H_" >> $OUTPUT
echo >> $OUTPUT
echo "#include \"release.h\"" >> $OUTPUT
echo >> $OUTPUT
echo /*----------------------------------------------------------------------------------- >> $OUTPUT
echo This file has been generated by make_version.sh and should not be manually modified. >> $OUTPUT
# -------------- Removing the two lines that regularly change making diffs useless -------------
# echo Source folder: $cd$  >> $OUTPUT
# echo Creation date: $date$  Time:$time$ >> $OUTPUT
# ----------------------------------------------------------------------------------------------
echo "Example:   return IGUANAIR_VER_STR(IGUANAIR_VERSION);"  >> $OUTPUT
echo ------------------------------------------------------------------------------------ >> $OUTPUT
echo svnversion.exe version: >> $OUTPUT
$SVNPATH --version >> $OUTPUT
echo ------------------------------------------------------------------------------------ >> $OUTPUT
# From svnversion.exe -h
echo The version number will be a single number if the working copy is single revision, >> $OUTPUT
echo unmodified, not switched and with an URL that matches the TRAIL_URL argument. >> $OUTPUT
echo If the working copy is unusual the version number will be more complex: >> $OUTPUT
echo   4123:4168     mixed revision working copy >> $OUTPUT
echo   4168M         modified working copy 	>> $OUTPUT
echo   4123S         switched working copy 	>> $OUTPUT
echo   4123P         partial working copy, from a sparse checkout >> $OUTPUT
echo   4123:4168MS   mixed revision, modified, switched working copy >> $OUTPUT			
echo  If invoked on a directory that is not a working copy, an exported directory say, >> $OUTPUT
echo  the program will output 'exported'.>> $OUTPUT
echo -----------------------------------------------------------------------------------*/ >> $OUTPUT

# Include manually edited header file for release versions.
# Application dialogs use IDC_RELEASE_NUMBER for dialog formatting.
#echo '#include "release.h"	// Manually edited release version numbers.' >> $OUTPUT
#echo >> $OUTPUT

# Alert user if DEBUG version was fielded.
echo '#ifdef _DEBUG' >> $OUTPUT
echo "#define IGUANAIR_VER_STR(a) \"DEBUG!: $USER@$HOSTNAME\"" >> $OUTPUT
echo '#else' >> $OUTPUT

if [ "$SVNPATH" == "REM" ]; then
  echo "#define IGUANAIR_VER_STR(a) \"  Built on $HOSTNAME\"" >> $OUTPUT
else
  echo "#define IGUANAIR_VER_STR(a) \"Release: \"a\"-\"IGUANAIR_RELEASE\"-\"IGUANAIR_VERSION" >>   $OUTPUT
fi

echo "#endif" >> $OUTPUT
echo >> $OUTPUT


# IguanaIR base version level:
echo "#define IGUANAIR_VERSION \"\\" >> $OUTPUT
$SVNPATH -n  $SRCPATH >>        $OUTPUT
echo \" >> $OUTPUT

echo >> $OUTPUT
echo "#endif" >> $OUTPUT

# Always write a temp file then move it so that parallel builds do not stomp
# on each other's versions file.  Further, if the content has not changed
# then do NOT replace the existing file so that later builds will not think
# that the file changed based on the timestamp.
diff $OUTPUT $SRCPATH/version.h > /dev/null 2>&1
if [ "$?" != "0" ]; then
  grep exported\" $OUTPUT > /dev/null 2>&1
  if [ "$?" != "0" ]; then
    cp $OUTPUT $SRCPATH/version.h
  fi
fi
rm $OUTPUT
