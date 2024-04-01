USE [Sandbox]
GO
/*
This SQL code creates a table named BK_Tree with the following columns:

id: An auto-incremented integer column serving as the primary key.
word: A Unicode string column with a maximum length of 50 characters, storing the word for each node in the BK tree. It is enforced to be unique.
parent_node_id: An integer column referencing the id column of the same table, indicating the parent node of each node in the tree. It allows NULL values to represent the root node.
levenshtein_distance: An integer column representing the Levenshtein distance of the word stored in the node from the word stored in its parent node. It allows NULL values.
active: A boolean column (bit type) indicating whether the node is active or not. It has a default value of 1 (true).
Additionally, the code defines three triggers:

TR_BK_Tree_INSERT: This trigger fires after an insert operation on the BK_Tree table. It raises an error indicating that inserts should be done using a stored procedure named P_BK_Tree_Insert. It then rolls back the transaction.

TR_BK_Tree_UPDATE: This trigger fires after an update operation on the BK_Tree table. It checks if any of the columns other than the active flag have been modified. If any modifications are detected, it raises an error indicating that only the active flag can be updated. It then rolls back the transaction.

TR_BK_Tree_DELETE: This trigger fires instead of a delete operation on the BK_Tree table. It raises an error indicating that deletion is not allowed as it would destroy the structure of the BK tree. It advises updating the active flag to 0 instead of deleting. It then rolls back the transaction.

These triggers enforce certain constraints and behaviors to maintain the integrity and structure of the BK tree stored in the BK_Tree table.
*/
	
CREATE TABLE dbo.BK_Tree(
	id int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_BK_Tree_id] PRIMARY KEY CLUSTERED,
	word nvarchar(50) NOT NULL CONSTRAINT [UQ_BK_Tree_word] UNIQUE,
	parent_node_id int NULL REFERENCES BK_Tree(id),
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
