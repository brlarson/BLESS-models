  --System.d
  --mock System package
  
 face System is
  	
	procedure println( i:integer, s:string)

	procedure println( i:integer, s:string, j:integer)
	
	type complex is private		--private type
	constant ivectorLast:integer:=9999
	type ivector is array 0..ivectorLast of complex
	function length(s:string) return r:integer
	function toString(ch:character) return r:string
	--the functions "now" are to be used abstractly in assertions,
	--not actually be invoked by programs
	function now() return r:integer	--the current time in integer format
	function now() return r:floating	--the current time as a real number

  	{ new:x: x and not x^1 }	--define "new" operator
	
 end face
  
body system:System is

	type complex is 
		record
			re:floating
			im:floating		
		end record	--end of complex
	constant ivectorLast:integer:=9999
	type ivector is array 0..ivectorLast of complex
  
	procedure println( i:integer, s:string) is
		begin	--dummy to fake System.out.println()
			skip
		end

	procedure println( i:integer, s:string, j:integer) is
		begin	--dummy to fake System.out.println()
			skip
		end

	function length(s:string) return r:integer is
		begin	--dummy string length function
			skip
		end
		
	function toString(ch:character) return r:string is
		begin		--dummy conversion of carachter to a string
			skip
		end

	function now() return r:integer is
		begin		--dummy body of "now" integer
			skip
		end

	function now() return r:floating is
		begin		--dummy body of "now" floating
			skip
		end
			
end body
þ