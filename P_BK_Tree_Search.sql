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

	;with candidate_nodes as (
		select id, word, active
		from BK_Tree 
		where id = 1
		union all
		select b.id, b.word, b.active
		from candidate_nodes cn
		join BK_Tree b on cn.id = b.parent_node_id
		where b.levenshtein_distance >= dbo.F_Levenshtein(cn.word, @search_word) - @tolerance
		and b.levenshtein_distance <= dbo.F_Levenshtein(cn.word, @search_word) + @tolerance
	)
	select id, word, 1 - (dbo.F_Levenshtein(word,@search_word)*1.0)/(GREATEST(len(word),len(@search_word))*1.0) [similarity_percent]
	from candidate_nodes
	where dbo.F_Levenshtein(word, @search_word) <= @tolerance
	and active = 1
	order by 1 - (dbo.F_Levenshtein(word,@search_word)*1.0)/(GREATEST(len(word),len(@search_word))*1.0) desc

END
GO
