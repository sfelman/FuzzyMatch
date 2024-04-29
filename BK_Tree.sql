USE [Sandbox]
GO
	
CREATE TABLE dbo.BK_Tree(
	id int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_BK_Tree_id] PRIMARY KEY CLUSTERED,
	word varchar(50) NOT NULL CONSTRAINT [UQ_BK_Tree_word] UNIQUE,
	parent_node_id int NULL,
	levenshtein_distance int NULL,
	active bit NOT NULL DEFAULT 1
);
GO
