USE Sandbox
GO

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