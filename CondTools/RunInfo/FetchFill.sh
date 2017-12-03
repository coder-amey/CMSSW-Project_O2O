rm fill.out

scram b
cmsRun test/FillInfoESAnalyzer.py > fill.out
ls -an
vim fill.out
