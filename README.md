# FuzzyMatch
The inspiration for this work is that SSIS jobs that use fuzzy matching cannot be setup to run through SQL Server jobs unless you are paying for the enterprise edition of SQL Server. Thus, I set out to create a quick fuzzy match/lookup structure within SQL Server.

The BK-Tree data structure, created in 1973 by W.A.Burkhard and R.M.Keller(hence the name BK), is useful for finding similar words to a dictionary of words, without having to compare with every word in the dictionary.

This project is a t-sql implementation of that data structure, which includes an insert algorithm that creates the BK-tree structure in T-SQL using adjacency list for the table structure storage and a search algorithm that parses the tree to find similar words.

For more information regarding the BK-tree data structure, see: https://dl.acm.org/doi/10.1145/362003.362025

Use a dictionary of words or other strings that you would like to fuzzy match.

For this example I used https://github.com/zeisler/scrabble/blob/master/db/dictionary.csv

Order of SQL for Setup:
1) F_Levenshtein.sql - altered version of https://blog.softwx.net/2014/12/optimizing-levenshtein-algorithm-in-tsql.html
2) BK_Tree.sql
3) BK_Tree_Triggers.sql
4) P_BK_Tree_Search.sql

To initialize the tree, you can run a normal insert call(the insert trigger will take care of the P_BK_Tree_Insert calls) such as:

insert into BK_Tree (word)
select word from Dictionary

BK-Tree insert computes in O(N) time - took 3 mins 36 seconds for the 172k dictionary.
Interesting bit of information: This insert was ~2 hours prior to adding a breadth-first index to BK_Tree table BEFORE the insert is run. This is unusual because most of the times, adding a index to a table before doing a bulk insert will cause the insert to take longer. The key to this one running faster is that part of the insert is to calculate the parent node id for each row, 1 at a time. Calculating this id makes use of the index, hence the speed up when having the index already on the table.

BK-Tree search computes in O(log N) time
Some example outputs of P_BK_Tree_Search on the Scrabble Words Dictionary of words and the runtimes:
<img width="981" alt="image" src="https://github.com/user-attachments/assets/545c53f0-ccff-4a6c-ac10-c3704b5f0657" />
<img width="979" alt="image" src="https://github.com/user-attachments/assets/22cb4bd6-2eaa-4e55-8f7a-35e566313a20" />
<img width="982" alt="image" src="https://github.com/user-attachments/assets/45bfa5a0-2f72-4813-ba95-eee2a7a547e8" />





One last note: To remove a word from the tree, run: UPDATE BK_Tree SET active = 0 WHERE word = 'word'


