
rm test_output.db
rm run.out

scram b
cmsRun FillInfoPopConAnalyzer.py > run.out
ls -an
vim run.out
