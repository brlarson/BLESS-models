--SignalProcessing.d

face SignalProcessing[arithmetic]
is
	required 
		body arithmetic:Arithmetic 
	end required

	procedure fft( last : integer, A : array[0..last] of arithmetic.baseType,
			 B : array[0..last] of arithmetic.baseType ) 

end face --of SignalProcessing

----------------------------------------------------------------

body standard:SignalProcessing[arithmetic]
is

required 
	body arithmetic:Arithmetic 
end required

function rev(x : integer, s : integer) return integer
is		--reverse the bits of a number x that is s bits long
declare
  variable j : integer := s;
  variable k : integer := 0;
begin
  do
    (j > 0) =>
	begin
	  if
	    (x / 2**(j-1) > 0) => k := k + 2**(s-j)
	  []
	    not(x / 2**(j-1) > 0) => skip
	  fi
	  ;
	  x := x mod 2**(j-1)
	  &
	  j := j-1
	end
  od
  ;
  return k
end --of rev (it reverses bits)

procedure fft( last : integer, A : array[0..last] of arithmetic.baseType,
			 B : array[0..last] of arithmetic.baseType, size:integer ) 
is
declare
  variable C D : array[0..last] of arithmetic.baseType:=arithmetic.zero;	
  			--an arithmetic.vector is a vector of complex numbers
			--supplied by a package with complex data 
			--structures and operations as yet uncoded
  variable h p q  : integer:=0;
  variable z w : arithmetic.baseType:=arithmetic.zero;
  variable n : integer:= last+1;		--n is the number of elements in the sample
  function twiddle(n:integer) return arithmetic.baseType is begin skip end
begin
  h := size-1	--h is the loop variable counting the number of 
			--butterfly stages
  &
  w := twiddle(n)		
  			--twiddle=e**(2*pi*i/n)
			--w is this goofy constant, complex number
			--used in the FFT formula
			--the "i" is the square root of -1 as a defined constant 
			--the complex arithmetic package
  ;
  C := A		--assign whole vector to C
  ;
  do
    (h>=0) =>
	begin
	  p := 2**h	--difference of indexes that are butterflied 
	  &
	  q := 2**(size-h)
	  &
	  z := w**(arithmetic.fromInteger(p))
	  ;
	  D := C	--make copy of current vector
	  ;
	  forall k:integer in 0..last 
	  	begin
		    if
			((k mod p) = (k mod (2*p))) =>
				begin
				C[k] := D[k] + D[(k+p)]*(z**arithmetic.fromInteger((rev(k,size) mod q)))
				&
				 C[(k+p)] := D[k] - D[(k+p)]*(z**arithmetic.fromInteger((rev(k,size) mod q)))
				end
		    []
			not((k mod p) = (k mod 2*p)) => skip
		    fi
		 end
	  ;
	  h := h-1
	end
  od
  ;
  forall k:integer in 0..last 
  	begin
    B[k] := C[(rev(k))]
    end 	--of last forall
end --of fft

end body	--of standard
