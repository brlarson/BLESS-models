-- Programm Name: 
--
--				ÒKmeans.dÓ
--
-- Programmer:	
--
--				Jeffrey Wolff
--
-- Purpose:		
--
--				To provide a K-Means Clustering algorithm
--				for high performance data mining
--
-- Version:		
--
--				0.01 01/30/00 JW
--				0.10 02/06/00 JW
--				0.15 02/09/00 JW
--				0.30 02/12/00 JW
--				0.40 02/26/00 JW
--				1.00 03/4/00 JW
--				1.01 03/5/00 JW
--				2.00 04/04/00 brl
--				2.01 12/15/2006 brl
--
-- Copyright:
--
--				(C) 2000, Multitude, Inc.

   

face Kmeans[n tV k add dist scale] is	

	required 
		constant n :  integer			-- number of data points
		type tV										-- type of the vector to be clustered
		constant k :  integer			-- number of clusters
		function add(fst:tV, snd:tV) return a:tV		--vector addition
			{all a,b:tV in true are add(a,b)=add(b,a)}
		function dist (element1:tV, element2:tV) return d:integer -- distance from a to b
			{all a,b,c:tV in true are dist(a,b)+dist(b,c) >= dist(a,c)}	--triangle inequality
		function scale(v:tV,sf:floating) return s:tV	--scale v by sf
			{all b:tV in true are  (scale((b+b),0.5)=b) }
			{all a,b:tV in true are exists s:floating in true that 
				((scale(a,s)=b) iff (scale(b,(1.0/s))=a))}		
	end required

	type V is array 1..n of tV						-- array of type tV to work on
	type k_part is array 1..n of range 1..k		-- k-way partition vector
	type k_cent is array 1..k of tV				-- a centroid for each partition
		
	function centroid(R:array 1..n of range 1..k, h:integer,	
				data:array 1..n of tV) return c:tV
		--the centroid of subset h is the sum of all vectors in that subset
		--divided by the number of elements in the set
		{centroid:R s d:	--define the centroid of subset h using partition vector R
--			((sum i:integer in 1..n and R[i]=h of data[i]) = s) and	--s is sum of all element in subset h
			((numberof i:integer in 1..n that are R[i]) = 1/d) and 	--d is reciprocol of cardinality of h
			(scale(s,d)=centroid) }

	function totalDist(data:array 1..n  of tV,  P:array 1..n of range 1..k) 
			return td:floating
		{totalDist::	sum j:integer in 1..n : dist(data[j],(centroid(P,j,data))) equals totalDist }
		--the total distance of a partition array M is the distance between
		--each element of V and the centorid of the partition the element is in

	
	procedure clusterize(data:array 1..n  of tV,  P:array 1..n  of range 1..k)
		{post:result: all Q:array 1..n  of range 1..k in Q<>P are 
				totalDist(data,Q) >= totalDist(data,P)}
		--the postcondition states that any partition array of V has
		--a greater total distance than the result P

end face

------------------------------	body kmeans ------------------------------ 
body kmeans:Kmeans[n tV k add dist scale] is

	required 
		variable n : constant integer			-- number of data points
		type tV										-- type of the vector to be clustered
		variable k : constant integer			-- number of clusters
		function add(fst:tV, snd:tV) return a:tV		--vector addition
			{all a,b:tV in true are add(a,b)=add(b,a)}
		function dist (element1:tV, element2:tV) return d:integer -- distance from a to b
			{all a,b,c:tV in true are dist(a,b)+dist(b,c) >= dist(a,c)}	--triangle inequality
		function scale(v:tV,sf:floating) return s:tV	--scale v by sf
			{all b:tV in true are  (scale((b+b),(1/2))=b) }
			{all a,b:tV in true are exists s:floating in true that 
				((scale(a,s)=b) iff (scale(b,(1/s))=a))}		
	end required

	import toFloating from builtInInteger:Arithmetic
	
	type V is array 1..n of tV						-- array of type tV to work on
	type k_part is array 1..n of range 1..k		-- k-way partition vector
	type k_cent is array 1..k of tV				-- a centroid for each partition
	
	function addUpVector(l:integer, h:integer, v:array 1..n of tV) return t:tV
		{l <= h}		--low index is at most high index
		is
		declare
			variable m:integer := (l+h)/2;		--midpoint between l (low) and h (high)
	--		variable t:tV	--total
		begin
			if
				(l=h) => t := v[l]		--only one element
			[]
				((l+1)=h) => t := add(v[l],v[h])		--two elements add them 
			[]	--otherwise add the result of recursive call
				((l+1)<h) => t := add((addUpVector(l,m,v)),(addUpVector((m+1),h,v)))	
			fi
	--		;
	--		return t
		end	--of addUpVector
		
	function centroid(R:array[1..n] of range 1..k, h:integer,	
				data:array[1..n] of tV) return tV 
		--the centroid of subset h is the sum of all vectors in that subset
		--divided by the number of elements in the set
		{centroid:R s d:	--define the centroid of subset h using partition vector R
			(sum i:integer in 1..n and R[i]=h : data[i] equals s) and	--s is sum of all element in subset h
			(numberof i:integer in 1..n:(R[i]=h) equals 1/d) and 	--d is reciprocol of cardinality of h
			(scale(s,d)=centroid) }
		is
		declare
			variable c:tV	--centroid vector of partition h is result before scaling
			variable count:shared integer := 0;	--used to count elements in partition h
			variable H:protected array[1..n] of tV	--separate out subset h
		begin		--there may be only a few subsets, each with many elements so 
					--adding vectors in parallel is worth the effort
			forall t:integer in 1..n 	--count the number of dataums in subset h
				declare variable p:integer 
				begin 
					if
					(R[t]=h) => 	--match?
						begin	--get unique index and store datum
							fetchadd(count,1,p) ;  H[p]:=data[t]
						end
					[]
					(R[t]<>h) => skip
					fi
				end
			{ numberof i:integer in 1..n: R[i]=h equals count }	--count holds cardinality of subset h
			;
			c := addUpVector(1,count,H)
			;
			return scale(c,(1.0/toFloating(count)))
		end	--of centroid

	function totalDist(data:array[1..n] of tV,  P:array[1..n] of range 1..k) return floating 
		{totalDist::	sum j:integer in 1..n : dist(data[j],(centroid(P,j,data))) equals totalDist }
		--the total distance of a partition array M is the distance between
		--each element of V and the centorid of the partition the element is in
		is	--a function only used within assertions, never actually calculate total distance
		declare
			variable td:floating:=0;		--total distance is result returned
		begin		
			return td
		end	--of totalDist
	
	procedure clusterize(data:array[1..n] of tV,  P:array[1..n] of range 1..k)
		{post:: all Q:array[1..n] of range 1..k in Q<>P are 
				totalDist(data,Q) >= totalDist(data,P)}
		--the postcondition states that any partition array of V has
		--a greater total distance than the result P
		is
		declare
			variable oldP:array[1..n] of range 1..k
			variable oldAndNewAreDifferent: shared boolean == true;
		begin
			--arbitrarily and evenly choose starting partition
			forall i:integer in 1..n begin P[i] := (i mod k)+1 end
			{ all j:integer in 1..n are P[j] in 1..k }	--P is a proper partition vector
			{ exists Q:array[1..n] of range 1..k in Q<>P that 
				totalDist(data,Q) < totalDist(data,P)}	--there's a better partition out there
			;
			do
			{ inv::  oldAndNewAreDifferent iff 
				(exists Q:array[1..n] of range 1..k in Q<>P that 
				totalDist(data,Q) < totalDist(data,P) ) } --loop invariant
			{ bd:BEST: totalDist(data,P) - totalDist(data,BEST) = bd}	--bound function
			(oldAndNewAreDifferent) =>
				declare
					variable cent:array[1..k] of tV		-- k centroids, one for each partition
				begin
					oldP := P		--save old partition
					&	--calculate new centroids at the same time
					forall i:integer in 1..k begin cent[i] := centroid(P,i,data) end
					&
					oldAndNewAreDifferent == false 	--reset flag, set if difference found
					{ all f:integer in 1..k are cent[f] = centroid(P,f,data) }
					;	--then repartiton with new centroids
					forall i:integer in 1..n		--find closest centroid for each datum
						declare
							variable sd:floating := dist(data[i],cent[1]);	--shortest distance
							variable closest:integer := 1;		--closest centroid so far
							variable c:integer := 1;		--loop index
						begin
						do
						{inv2:: all d:integer in 1..c and d<>closest are 
								dist(data[i],cent[P[d]]) >= dist(data[i],cent[closest]) }
						{bd2::  k+1-c = bd2 }		--done when c>k or bd2=0
						(c<=k) =>
							begin
								if
								(dist(data[i],cent[P[c]]) <  dist(data[i],cent[closest])) =>	--c is closer
									begin
										closest := c
										&
										sd := dist(data[i],cent[P[c]])
									end
								[]
								(dist(data[i],cent[P[c]]) >= dist(data[i],cent[closest])) => skip
								fi
								;
								c := c+1
							end
						od
						;
						P[i] := closest
						{ all f:integer in 1..k and f<>closest are
							dist(data[i],cent[P[f]]) >= dist(data[i],cent[P[closest]]) }
						;
						if
							(P[i]=oldP[i]) => skip
						[]
							(P[i]<>oldP[i]) => 
								declare variable dummy:boolean	--return value from fetchor, unused
								begin 
									fetchor(oldAndNewAreDifferent,true,dummy) 
									{ (P[i]<>oldP[i]) implies oldAndNewAreDifferent }
								end
						fi		
						end	--of finding closest centroid for each datum
					{ all j:integer in 1..n are 
						all f:integer in 1..k and f<>P[j] are 
							dist(data[j],cent[f]) >= dist(data[j],cent[P[j]]) }
					{ oldAndNewAreDifferent iff (exists g:integer in 1..n that P[g]<>oldP[g]) }
				end
			od
		{ not oldAndNewAreDifferent and inv }
		{post}
		end	--of clusterize
		
		
end body --kmeans:Kmeans		

