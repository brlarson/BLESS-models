
body partitionSort:Sort[rt `<' `='] is

	required
		type rt 		--the record type of the array to be sorted
		function `<'(left:rt right:rt) return lt:boolean	--is a<b?
			{transitivity:c d e: ((c<d) and (d<e)) implies (c<e)}
		function `='(a:rt b:rt) return eq:boolean		--is a=b?
			{reflexive:c d: ((c=d) iff (d=c))}
			{transitiveEquality:c d e: ((c=d) and (d=e)) implies (c=e)}
			{notUnequal:c d:(not(c<d) and not(d>c)) iff (c=d)}
	end required


procedure partition(i:integer j:integer a:spread array i..j of rt 
			b:spread array i..j of rt pl:integer ph:integer) 
	{pre2:: (i<j) }		--there re at least two things to partition
	{cut:low high b pl ph:  
		((pl-1)<(ph+1))and
		(all sl:integer in low..(pl-1) are (b[sl] < b[pl])) and
		(all sh:integer in (ph+1)..high are (b[sh] > b[pl])) and
		(all sp:integer in pl..ph are (b[sp]=b[pl])) }
	{post2::  cut(i j b pl ph) and permutation(a b i j) }
	{partitioned:lowIndex highIndex p:
			(all t:integer in i..j are 
		  	((exists sl:integer  in i..(lowIndex-1) that 
		  		(a[t]=b[sl]) and (a[t] < p)) or 
		  	(exists sh:integer in (1+highIndex)..j that 
		  		(a[t]=b[sh]) and (p < a[t])) or 
		  	(exists sp:integer in lowIndex..highIndex that 
		  		(a[t]=b[sp]) and (a[t]=p)) )) }
--	{rule2:: partitioned(lowIndex highIndex p) implies permutation(a b i j)}
	{rule2:: permutation(a b i j) implies partitioned(lowIndex highIndex p) }
	is	  
	declare	
		variable lowIndex : shared integer := i		--start at bottom
		variable highIndex : shared integer := j	--start at top
			{ nolap:: (lowIndex-1 < highIndex+1) }	--no overlap of slices
		variable h : integer := (i+j)/2	--pick pivot from middle
		variable p : rt := a[h]	--value of pivot
			--pivotStore holds multiple records equal to pivot 
		variable pivotStore : spread array 1..(j-i) of rt 
		variable pivotIndex : shared integer := 1	--first pivot slot 1
	begin		--of partition
		{ (lowIndex>=i) and (highIndex<=j) and (pivotIndex>=1) and 
			pre2 and nolap }
		forall t:integer in i..j
			begin
				{ (lowIndex>=i) and (highIndex<=j) and (pivotIndex>=1) }
				if
					(a[t] < p) =>	--is this element smaller than pivot?
						{ (lowIndex>=i) }
						declare 
							variable sl:integer	--results from fetchadd (low)
						begin	--then put it in the lower half of b
							{ (a[t] < p) and (lowIndex>=i)}
							fetchadd(lowIndex 1 sl)
							{ (sl in i..(lowIndex-1)) and (a[t] < p) }
							;
							b[sl] := a[t]
							{ (sl in i..(lowIndex-1)) and (a[t]=b[sl]) and (a[t] < p) }
						end
						{ltp:: exists sl:integer in i..(lowIndex-1) that 
							(a[t]=b[sl]) and (a[t] < p) }
				[]
					(a[t] > p) =>	--is this element bigger than pivot?
						{ (highIndex<=j) }
						declare 
							variable sh:integer	--results from fetchadd (high)
						begin	--then put it in the upper half of b
							{ (p < a[t]) and (highIndex<=j)}
							fetchadd(highIndex -1 sh)
							{ (sh in (highIndex+1)..j) and (p < a[t]) }
							;
							b[sh] := a[t]
							{ (sh in (highIndex+1)..j) and (a[t]=b[sh]) and (p < a[t]) }
						end
						{gtp:: exists sh:integer in (highIndex+1)..j that 
							(a[t]=b[sh]) and (p < a[t]) }
				[]
					(a[t] = p) => 	--is this element equal to pivot?
						{ (pivotIndex>=1) }
						declare 
							variable sp:integer	--results from fetchadd (pivot)
						begin	--then save in pivotStore
							{ (a[t]=p) and (pivotIndex>=1) }
							fetchadd(pivotIndex 1 sp)
							{ (sp in 1..(pivotIndex-1)) and (a[t]=p) }
							;
							pivotStore[sp] := a[t]
							{ (sp in 1 ..(pivotIndex-1)) and (a[t]=p) and
								(pivotStore[sp] =a[t]) }
						end
						{eqp:: exists sp:integer in 1 ..(pivotIndex-1) that 
							(a[t]=p) and (a[t]=pivotStore[sp]) }
				fi
				{ ltp or gtp or eqp }
			end	--of forall t
		{ nolap and
		  (all t:integer in i..j are --for each of the records from i to j
		  	ltp or --it's less than pivot  copied to lower partition
		  	gtp or --it's greater than pivot  copied to upper partition
		  	eqp) --it's equal to pivot  copied to pivot store
		  and ((j-i)+1 = ((j-(highIndex+1))+1) + (((lowIndex-1)-i)+1) + (((pivotIndex-1)-1)+1)) }		  			  	  
		  {upper::(all sh:integer in highIndex+1 ..j are (p<b[sh]))} --everything in the upper partition is greater than pivot		   
		  {lower::(all sl:integer in i..(lowIndex-1) are (b[sl]<p)) }  --everything in lower partition is less than pivot		  	 
		  {middle::(all sp:integer in 1 ..pivotIndex-1 are (pivotStore[sp]=p)) } --everything in pivot store is equal to pivot
		  	--sum of elements in upper and lower partitions and 
		  	--pivot store equals the total number of elements
		;	--sequential composition
		begin
			{ (lowIndex-1<highIndex+1) }
			pl := lowIndex
			{ (lowIndex-1<highIndex+1) and (pl=lowIndex) }
			&
			{ (lowIndex-1<highIndex+1) }
			ph := highIndex
			{ (lowIndex-1<highIndex+1) and (ph=highIndex) }
			&
			{ (all t:integer in i..j are ltp or gtp or eqp) and
			   upper and middle and lower and
			  (lowIndex-1 = highIndex-(pivotIndex-1)) }
			 b[lowIndex..highIndex] := pivotStore[1 ..(pivotIndex-1)]
			{ 
			(all sp:integer in lowIndex..highIndex are (b[sp]=p) )  and
			  upper and lower and  
			   partitioned(lowIndex highIndex p) and rule2 } 
		end
	{ post2 and (p=b[pl])	}  --it's partitioned and b[pl] holds the pivot
	end	--of partition

	
procedure sort(low:constant integer high:constant integer 
		original:constant array low..high of rt 
		final:spread array low..high of rt)
	{pre:: (low<=high) }
	{post:: sorted(final low high) and permutation(original final low high) }  
	is
	declare  --variables for procedure sort
	variable inter : spread array low..high of rt	--intermediate array
	variable pl : integer	--pivot "low"  
	variable ph : integer	--pivot "high"
	{sscut:: sorted(final (ph+1) high) and permutation(inter final (ph+1) high)
		and sorted(final low (pl-1)) and permutation(inter final low (pl-1))
		and cut(low high inter pl ph) } 
	{rule1::  
		post implies
			(sscut and (all sp:integer in pl..ph are 
				(final[sp] = inter[sp]) and (inter[sp]=inter[pl])) ) }	
	begin		--of sort body
		{ pre }	  --assert precondition
		if
			(low=high) => 
				begin
					{ (low=high) }
--					{ rbound(low high) = 0 }
					final[low] := original[low]		--just one? then done
					{ post and (low=high) }
				end
				{ post }
		[]
			(low<high) =>
				begin		--partition then sort again
					{ (low<high) }
					partition(low high original inter pl ph)
					 { cut(low high inter pl ph) and (low<high) and 
					 		permutation(original inter low high)  }
					;
					if
						((pl=low) and (ph<high))=> 	--nothing in lower partition
							{ cut(low high inter pl ph) and (low<high) }
							begin
							{ cut(low high inter pl ph) and (pl=low) and 
									(low<high) and (ph<high)  }
--							{ (rbound(low high)>0) and 
--								(rbound((ph+1) high)<rbound(low high)) }
								--just sort upper half
							sort((ph+1) high inter[(ph+1)..high] final[(ph+1)..high])								
							{ sorted(final (ph+1) high) and 
								permutation(inter final (ph+1) high) and 
								cut(low high inter pl ph) and (pl=low) and (ph<high) }
							;skip
							{ sscut and (pl=low) and (ph<high) }
							end
							{ sscut }
					[]	
						((ph=high) and (low<pl))=>	--nothing in upper partition
							{ cut(low high inter pl ph) and (low<high) }
							begin
							{ cut(low high inter pl ph) and (ph=high) and 
								(low<high) and (low<pl) }
--							{ (rbound(low high)>0) and 
--								(rbound(low (pl-1))<rbound(low high)) }
								--just sort lower half
							sort(low (pl-1) inter[low..pl-1] final[low..pl-1])	
							{ sorted(final low (pl-1)) and 
								permutation(inter final low (pl-1)) and 
								cut(low high inter pl ph) and (ph=high) and (low<pl) }
							;skip
							{ sscut and (ph=high) and (low<pl) }
							end
							{ sscut } 
					[]	
						((ph<high) and (pl>low))=>
							{ cut(low high inter pl ph) and (low<high) }
							begin
								{ (pl>low) and cut(low high inter pl ph)}
--								{ (rbound(low high)>0) and 
--									(rbound(low (pl-1))<rbound(low high)) }
									--sort lower half
								sort(low (pl-1) inter[low..pl-1] final[low..pl-1])	
								{ sorted(final low (pl-1)) and 
									permutation(inter final low (pl-1)) and 
									cut(low high inter pl ph) } 
								& 
								{ (ph<high) and cut(low high inter pl ph)}
--								{ (rbound(low high)>0) and 
--									(rbound((ph+1) high)<rbound(low high)) }
									--sort upper half		
								sort((ph+1) high inter[(ph+1)..high] final[(ph+1)..high])							
								{ sorted(final (ph+1) high) and 
									permutation(inter final (ph+1) high) and 
									cut(low high inter pl ph) } 
							end
							{ sscut } 
					fi
					{ sscut } 
					;
					{ all sp:integer in pl..ph are (inter[sp]=inter[pl]) }
					forall sp:integer in pl..ph
						begin
							{ (inter[sp]=inter[pl]) }
							final[sp] := inter[sp]
							{ (final[sp] = inter[sp]) and (inter[sp]=inter[pl]) }
						end
					{ sscut and 
						(all sp:integer in pl..ph are 
							(final[sp] = inter[sp]) and (inter[sp]=inter[pl]))
						 and rule1 } 
				end	--of partition then sort again
				{ post }
		fi		--done with low<high
		{ post } 
	end 		--of sort
	
end body	--partitionSort:Sort
