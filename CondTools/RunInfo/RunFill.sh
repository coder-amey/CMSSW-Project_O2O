
rm test_output.db
rm run.out

scram b
cmsRun test/FillInfoPopConAnalyzer.py > run.out
mv test_output.db test/test_output.db
ls -an
vim run.out
