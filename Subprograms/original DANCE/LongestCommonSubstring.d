face LongestCommonSubstring is

import length from system:System 

function substring(x:string,y:string) return boolean
	{substring:: exists j:integer 	
			in (j>=0) and (j<=length(y)-length(x)) that
			all k:integer in 1..lengthx are x[k] = y[j+k] }


function lcs(s:string,t:string) 
		return string
	{post:: (substring(lcs,s) and substring(lcs,t)) and 
		(not exists w2:string in true that 
			(substring(w2,s) and substring(w2,t))
			and (length(w2)>length(lcs)) 
		)}
		
end face  --of LongestCommonSubstring
