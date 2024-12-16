USE Sandbox
GO


CREATE TRIGGER dbo.TR_BK_Tree_UPDATE
ON dbo.BK_Tree
AFTER UPDATE
AS
BEGIN
IF EXISTS (SELECT 1 FROM inserted i join deleted d on i.id = d.id WHERE i.word != d.word OR i.levenshtein_distance != d.levenshtein_distance OR i.parent_node_id != d.parent_node_id OR (d.levenshtein_distance IS NULL AND i.levenshtein_distance IS NOT NULL) OR (d.parent_node_id IS NULL AND i.parent_node_id IS NOT NULL))
	BEGIN
	RAISERROR ('Cannot Update Table. Only Active Flag can be Updated.',-1,-1,'BK_Tree')
	ROLLBACK TRANSACTION;
	RETURN
	END
END;
GO


CREATE TRIGGER dbo.TR_BK_Tree_INSERT
ON dbo.BK_Tree
AFTER INSERT
AS
BEGIN

ALTER TABLE BK_Tree DISABLE TRIGGER TR_BK_Tree_UPDATE

--variables that for calculating the parent_node_id
DECLARE @insert_word varchar(50),
		@insert_word_id int,
		@parent_node_id int = 1,
		@parent_word varchar(50) = (SELECT word FROM BK_Tree WHERE id = 1),
		@parent_levenshtein_distance int,
		@conflict_id int

--null parent_node_id means that the row has not yet been added to the tree. (except for the root node id = 1, all should have a parent_node_id)
WHILE exists(SELECT 1 FROM BK_Tree WHERE parent_node_id is null and id != 1)
BEGIN
	if(@insert_word is null)
	BEGIN
		SELECT top 1 @insert_word = word, @insert_word_id = id FROM BK_Tree WHERE parent_node_id is null and id != 1 ORDER BY id ASC
	END
	set @parent_levenshtein_distance = (select dbo.F_Levenshtein(@parent_word,@insert_word))
	set @conflict_id = (select id from BK_Tree where parent_node_id = @parent_node_id and levenshtein_distance = @parent_levenshtein_distance)
	--no confliction, update the parent node
	if @conflict_id is null
	BEGIN
		UPDATE BK_tree set parent_node_id = @parent_node_id, levenshtein_distance = @parent_levenshtein_distance WHERE id = @insert_word_id
		set @parent_node_id = 1 
		set @parent_word = (SELECT word FROM BK_Tree WHERE id = 1)
		set @insert_word = null
	END
	--confliction for insert, try again with child node
	ELSE
	BEGIN
		set @parent_node_id = @conflict_id
		set @parent_word = (SELECT word FROM BK_Tree WHERE id = @conflict_id)
	END
END

ALTER TABLE BK_Tree ENABLE TRIGGER TR_BK_Tree_UPDATE;
RETURN
END;
GO

CREATE TRIGGER dbo.TR_BK_Tree_DELETE
ON dbo.BK_Tree 
INSTEAD OF DELETE 
AS
BEGIN
	RAISERROR ('Cannot Delete - Will destroy structure of BK_Tree. Updating Active Flag to 0 instead.',-1,-1,'BK_Tree')
	UPDATE BK_Tree set active = 0 WHERE word in (SELECT word FROM deleted)
	RETURN
END;
GO
