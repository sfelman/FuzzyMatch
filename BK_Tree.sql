USE [Sandbox]
GO

CREATE TABLE dbo.BK_Tree(
	id int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_BK_Tree_Id] PRIMARY KEY NONCLUSTERED,
	word varchar(50) NOT NULL CONSTRAINT [UQ_BK_Tree_word] UNIQUE,
	parent_node_id int NULL constraint [FK_BK_Tree_Parent_Node_Id_BK_Tree_Id] FOREIGN KEY (Parent_Node_Id) references BK_Tree(id),
	levenshtein_distance int NULL,
	active bit NOT NULL DEFAULT 1
);
GO

CREATE CLUSTERED INDEX [IX_BK_Tree_Breadth_First] on BK_Tree(Parent_Node_Id, Id)
