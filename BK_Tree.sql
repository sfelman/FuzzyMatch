USE [Sandbox]
GO

CREATE TABLE dbo.BK_Tree(
	id int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_BK_Tree_id] PRIMARY KEY CLUSTERED,
	word nvarchar(50) NOT NULL CONSTRAINT [UQ_BK_Tree_word] UNIQUE,
	parent_node_id int NULL,
	levenshtein_distance int NULL,
	active bit NOT NULL DEFAULT 1
);
GO

CREATE TRIGGER dbo.TR_BK_Tree_INSERT
ON dbo.BK_Tree
AFTER INSERT
AS
BEGIN
RAISERROR ('Please Use P_BK_Tree_Insert to Insert into this table',-1,-1,'BK_Tree')
ROLLBACK TRANSACTION;
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
	RAISERROR ('Cannot Delete. Deleting will destroy the structure of the BK_Tree. Update Active Flag to 0 instead of Deleting.',-1,-1,'BK_Tree')
	ROLLBACK TRANSACTION;
	RETURN
END;
GO