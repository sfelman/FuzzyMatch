USE Sandbox
GO
/*
IMPORTANT NOTE: 
	The @parent_node_id and @parent_word are used when the function is called recursively.
	When inserting a new word, only use the @insert_word parameter. Otherwise, the intergrity of the BK-Tree will be lost.
	
This SQL code defines a stored procedure named P_BK_Tree_Insert used for inserting nodes into the BK_Tree table. Here's a breakdown of what the code does:

The procedure takes three parameters:

@insert_word: The word to be inserted into the tree.
@parent_node_id: The ID of the parent node. It defaults to NULL.
@parent_word: The word of the parent node. It defaults to NULL.
The procedure first checks if the BK_Tree table is empty. If it is, it assumes the inserted word is the root node and inserts it with a NULL parent node ID and sets its Levenshtein distance and active flag. This block of code temporarily disables and then enables the TR_BK_Tree_INSERT trigger to prevent it from firing during this initial insertion.

If the parent node ID is not provided, it sets it to 1 (the root node) and retrieves the word of the root node.

It calculates the Levenshtein distance between the inserted word and the parent word.

It checks if there is a conflict with the Levenshtein distance for the parent node. If there is a conflict (i.e., another node with the same Levenshtein distance and parent node ID), it recursively calls the P_BK_Tree_Insert procedure with the conflicted node as the parent node until it finds a node without a conflict.

If there is no conflict, it disables and then enables the TR_BK_Tree_INSERT trigger and inserts the new node into the BK_Tree table with the provided word, parent node ID, Levenshtein distance, and active flag.

Overall, this stored procedure is responsible for inserting nodes into the BK tree while handling conflicts with the Levenshtein distance and ensuring the integrity of the tree structure.
*/
CREATE PROCEDURE P_BK_Tree_Insert
	@insert_word varchar(50),
	@parent_node_id int = null,
	@parent_word varchar(50) = null
AS
BEGIN
	--root node
	IF NOT EXISTS (SELECT 1 FROM BK_Tree)
		BEGIN
			--don't forget to change these if you use a different table name than BK_Tree
			EXEC('DISABLE TRIGGER dbo.TR_BK_Tree_INSERT on dbo.BK_Tree;');
			INSERT INTO BK_TREE (word, parent_node_id, levenshtein_distance, active)
			SELECT @insert_word, null, null, 1
			--don't forget to change these if you use a different table name than BK_Tree
			EXEC('ENABLE TRIGGER dbo.TR_BK_Tree_INSERT on dbo.BK_Tree;');
			RETURN 0
		END
	IF @parent_node_id IS NULL
		BEGIN
			SET @parent_node_id = 1
			SET @parent_word = (SELECT word FROM BK_Tree WHERE id = 1)
		END
	--confliction for insert, try again with child node
	DECLARE @parent_insert_distance int = (select dbo.F_Levenshtein(@parent_word,@insert_word))
	DECLARE @conflict_id int = (SELECT id FROM BK_Tree WHERE parent_node_id = @parent_node_id AND @parent_insert_distance = levenshtein_distance)
	IF @conflict_id IS NOT NULL
		BEGIN
			DECLARE @conflict_word varchar(50) = (SELECT word FROM BK_Tree where id = @conflict_id)
			EXEC P_BK_Tree_Insert @insert_word=@insert_word, @parent_node_id=@conflict_id, @parent_word = @conflict_word
		END
	--no Levenshtein Distance Confliction, insert word
	ELSE
		BEGIN
			--don't forget to change these if you use a different table name than BK_Tree
			EXEC('DISABLE TRIGGER dbo.TR_BK_Tree_INSERT on dbo.BK_Tree;');
			INSERT INTO BK_Tree (word, parent_node_id, levenshtein_distance, active)
			VALUES (@insert_word,@parent_node_id,@parent_insert_distance,1)
			--don't forget to change these if you use a different table name than BK_Tree
			EXEC('ENABLE TRIGGER dbo.TR_BK_Tree_INSERT on dbo.BK_Tree;');
			RETURN 0
		END
END
