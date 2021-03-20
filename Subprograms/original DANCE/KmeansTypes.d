--KmeansTypes.d 
--this package contains all data types needed for Kmeans

face KmeansTypes [n]
is
	required 
		constant n : integer
	end required
	
	type tV is private -- tV is the custom type supplied by the implementing body

	type centroidsType is
		record
			loc: tV 						-- centroid location 
			indexV: array 1..n of integer	-- index of V of elements in cluster
			numElements: integer	-- number of elements belonging to cluster
		end record -- end complex

end face 	--of KmeansTypes.d 

--------------------------------------------------------------
