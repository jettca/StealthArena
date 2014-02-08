local json = require "json"
local filename = "map.json"
local wall_width

function makeMap(world)
	local map_data = loadMapFromFile(filename)
	local platforms_data = map_data["platforms"]
	local map = {
		height = map_data["height"],
		width = map_data["width"],
		platforms = {},
		walls = {}
	}
	for index in 1, table.getn(platforms) do
		map.platforms[index] = {}
		map.platforms[index] = makeObject(
			map.platforms[index].w,
			map.platforms[index].h,
			map.platforms[index].x + plat_w/2,
			map.platforms[index].y + plat_h/2
		)
	end
	map.walls = {
		top = makeObject(world, map.width/2, wall_width/2, map.width, wall_width),
		bottom = makeObject(world, map.width/2, map.height - wall_width/2, map.width, wall_width),
		left = makeObject(world, wall_width/2, map.height/2, map.height - 2*wall_width),
		right = makeObject(world, width - wall_width/2, map.height/2, wall_width, map.height - 2*wall_width),
	}
	return map
end

function makeObject(world, h, w, x, y)
	obj =  {}
	obj.body = love.physics.newBody(world, x, y)
	obj.shape = love.physics.newRectangleShape(w, h)
	obj.fixture = love.physics.newFixture(obj.body, obj.shape)
	return obj
end

function loadMapFromFile(fn)
	local data = json.decode(jsonFile(fn))
	if data["platforms"] == nil or
		data["map_width"] == nil or
		data["map_height"] == nil then
		print("Corrupt map file:"..fn)
	else
	    print("Data read from file:"..fn)
	end
	return data
end
