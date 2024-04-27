USE Sandbox
GO

CREATE TRIGGER dbo.TR_BK_Tree_INSERT
ON dbo.BK_Tree
INSTEAD OF INSERT
AS
BEGIN
CREATE TABLE #stage
(
	id int IDENTITY(1,1),
	word varchar(50),
	active bit
)
insert into #stage
select word, active from inserted
DECLARE @i int = 1, 
		@total int = (select count(*) from #stage),
		@insert varchar(50),
		@active bit
--Note: This while loop is time intensive. In my testing, it does about 80,000 inserts per hour but results may vary.
WHILE (@i <= @total)
	BEGIN
		SELECT @insert = word, @active = active FROM #stage WHERE id = @i
		--resets active_flag to 1 if word already in bk_tree structure, this also avoids duplicates of same word.
		IF(exists (select 1 from BK_TREE where word = @insert))
		BEGIN
			update BK_Tree set active = 1 where word = @insert
		END
		--otherwise insert the new word
		ELSE
		BEGIN
			EXEC P_BK_Tree_Insert @insert_word = @insert, @active_flag = 1
		END
		SET @i = @i+1
	END 
RETURN
END;
GO

CREATE TRIGGER dbo.TR_BK_Tree_UPDATE
ON dbo.BK_Tree
AFTER UPDATE
AS
BEGIN
IF EXISTS (select 1 from inserted i join deleted d on i.id = d.id where i.word != d.word OR i.levenshtein_distance != d.levenshtein_distance OR i.parent_node_id != d.parent_node_id OR (d.levenshtein_distance IS NULL AND i.levenshtein_distance IS NOT NULL) OR (d.parent_node_id IS NULL AND i.parent_node_id IS NOT NULL))
	BEGIN
	RAISERROR ('Cannot Update Table. Only Active Flag can be Updated.',-1,-1,'BK_Tree')
	ROLLBACK TRANSACTION;
	RETURN
	END
END;
GO

CREATE TRIGGER dbo.TR_BK_Tree_DELETE
ON dbo.BK_Tree 
INSTEAD OF DELETE 
AS
BEGIN
	RAISERROR ('Cannot Delete - Will destroy structure of BK_Tree. Updating Active Flag to 0 insted.',-1,-1,'BK_Tree')
	UPDATE BK_Tree set active = 0 WHERE word in (select word from deleted)
	RETURN
END;
GO