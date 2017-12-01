rm fill.out

scram b
cmsRun FillInfoESAnalyzer.py > fill.out
ls -an
vim fill.out
