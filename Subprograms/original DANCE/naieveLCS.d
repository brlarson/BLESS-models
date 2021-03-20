--naieveLCS.d
--no concurrency O(nm) execution time
--no tables  O(n+m) space


body naieve:LongestCommonSubstring is

	import length from system:System --get string length function

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
		variable i:integer := 1;
		variable j:integer := 1;
		variable maxLengthSoFar:integer := 1;
		variable w:string := `';
 begin
 do (i<=length(s)) =>
 		begin
 		do (j<=length(s)) =>
 			begin 						
			if
				(s[i]<>t[j]) => skip
			[]
				(s[i]=t[j]) => --character match
				declare
					variable l:integer := 1;
					variable p:string := `'; --hold partially matched string
				begin  --check how many more characters match
				p[1] := s[i]	--store first matched character
				;
				do ((s[i+l]=t[j+l]) and (i+l <= length(s)) and (j+l <= length(t)) ) =>
					begin
						p[l+1] := s[i+l];	--store next matching character
						l := l+1			--try next character
					end
				od
				;
				if 
					(l <= maxLengthSoFar) => skip
				[]
					(l > maxLengthSoFar) =>
						begin
							maxLengthSoFar := l;
							w := p	--copy longest string so far
						end
				fi
				end --character match
			fi
			;
	  	j := j+1
			end 
		od  --of do j
		;
		i := i+1
 		end	
 	od --of do i
 	;
 	return w
 end --of naieve lcs 
 
end body		--of naieve
