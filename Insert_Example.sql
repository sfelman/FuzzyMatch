USE Sandbox

CREATE TABLE #words (
	id int identity(1,1),
	word varchar(50)
)

Insert into #words (word) 
select word from ScrabbleWords

DECLARE @i int = 1, 
		@total int = (select count(*) from #words),
		@insert varchar(50)

--Note: This while loop is time intesnive. In my testing, it does about 80,000 inserts per hour but results may vary.
WHILE (@i <= @total)
	BEGIN
		SET @insert = (select word from #words where id = @i)
		EXEC P_BK_Tree_Insert @insert_word = @insert
		SET @i = @i+1
	END 
