# FuzzyMatch
Fuzzy Matching Code in T-SQL

Use a dictionary of words or other strings that you would like to fuzzy match.

For this example I used https://github.com/zeisler/scrabble/blob/master/db/dictionary.csv

Order of SQL for Setup:
1) F_Levenshtein.sql - altered version of https://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-tsql.html
2) BK_Tree.sql
3) P_BK_Tree_Insert.sql
4) BK_Tree_Triggers.sql
5) P_BK_Tree_Search.sql

Note: To initialize the tree, you can run a normal insert call(the insert trigger will take care of the P_BK_Tree_Insert calls).

BK-Tree insert computes in O(N) time - took ~2 hours for the 172k dictionary.

BK-Tree search computes in O(log N) time

To Remove a word from the tree, run: UPDATE BK_Tree SET active = 0 WHERE word = 'word'

Some example outputs of P_BK_Tree_Search on the Scrabble Words Dictionary of words and the runtimes:
![image](https://github.com/sfelman/FuzzyMatch/assets/7735212/07119d83-70b6-4f18-83e2-90f5118b5ec7)
![image](https://github.com/sfelman/FuzzyMatch/assets/7735212/7b9decc8-daa8-404f-be28-56e327fcbce6)
![image](https://github.com/sfelman/FuzzyMatch/assets/7735212/0b46befa-4bfd-4628-adab-6b2e2f9d63a2)
