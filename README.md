# FuzzyMatch
Fuzzy Matching Code in T-SQL

The BK-Tree data structure, created in 1973 by W.A.Burkhard and R.M.Keller(hence the name BK), is useful for finding similar words to a dictionary of words, without having to compare with every word in the dictionary.
This project is a t-sql implementation of that data structure, which includes an insert algorithm that creates the BK-tree structure in T-SQL using adjacency list for the table structure storage and a search algorithm that parses the tree to find similar words.

For more information regarding the BK-tree data structure, see: https://dl.acm.org/doi/10.1145/362003.362025

Use a dictionary of words or other strings that you would like to fuzzy match.

For this example I used https://github.com/zeisler/scrabble/blob/master/db/dictionary.csv

Order of SQL for Setup:
1) F_Levenshtein.sql - altered version of https://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-tsql.html
2) BK_Tree.sql
3) P_BK_Tree_Insert.sql
4) BK_Tree_Triggers.sql
5) P_BK_Tree_Search.sql

To initialize the tree, you can run a normal insert call(the insert trigger will take care of the P_BK_Tree_Insert calls) such as:

insert into BK_Tree (word)
select word from Dictionary

BK-Tree insert computes in O(N) time - took ~2 hours for the 172k dictionary.

BK-Tree search computes in O(log N) time

To Remove a word from the tree, run: UPDATE BK_Tree SET active = 0 WHERE word = 'word'

Some example outputs of P_BK_Tree_Search on the Scrabble Words Dictionary of words and the runtimes:
![image](https://github.com/sfelman/FuzzyMatch/assets/7735212/07119d83-70b6-4f18-83e2-90f5118b5ec7)
![image](https://github.com/sfelman/FuzzyMatch/assets/7735212/7b9decc8-daa8-404f-be28-56e327fcbce6)
![image](https://github.com/sfelman/FuzzyMatch/assets/7735212/0b46befa-4bfd-4628-adab-6b2e2f9d63a2)
