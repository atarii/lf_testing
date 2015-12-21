@rem New Code Review branch
@rem For use with SourceTreeCustomActions
@rem Parameters: $REPO $SHA

set prefix=CR

@rem cmd
set sha1=%2

set repo=%1
cd %repo%
echo Using repo "%repo%"

set origin=master
git checkout %origin%
if %errorlevel% neq 0 exit 1
echo Using origin "%origin%"

for /f %%i in ('git branch -r --contains %sha1%') do set remote-branch=%%i
echo Got remote-branch "%remote-branch%"
if '%remote-branch%' equ '' exit 1
if %remote-branch% equ '*' exit 1

set branch=%remote-branch:~7%
echo Got branch "%branch%"
git checkout -b %branch% %remote-branch%
if %errorlevel% neq 0 exit 1
if '%branch%' equ '' exit 1
if %branch% equ '*' exit 1

for /f %%i in ('git merge-base %branch% %origin%') do set head=%%i
git checkout %head%
echo Got head "%head%"

set review-branch=%prefix%-%branch%
git branch %review-branch%
if %errorlevel% neq 0 exit 1
git checkout %review-branch%
for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set created-branch=%%i
if %created-branch% neq %review-branch% exit 1
echo Created review branch "%review-branch%"

git merge --no-ff %branch%
echo Merged branch "%branch%"
if %errorlevel% neq 0 exit 1

git branch -d %branch%
if %errorlevel% neq 0 exit 1
echo Cleaned up "%branch%"

echo Done!
