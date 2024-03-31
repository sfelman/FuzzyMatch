# FuzzyMatch
Fuzzy Matching Code in T-SQL

Use a dictionary of words or other strings that you would like to fuzzy match
For this example I used https://github.com/zeisler/scrabble/blob/master/db/dictionary.csv

Order of SQL 
1) F_Levenshtein.sql - altered version of https://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-tsql.html
2) BK_Tree.sql
3) P_BK_Tree_Insert.sql
4) P_BK_Tree_Search.sql
5) Run something similar to Insert_Example.sql to initialize the tree. Note: each insert will need to be run 1 at a time.

BK-Tree insert computes in O(N) time - took ~2 hours for the 172k dictionary

BK-Tree search computes in O(log N) time

To Remove a word from the tree, run: UPDATE BK_Tree SET active = 0 WHERE word = 'word'
