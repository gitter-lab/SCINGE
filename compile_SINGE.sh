#!/bin/bash
# Compile SINGE_Test.m, SINGE_GLG_Test.m, and SINGE_Aggregate.m
# Run from the repository base directory
# Store the md5sum of the source MATLAB files and binaries
# If a directory is provided as an argument, copy the binaries and md5sum file there

# Test the updated compiled glmnetMex.mexa64
mv glmnet_matlab/glmnetMex.mexa64 glmnet_matlab/glmnetMex.mexa64.bak
cp glmnet_matlab_64/glmnetMex.mexa64 glmnet_matlab/glmnetMex.mexa64

# Compile SINGE creating the binaries SINGE_Test.m, SINGE_GLG_Test.m, and SINGE_Aggregate.m
# SINGE_Test.m is compiled so that it can be tested to ensure the MATLAB version of SINGE works
mcc -N -m -R -singleCompThread -R -nodisplay -R -nojvm -a ./glmnet_matlab/ -a ./code/ tests/SINGE_Test.m
mv SINGE_Test tests/SINGE_Test
mv readme.txt tests/readme_SINGE_Test.txt
mv run_SINGE_Test.sh tests/run_SINGE_Test.sh

mcc -N -m -R -singleCompThread -R -nodisplay -R -nojvm -a ./glmnet_matlab/ -a ./code/ SINGE_GLG_Test.m
mv readme.txt readme_SINGE_GLG_Test.txt

mcc -N -m -R -singleCompThread -R -nodisplay -R -nojvm -a ./code/ SINGE_Aggregate.m
mv readme.txt readme_SINGE_Aggregate.txt

# Restore glmnetMex.mexa64
mv glmnet_matlab/glmnetMex.mexa64.bak glmnet_matlab/glmnetMex.mexa64

# Store the md5sums of all .m files tracked in the git repository and the binaries
# See https://stackoverflow.com/questions/15606955/how-can-i-make-git-show-a-list-of-the-files-that-are-being-tracked/15606998
# and https://stackoverflow.com/questions/13335837/how-to-grep-for-a-file-extension
md5sum $(git ls-tree -r HEAD --name-only | grep '.*\.m$') tests/SINGE_Test SINGE_GLG_Test SINGE_Aggregate > code.md5
cat code.md5

# Copy the binary and md5sum file
if [ $# -gt 0 ]; then
  basedir=$1

  # Use the md5sum of the SINGE_GLG_Test binary as a subdirectory name
  # See array assignment from https://stackoverflow.com/questions/3679296/only-get-hash-value-using-md5sum-without-filename
  binary_md5=($(md5sum SINGE_GLG_Test))
  outdir=$basedir/$binary_md5

  printf "Copying SINGE_Test, SINGE_GLG_Test, SINGE_Aggregate, and code.md5 to %s\n" $outdir
  mkdir -p $outdir
  cp tests/SINGE_Test $outdir
  cp SINGE_GLG_Test $outdir
  cp SINGE_Aggregate $outdir
  cp code.md5 $outdir
fi
