--MatrixOperations.d

face MatrixOperations is

--integer matrix transpose 
	function T(n:integer, B:spread array 1..n,1..n of integer) 
		return C: spread array 1..n,1..n of integer
		{postTi:: all x,y:integer in 1..(n+1) are C[x,y] = B[y,x] }

--floating matrix transpose
	function T(n:integer, B:spread array 1..n,1..n of floating) 
		return C: spread array 1..n,1..n of floating
		{postTf:: all x,y:integer in 1..n are C[x,y] = B[y,x] }

--integer matrix multiply A*B = C
	function `*'( n:integer, 
			A: spread array 1..n,1..n of integer,
			B: spread array 1..n,1..n of integer ) 
		return C: spread array 1..n,1..n of integer 
		{postMi:: all x,y:integer in 1..n are
			(C[x,y] = (sum z:integer in 1..n of A[x,z]*B[z,y])) }

--floating matrix multiply A*B = C
	function `*'( n:integer, 
			A: spread array 1..n,1..n of floating,
			B: spread array 1..n,1..n of floating) 
		return C: spread array 1..n,1..n of floating
		{preMf:: 1<n }
		{postMf:: all x,y:integer in 1..n are
			(C[x,y] = (sum z:integer in 1..n of A[x,z]*B[z,y])) }

--floating identity matrix
function I(n:integer) return i:spread array 1..n,1..n of floating
	{ID:i: all x,y:integer in 1..n are (
		((x=y) and (i[x,y]=1.0)) or
		((x<>y) and (i[x,y]=0.0)) ) }
	{postID:: ID|i|}

end face	--of MatrixOperations

----------------------------------------------------------------

body mo: MatrixOperations is

--integer matrix transpose 
function T(n:integer,B:spread array 1..n,1..n of integer) 
	return C:spread array 1..n,1..n of integer
	{postTi:: all x,y:integer in 1..(n+1) are C[x,y] = B[y,x] }
is
begin
	{ true }
	forall x,y: integer in 1..(n+1)
		begin
			{ true }
			C[x,y]:= B[y,x]
			{ C[x,y] = B[y,x] }
		end				
	{ postTi }
end	--of integer matrix Transpose

--floating matrix transpose
function T(n:integer, B:spread array 1..n,1..n of floating) 
	return C: spread array 1..n,1..n of floating
	{postTf:: all x,y:integer in 1..n are C[x,y] = B[y,x] }
is
begin
	{ true }
	forall x,y: integer in 1..n
		begin
			{ true }
			C[x,y]:= B[y,x]
			{ C[x,y] = B[y,x] }
		end				
	{ postTf }
end	--of integer matrix Transpose

--integer matrix multiply A*B = C
function `*'( n:integer, 
		A: spread array 1..n,1..n of integer,
		B: spread array 1..n,1..n of integer ) 
	return C: spread array 1..n,1..n of integer 
	{postMi:: all x,y:integer in 1..n are
		C[x,y] = (sum z:integer in 1..n of A[x,z]*B[z,y]) }
is
begin
	{ true }
	forall x,y:integer in 1..n 
		declare variable dotProductResult : shared integer := 0
		begin
			{ true }
			forall z:integer in 1..n
				declare variable dummy:integer
				begin
					{ true }
					fetchadd(dotProductResult, A[x,z]*B[z,y],dummy)
					{ dotProductResult += A[x,z]*B[z,y] }
				end	--of forall z
			{all z:integer in 1..n are
         		exists dummy:integer that 
         			dotProductResult+=(A[x,z]*B[z,y]) }			
         	;
			C[x,y] := dotProductResult
			{ (C[x,y] = dotProductResult) and (dotProductResult = 
				(sum z:integer in 1..n of A[x,z]*B[z,y]) ) }
		end	--of forall x,y
	{ all x,y:integer in 1..n are exists dotProductResult:integer that
		(C[x,y] = dotProductResult and
		dotProductResult = (sum z:integer in 1..n of A[x,z]*B[z,y]) )}
	;
	skip	--doesn't "do" anything, but the above form is needed for wp
	{ postMi }
end	--of IntegerMatrixMultiply


--floating matrix multiply A*B = C
function `*'( n:integer, 
		A: spread array 1..n,1..n of floating,
		B: spread array 1..n,1..n of floating) 
	return C: spread array 1..n,1..n of floating
	{preMf:: 1<n }
	{postMf:: all x,y:integer in 1..n are
		C[x,y] = (sum z:integer in 1..n of A[x,z]*B[z,y]) }
is
begin
	{ preMf and (0<n) }
	forall x,y:integer in 1..n 
		declare 
			variable dotProductResult:floating := 0.0
			variable k:integer :=0
			{inv:: dotProductResult =  (sum z:integer in 1..k of 
					A[x,z]*B[z,y])}			
			{ruleT::  inv implies (dotProductResult = (sum z:integer in 1..(k-1) of A[x,z]*B[z,y]) 
				+ (A[x,k]*B[k,y]))  }
		begin
			{b1:F: inv and (k=0) and (0<n-k) and (1<n) }
			do
			(0<n-k) =>	
				begin
					{ inv and (n-k=F)}
					k := k+1
					{ (n-k<F) and (dotProductResult =  
						(sum z:integer in 1..(k-1) of A[x,z]*B[z,y])) }		
					;	
					dotProductResult := dotProductResult + (A[x,k]*B[k,y])
					{ (n-k<F) and ruleT and 
						((dotProductResult - (A[x,k]*B[k,y])) = 
							(sum z:integer in 1..(k-1) of A[x,z]*B[z,y])) }
				end	--of loop body
			od
			{ inv and (n-k=0) and (not (0<n-k)) }			
         	;
			C[x,y] := dotProductResult
			{ (C[x,y] = (sum z:integer in 1..n of A[x,z]*B[z,y]) ) }
		end	--of forall x,y
	{all x,y:integer in 1..n are
         exists dotProductResult:floating that
           exists k:integer that (sum z:integer in 1..n of (A[x,z]*B[z,y]))=C[x,y]}	
    ;skip	--does nothing but allows assertion above to be transformed into postMf
    { postMf }
end	--of floating matrix multiply A*B = C

--make floating identity matrix
function I(n:integer) return i:spread array 1..n,1..n of floating
	{ID:i: all x,y:integer in 1..n are (
		((x=y) and (i[x,y]=1.0)) or
		((x<>y) and (i[x,y]=0.0)) ) }
	{postID:: ID|i|}
is
begin
	{ true }
	forall x,y:integer in 1..n
		begin
			{ true }
			if
			(x=y) => i[x,y] := 1.0		--on diagonal =1
				{d::((x=y) and (i[x,y]=1.0)) or ((x<>y) and (i[x,y]=0.0)) }
			[]
			(x<>y) => i[x,y] := 0.0		--elsewhere = 0
				{ d }
			fi
			{ d }
		end
	{postID}
end	--of make floating identity matrix


	
end body 	--body mo: Matrix Operations 
