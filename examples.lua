-- --examples of map, filter and apply with vectors
--you can pass in vector:new in a functional (kinda) way and print
--it directly with 0 assignments. showing this to a C programmer is guaranteed
--to give them a heart attack! Also note, this is a complete filter-map-print example.

-- first, require the vector module
local vector = require("vector")

vector:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 10})
	:filter(
		function(n) return ((n%2) == 0) end)
	:map(
		function(m) return m*m end)
	:print()

--we can add fold if we do it like this:
print(
	vector:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15})
		:filter(
			function(n) return ((n%2) == 0) end)
		:map(
			function(m) return m*m end)
		:fold(
			function(p, q) return p+q end))
--beautiful.

-- don't panic if there are vectors of vectors with  
--multiple nesting levels! we have 
-- linearize() here to help us:

vector:new({
	vector:new({
		vector:new({
			1, 2, 3, vector:new({4})
		}), 5, 6, 7
	}), 
8, 9, 10}):linearize():print()

-- how to find the maximum element of a vector using
--what we've built up until now?

print(vector:new(
	{1, 2, vector:new({3, 4, 5}), 6, 7, vector:new({8, 9})})
		:linearize() -- to make it flat
		:fold(function(n1, n2)
		  	if n1 > n2 then return n1 else return n2 end end)) 

vector:new({
	vector:new({1, 2, 3, 4}),
	vector:new({5, 6, 7, 8})
}):zip(function(p1, p2)
 	return {p1*p1, p2*p2} end)
  :print_tuples()


print("zipn: with function")
vector:new({
	  {1, 2, 3},
	  {4, 5, 6},
	  {7, 8, 9}
}):zipn(function(p1, p2, p3)
	return p1+p2+p3 end)
  :print_tuples()


print("zipn: without function")
vector:new({
	{1, 2, 3},
	{4, 5, 6},
	{7, 8, 9}
}):zipn():print_tuples()
