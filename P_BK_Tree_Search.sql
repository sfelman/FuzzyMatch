USE [Sandbox]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[P_BK_Tree_Search]
	@search_word varchar(50),
	@tolerance int
AS
BEGIN

	IF OBJECT_ID('tempdb..#Matches') IS NOT NULL
		TRUNCATE TABLE #Matches
	ELSE
		CREATE TABLE #Matches (
			id int,
			word varchar(50),
			similarity tinyint
		)

	IF OBJECT_ID('tempdb..#Candidate_Nodes') IS NOT NULL
		Truncate TABLE #Candidate_Nodes
	ELSE
	CREATE TABLE #Candidate_Nodes(
		id int not null PRIMARY KEY,
		word varchar(50) not null,
		search_flag bit not null,
		active bit not null
	)
	insert into #Candidate_Nodes 
	select id, word, 1, active
	from BK_Tree 
	where parent_node_id is null

	while(exists (select 1 from #Candidate_Nodes where search_flag = 1))
	BEGIN
		update #Candidate_Nodes set search_flag = 0
		insert into #Matches (id,word,similarity) 
		select id
			   ,word
			   ,100 - (((dbo.F_Levenshtein(word,@search_word)*1.0)/(GREATEST(len(word),len(@search_word))*1.0))*100)
		from #Candidate_Nodes 
		where dbo.F_Levenshtein(word, @search_word) <= @tolerance
		and active = 1
		
		insert into #Candidate_Nodes
		select b.id, b.word, 1, b.active
		from BK_Tree b
		cross apply #Candidate_Nodes c
		where b.parent_node_id = c.id
		and levenshtein_distance >= dbo.F_Levenshtein(c.word, @search_word) - @tolerance
		and levenshtein_distance <= dbo.F_Levenshtein(c.word, @search_word) + @tolerance
		
		delete #Candidate_Nodes where search_flag = 0
	END
	select id, word, similarity/100.0 [similarity_percent] from #Matches order by similarity desc
END
GO