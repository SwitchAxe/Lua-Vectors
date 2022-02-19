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


local struct = {
    ["old_state"] = false,
    ["new_state"] = false
}
function struct:new(s)
    local s = s or {["old_state"] = false, ["new_state"] = false}
    setmetatable(s, struct)
    self.__index = self
    return s
end
print("\x1b[2J") --clears the terminal
-- we can do the game of life with vectors! (and structs, we need structs :/)
-- plane is the grid in which the game will be running
-- we can make it arbitrarily big, but as an example a 5x5 will do
-- this particular initial configuration is quite convenient.
-- its common name is "block" and it's a still life, that is: it does
-- absolutely nothing and stays there forever or until ^C is pressed.
local plane = vector:new({
    false, false, false, false,false,
    false, true, true, false,false,
    false, true, true, false,false,
    false, false, false, false,false,
    false, false, false, false,false,
}):map(function(elem)
    if elem == false then
        return struct:new({["old_state"] = false, ["new_state"] = false})
    end
    return struct:new({["old_state"] = true, ["new_state"] = false})
end) -- now we got a table of structs

-- first, some helper functions:
local function grid_ref(table, i)
    if (i > #table.elements) or (i < 1) then
        return 0
    end
    return table.elements[i].old_state
end


local function cntNeighborhood(table, index)
    local mx = #table.elements // math.sqrt(#table.elements)
    local cnt = 0
    if grid_ref(table, index+1) == true then
        cnt = cnt + 1
    end
    if grid_ref(table, index-1) == true then
        cnt = cnt + 1
    end
    if grid_ref(table, index - mx) == true then
        cnt = cnt + 1
    end
    if grid_ref(table, index + mx) == true then
        cnt = cnt + 1
    end
    if grid_ref(table, index+mx - 1) == true then
        cnt = cnt + 1
    end
    if grid_ref(table, index+mx + 1) == true then
        cnt = cnt + 1
    end
    if grid_ref(table, index-mx - 1) == true then
        cnt = cnt + 1
    end
    if grid_ref(table, index-mx + 1) == true then
        cnt = cnt + 1
    end
    return cnt
end

local function print_plane(table)
    local mx = #table.elements // math.sqrt(#table.elements)
    print("\x1b[0;0H") -- puts the cursor to the column 0, row 0 of the terminal
    for e = 1, #table.elements, 1 do
        if (e % mx) == 0 then
            io.write("\n")
        end
        if table.elements[e].old_state == false then
            io.write(" ")
        else
            io.write("o")
        end
    end
end

local function update_plane(plane)
    for i = 1, #plane.elements, 1 do
        local cnt = cntNeighborhood(plane, i)
        if (cnt < 2) or (cnt > 3) then
            -- any cell with less than two live neighbors
            -- or more than 3 neighbors
            -- dies or stays dead.
            plane.elements[i].new_state = false
        elseif (cnt == 3) and (plane.elements[i].old_state == false) then
            plane.elements[i].new_state = true
        elseif ((cnt == 3) or (cnt == 2)) and (plane.elements[i].old_state == true) then
            plane.elements[i].new_state = true
        end
    end
    for i = 1, #plane.elements, 1 do
        plane.elements[i].old_state = plane.elements[i].new_state
    end
end

-- main loop
while true do
    print_plane(plane)
    update_plane(plane)
end