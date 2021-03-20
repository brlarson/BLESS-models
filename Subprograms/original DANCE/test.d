	--test.d
	--DANCE compiler test program

face test[limit] is		--a package declaration defines a type

	--required parameters of polymorphic package
	required variable limit : integer end required
		
	procedure findPrimes()	--procedure declaration
		
end face

-------------------------------------------------------------------
body sieve:test[limit] is	--body "sieve" of type "test"

 	required variable limit : integer end required
	import println from system:System 
			
	procedure findPrimes() is	--sieve of Erastosthenes
		declare		--temporal existential quantification
			variable hole : array[2..limit,2..limit] of boolean == false;
		begin
		{pre:: all i,j:integer in 2..limit are not hole[i,j]}	--no holes
		forall drillOffset:integer in 1..limit
			declare
				variable drillLocation:integer := drillOffset;
			begin	--drill holes
				{all j:integer in 2..limit are not hole[drillOffset,j]}
				do
					(drillLocation <= limit) =>
						begin	--drill a hole
							hole[drillOffset,drillLocation] == true
							;
							drillLocation := drillLocation + drillOffset
						end		--drilling a hole
				od
				{ (drillLocation > limit) and 
					( all j:integer in 2..limit are hole[drillOffset,j] iff
						(exists k:integer in 1..limit that k*drillOffset = j ) ) }
			end		--of drilling holes
		;
		forall ball:integer in 1..limit
			declare
				variable ballLocation:integer := 2;	
			begin	--roll balls
				do
					( (ballLocation<=limit) cand (not hole[ballLocation,ball]) )
						=> ballLocation := ballLocation + 1
				od
				{ (ballLocation > limit) or hole[ballLocation,ball] }
				{ (ballLocation > limit) implies (all h:integer in 2..limit are not hole[h,ball]) }
				{ (ballLocation > limit) implies (all j:integer in 2..limit are
					not exists k:integer in 1..limit that (k*ball) = j ) }
				;
				if
					(ballLocation > limit) => println(ball,` is prime')
				[]
					(ballLocation <= limit) => println(ball,` is divisible by',ballLocation)				
				fi
			end		--of rolling balls
		end		--of findPrimes

end body  --sieve
