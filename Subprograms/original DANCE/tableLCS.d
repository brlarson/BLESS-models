--tableLCS.d
--use n by m table to hold character matches, O(nm) space
--use array indexed by substring length to find longest

body table:LongestCommonSubstring is

import length from system:System --get string length function
type startLengthPair is record start:integer, length:integer end record

function atMost(a:startLengthPair,b:startLengthPair) return boolean
is
	declare 
		variable atMost : boolean
	begin
		atMost == (a.length <= b.length)
		;
	 return (atMost)
	end

function substring(x:string,y:string) return boolean
	{substring:: exists j:integer 	
			in (j>=0) and (j<=length(y)-length(x)) that
			all k:integer in 1..lengthx are x[k] = y[j+k] }
is	--a dummy body so "substring" can be used in the postcondition of lcs
	begin
		skip
	end

function lcs(s:string,t:string) 
		return string
	{post:: (substring(lcs,s) and substring(lcs,t)) and 
		(not exists w2:string in true that 
			(substring(w2,s) and substring(w2,t))
			and (length(w2)>length(lcs)) 
		)}
is
	declare
	variable m:integer := length(s);
	variable n:integer := length(t);
	variable table:array[0..m,0..n] of boolean == false;
	variable index:shared integer := 1;
	variable pairs:spread array[1..m] of startLengthPair
	variable result:string := `';

begin  --of lcs
	--fill in table with character matches
forall i:integer in 1..m 
	begin
	forall j:integer in 1..n
		begin
			if
				(s[i]=t[j]) => table[i,j] == true
			[]
				(s[i]<>t[j]) => table[i,j] == false			
			fi
		end  --of forall j
	end --of forall i
{all d:integer in 1..m are
	all e:integer in 1..n are
		table[d,e] iff (s[d]=t[e]) }
	--look for start of substring and then count
;
forall i:integer in 1..m 
	begin
	forall j:integer in 1..n
		begin
			if	--is it a match?
				(not table[i,j]) => skip  --no do nothing
			[]
				(table[i,j]) =>  --yes, check if first character of substring
					if
						(table[(i-1),(j-1)]) => skip --previous chrachter matched, not start
					[]
						(not table[(i-1),(j-1)]) => --found start of substring
							declare		
								variable count:integer := 1;
								variable aPair:startLengthPair  --start/length
								variable position:integer	--place to put start/length
							begin
							{inv:: all f:integer in 1..count are s[(i+f)-1] = t[(j+f)-1] }
							do	--start counting
								((i+count<=m and j+count<=n) cand table[(i+count),(j+count)]) =>
										count := count+1
							od
							{inv}
							; --store it in "pairs"
							aPair.start := i & aPair.length := count &
							fetchadd(index,1,position)	--get position
							;
							pairs[position] := aPair
							end
					fi
			fi
		end  --of forall j
	end --of forall i
--non-overlapping common substrings entered into "pairs", now sort
	;
	declare
	import sort from Sort[startLengthPair m atMost]
	import toString from System
	variable sortedPairs:spread array[1..m] of startLengthPair
	variable c:integer := 0;
	begin
		sort(pairs,sortedPairs,1,index)
		;
		do	--copy lcs to result
			(c<sortedPairs[index].length) =>
				declare 
					variable start:integer := sortedPairs[index].start;
				begin
					result := result + toString(s[start + c])
					;
					c := c+1				
				end
		od
	end  --of sorting
	;
	return result
end  --of lcs

end body