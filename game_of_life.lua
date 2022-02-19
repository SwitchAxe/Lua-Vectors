-- --examples of map, filter and apply with vectors
--you can pass in vector:new in a functional (kinda) way and print
--it directly with 0 assignments. showing this to a C programmer is guaranteed
--to give them a heart attack! Also note, this is a complete filter-map-print example.

-- first, require the vector module
local vector = require("vector")


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
end) -- now we got a vector of structs

-- first, some helper functions:
local function grid_ref(vector, i)
    if (i > #vector.elements) or (i < 1) then
        return 0
    end
    return vector.elements[i].old_state
end


local function cntNeighborhood(vector, index)
    local mx = #vector.elements // math.sqrt(#vector.elements)
    local cnt = 0
    if grid_ref(vector, index+1) == true then
        cnt = cnt + 1
    end
    if grid_ref(vector, index-1) == true then
        cnt = cnt + 1
    end
    if grid_ref(vector, index - mx) == true then
        cnt = cnt + 1
    end
    if grid_ref(vector, index + mx) == true then
        cnt = cnt + 1
    end
    if grid_ref(vector, index+mx - 1) == true then
        cnt = cnt + 1
    end
    if grid_ref(vector, index+mx + 1) == true then
        cnt = cnt + 1
    end
    if grid_ref(vector, index-mx - 1) == true then
        cnt = cnt + 1
    end
    if grid_ref(vector, index-mx + 1) == true then
        cnt = cnt + 1
    end
    return cnt
end

local mx = #plane.elements // math.sqrt(#plane.elements)
local function print_plane(plane)
    print("\x1b[0;0H") -- puts the cursor to the column 0, row 0 of the terminal
    for e = 1, #plane.elements, 1 do
        if (e % mx) == 0 then
            io.write("\n")
        end
        if plane.elements[e].old_state == false then
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