-- the vector class
local vector = {
	["size"] = 0, --the size of the vector
	["elements"] = {} -- the vector's elements
}


function vector:new(T) --default constructor
	T = {["size"] = #T, ["elements"] = T} or {["size"] = 0, ["elements"] = {}}
	setmetatable(T, self)
	self.__index = self
	return T
end

function vector:push_back(elem) --push elements onto the vector
	table.insert(self.elements, elem)
	self.size = self.size + 1
	return self --returns the vector
end 

function vector:erase_at(p)
	table.remove(self.elements, p)
	self.size = self.size - 1
	return self
end
function vector:erase_if(predicate)
	for i, _ in pairs(self.elements) do
		if predicate(self.elements[i]) then
			self:erase_at(i)
			self.size = self.size - 1
		end
	end
	return self
end

function vector:get_container() return self.elements end

function vector:get_size() return self.elements end

function vector:join(other)
	for _, v in pairs(other.elements) do
		self:push_back(v)	
		self.size = self.size + 1
	end
	return self
end

function vector:join_if(predicate, other)
	for _, v in pairs(other.elements) do
		if (predicate(v)) then
			self:push_back(v)
			self.size = self.size + 1
		end
	end
end

function vector:foreach(f)
	for _, v in ipairs(self.elements) do
		f(v)
	end
end

function vector:is_empty()
	return (self.size == 0)
end

function vector:map(f)  
	local mapvector = vector:new({})
	for _, v in pairs(self.elements) do
		mapvector:push_back(f(v))
	end
	return mapvector
end

function vector:fold(f)
	local result = self.elements[1]
	if #self.elements == 0 then
		return nil
	end
	local selfvec = self.elements
	table.remove(selfvec, 1)
	for _, v in pairs(selfvec) do
		result = f(result, v)
	end
	return result
end


function vector:filter(predicate)
	local reV = vector:new({})
	for _, v in pairs(self.elements) do
		if predicate(v) then
			reV:push_back(v)
		end
	end
	return reV
end

--used to linearize a vector with multiple levels of nesting
--oh and don't fill the parameter when calling the function!
function vector:linearize(r)
	local result = r or vector:new({})
	for i, v in ipairs(self.elements) do
		if type(v) == "table" then
			v:linearize(result)
		else 
			result:push_back(v)
		end
	end
	return result
end

--f is optional.
function vector:zip(f)
	local f = f or function(p1, p2) return {p1, p2} end
	local selfcopy = self
	local retvec = vector:new({})
	while #(selfcopy.elements[1].elements) ~= 0 do
		local v = f(
		selfcopy.elements[1].elements[1],
		selfcopy.elements[2].elements[1])
		retvec:push_back(v)
		selfcopy.elements[1]:erase_at(1)
		selfcopy.elements[2]:erase_at(1)
	end
	return retvec
end
-- f is optional
function vector:zipn(f)
	local f = f or nil
	local selfcopy = self
	local retuples = vector:new({})
	local n = #selfcopy.elements[1]
	-- we check if the tuples all have the same length first
	assert(
		(function() 
			for _, v in ipairs(selfcopy.elements) do
				if #v ~= n then return false end
			end
			return true
		end)(), "zipn: tuples have different lengths!")
	local i = 1
	while i <= n do
		local tuple = {}
		for e = 1, #self.elements, 1 do
			table.insert(tuple, e, selfcopy.elements[e][i])
		end
		if f == nil then
			retuples:push_back({table.unpack(tuple)})
		else 
			retuples:push_back({f(table.unpack(tuple))})
		end
		i = i + 1;
	end
	return retuples
end

-- ONLY FOR VECTORS OF ELEMENTS THAT ARE OF SIMPLE TYPES
--for vectors of tuples (for instance, obtained by the vector:zip() method)
--use the vector:print_tuples() function instead.
function vector:print() --pretty-print the values
	self:foreach(function(e) io.write(e, " ") end)
	io.write("\n")
	return self
end

function vector:print_tuples()
	-- self is a vector of tuples
	-- i.e. self is in the form:
	-- vector:new({{a, b}, {c, d}, ...})
	-- self.elements returns the tuples.
	for i, v in ipairs(self.elements) do
		io.write("(")
		for e, w in ipairs(self.elements[i]) do
			io.write(w)
			if e < #self.elements[i] then
				io.write(", ")
			end
		end
		io.write(") ")
	end
	io.write("\n")
	return self
end





-- --examples of map, filter and apply with vectors
-- apply_v = vector:new({1, 2, 3})
-- print(apply_v:apply(function(n, m) return n+m end))
-- map_v = vector:new({1, 2, 3, 4})
-- mapped_v = map_v:map(function(e) return e * e end)
-- mapped_v:print()
--you can also pass in vector:new in a functional (kinda) way and print
--it directly with 0 assignments. showing this to a C programmer is guaranteed
--to give them a heart attack! Also note, this is a complete filter-map-print example.

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