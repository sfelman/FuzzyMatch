USE [Sandbox]
GO
/****** Object:  UserDefinedFunction [dbo].[F_Levenshtein]    Script Date: 3/19/2024 9:17:59 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[F_Levenshtein](
    @string_input1 nvarchar(4000)
  , @string_input2 nvarchar(4000)
)
RETURNS int
WITH SCHEMABINDING
AS
BEGIN
    DECLARE @distance int = 0 -- return variable
          , @v0 nvarchar(4000)-- running scratchpad for storing computed distances
          , @start int = 1      -- index (1 based) of first non-matching character between the two string
          , @i int, @j int      -- loop counters: i for s string and j for t string
          , @diag int          -- distance in cell diagonally above and left if we were using an m by n matrix
          , @left int          -- distance in cell to the left if we were using an m by n matrix
          , @sChar nchar      -- character at index i from s string
          , @thisJ int          -- temporary storage of @j to allow SELECT combining
          , @jOffset int      -- offset used to calculate starting value for j loop
          , @jEnd int          -- ending value for j loop (stopping point for processing a column)
          -- get input string lengths including any trailing spaces (which SQL Server would otherwise ignore)
          , @Len1 int = datalength(@string_input1) / datalength(left(left(@string_input1, 1) + '.', 1))    -- length of smaller string
          , @Len2 int = datalength(@string_input2) / datalength(left(left(@string_input2, 1) + '.', 1))    -- length of larger string
          , @lenDiff int      -- difference in length between the two strings
		  , @max int
    IF (@Len1 > @Len2) BEGIN
        SELECT @v0 = @string_input1, @i = @Len1 -- temporarily use v0 for swap
        SELECT @string_input1 = @string_input2, @Len1 = @Len2
        SELECT @string_input2 = @v0, @Len2 = @i
    END
    SELECT @max = @Len2
         , @lenDiff = @Len2 - @Len1
    IF @lenDiff > @max RETURN NULL

    -- suffix common to both strings can be ignored
    WHILE(@Len1 > 0 AND SUBSTRING(@string_input1, @Len1, 1) = SUBSTRING(@string_input2, @len2, 1))
        SELECT @Len1 = @Len1 - 1, @len2 = @len2 - 1

    IF (@Len1 = 0) RETURN CASE WHEN @len2 <= @max THEN @len2 ELSE NULL END

    -- prefix common to both strings can be ignored
    WHILE (@start < @Len1 AND SUBSTRING(@string_input1, @start, 1) = SUBSTRING(@string_input2, @start, 1)) 
        SELECT @start = @start + 1
    IF (@start > 1) BEGIN
        SELECT @Len1 = @Len1 - (@start - 1)
             , @len2 = @len2 - (@start - 1)

        -- if all of shorter string matches prefix and/or suffix of longer string, then
        -- edit distance is just the delete of additional characters present in longer string
        IF (@Len1 <= 0) RETURN CASE WHEN @len2 <= @max THEN @len2 ELSE NULL END

        SELECT @string_input1 = SUBSTRING(@string_input1, @start, @Len1)
             , @string_input2 = SUBSTRING(@string_input2, @start, @len2)
    END

    -- initialize v0 array of distances
    SELECT @v0 = '', @j = 1
    WHILE (@j <= @len2) BEGIN
        SELECT @v0 = @v0 + NCHAR(CASE WHEN @j > @max THEN @max ELSE @j END)
        SELECT @j = @j + 1
    END
    
    SELECT @jOffset = @max - @lenDiff
         , @i = 1
    WHILE (@i <= @Len1) BEGIN
        SELECT @distance = @i
             , @diag = @i - 1
             , @sChar = SUBSTRING(@string_input1, @i, 1)
             -- no need to look beyond window of upper left diagonal (@i) + @max cells
             -- and the lower right diagonal (@i - @lenDiff) - @max cells
             , @j = CASE WHEN @i <= @jOffset THEN 1 ELSE @i - @jOffset END
             , @jEnd = CASE WHEN @i + @max >= @len2 THEN @len2 ELSE @i + @max END
        WHILE (@j <= @jEnd) BEGIN
            -- at this point, @distance holds the previous value (the cell above if we were using an m by n matrix)
            SELECT @left = UNICODE(SUBSTRING(@v0, @j, 1))
                 , @thisJ = @j
            SELECT @distance = 
                CASE WHEN (@sChar = SUBSTRING(@string_input2, @j, 1)) THEN @diag                    --match, no change
                     ELSE 1 + CASE WHEN @diag < @left AND @diag < @distance THEN @diag    --substitution
                                   WHEN @left < @distance THEN @left                    -- insertion
                                   ELSE @distance                                        -- deletion
                                END    END
            SELECT @v0 = STUFF(@v0, @thisJ, 1, NCHAR(@distance))
                 , @diag = @left
                 , @j = case when (@distance > @max) AND (@thisJ = @i + @lenDiff) then @jEnd + 2 else @thisJ + 1 end
        END
        SELECT @i = CASE WHEN @j > @jEnd + 1 THEN @Len1 + 1 ELSE @i + 1 END
    END
    RETURN CASE WHEN @distance <= @max THEN @distance ELSE NULL END
END