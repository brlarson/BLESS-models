--Graph.d


--Determine for each node (vertex) in a graph, its "component number."  
--A component number is the lowest numbered vertex the node is connected to.  
--In this way all nodes that are connected have the same component number, 
--and just as importantly all nodes not reachable have different component numbers.

face Graph is
	function components(last : integer, A : array 0..last,0..last of boolean)
		return V:array 0..last of integer
	procedure connectivity(last : integer, B : spread array 0..last,0..last of boolean, 
		C : spread array 0..last,0..last of boolean)
end face	--of Graph

-------------------------------------------------------------

body graph:Graph is

import log2 from builtInInteger:Arithmetic 

function components(last : integer, A : array 0..last,0..last  of boolean)
	return V:array 0..last  of integer is
		--A holds the adjancy matrix of the graph 
		--that is A[x,y] is true
		--iff node x is directly connected to node y
		--the vector returned contains the component numbers: the
		--lowest numbered node that can be reached in the graph
declare
	variable B : array 0..last,0..last of boolean==false
	variable t : array 0..last of integer:=nil
	variable i : integer:=0
begin
		--A[x,y] is true if node x is directly connected to node y
	{defn:Connect: all x,y:integer in 0..last are A[x,y] implies Connect|x,y| }
	connectivity(A,B,last)	--forward reference to "connectivity"
		--B[x,y] is true if there is a path from node x to node y
	{path:Path:all x,y:integer in 0..last are B[x,y] implies Path|x,y| }
	;
	forall i:integer in 0..last 
		declare
			variable j : integer := 0
		begin
		--find the lowest numbered node we're connected to
			{inv:: all k:integer in 0..j are not B[i,j] }
			do
				not(B[i,j] or (i=j)) => j := j+1
			od
			{inv and (B[i,j] or (i=j) ) }
			;
			t[i] := j
			{(t[i]=j) and (B[i,j] or (i=j)) and inv}
		end
--parenthesis problem in folloing line after "are"
	{post::  all v:integer in 0..last are (all k:integer in 0 ..(t[v]) are 
		not(Path|v,k|) ) or (t[v] = v) }
	--this is yet another adaptation of Dijkstra's linear search
	;
	V:=t
end  --of components

procedure connectivity(last : integer, B : spread array 0..last,0..last of boolean, 
				C : spread array 0..last,0..last of boolean)
is
	--given an adjacency matrix B, compute reachability matrix C
	--that means C[x,y] is true iff the is some set of nodes n1, n2,...nk
	--so that B[x,n1], B[n1,n2], ... B[nk,y] are all true
declare
	variable D : spread array 0..last,0..last of boolean==false
	variable i : integer := 1
	variable limit : integer:= log2((last+1))	--how many iterations?
	--the second "integer" is an invocation of type conversion

begin
	{all x,y:integer in 0..last are B[x,y] implies Connect|x,y| }
	{all x,y:integer in 0..last are Connect|x,y| implies Path|x,y| }
	C := B	--copy input
	{all x,y:integer in 0..last are C[x,y] implies Path|x,y| }
--	{MaxPathLength::true}		--introduce MaxPathLength
--problem with MaxPathLength, need way to introduce assertion-only functions
--	{all x,y:integer in 0..last are C[x,y] implies (MaxPathLength(x,y) = 1) }
--	{(V implies MaxPathLength = u) implies (V*V implies MaxPathLength = 2*u)}
       --see Akl page 254 for justification
	;
	{inv:: C implies (MaxPathLength = 2**(i-1)) }
	{bound:: limit - i >= 0 }
	do
		(i < limit) =>
			begin
				C := C*C --binary matrix multiplication
				;
				i := i+1
			end
	od
	{C implies (MaxPathLength = last) }
	{all x,y:integer in 0..last are C[x,y] implies Path|x,y| }
	;
	return C
end --of connectivity

end body		--of graph
