local vector = require("vector")

print("printing the squares of all the even numbers between 1 and 10:")
vector:new({1, 2, 3, 4, 5, 6, 7, 8, 9, 10})
	:filter(
		function(n) return ((n%2) == 0) end)
	:map(
		function(m) return m*m end)
	:print()

--we can add fold if we do it like this:
print("printing the result of the sum of the squares of the even numbers between 1 and 15:")
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
print("linearizing a nested vector:")
vector:new({
	vector:new({
		vector:new({
			1, 2, 3, vector:new({4})
		}), 5, 6, 7
	}), 
8, 9, 10}):linearize():print()

-- how to find the maximum element of a vector using
--what we've built up until now?

print("finding the max element of an array using fold:")
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
