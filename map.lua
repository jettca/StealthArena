local json = require "json"
local filename = "map.json"
local wall_size = 5

function makeMap(world)
	local map_data = loadMapFromFile(filename)
	local map = {
		height = map_data["map_height"],
		width = map_data["map_width"],
		platforms = {},
		walls = {}
	}
	for _, p in ipairs(map_data["platforms"]) do
		platform = {}
		platform = makeObject(
			world,
			p.x + p.w/2,
			p.y + p.h/2,
			p.w,
			p.h,
            "floor"
		)
		table.insert(map.platforms, platform)
	end
	map.walls = {
		top = makeObject(world, map.width/2, wall_size/2, map.width, wall_size),
		bottom = makeObject(world, map.width/2, map.height - wall_size/2, map.width, wall_size, "floor"),
		left = makeObject(world, wall_size/2, map.height/2, wall_size, map.height - 2*wall_size),
		right = makeObject(world, map.width - wall_size/2, map.height/2, wall_size, map.height - 2*wall_size)
	}
	return map
end

function makeObject(world, x, y, w, h, data)
	obj =  {}
	obj.body = love.physics.newBody(world, x, y)
	obj.shape = love.physics.newRectangleShape(w, h)
	obj.fixture = love.physics.newFixture(obj.body, obj.shape)
    obj.fixture:setUserData(data)
	return obj
end

function drawWalls(walls)
	for _, wall in pairs(walls) do
		love.graphics.setColor(0,0,255)
		love.graphics.polygon("fill", wall.body:getWorldPoints(wall.shape:getPoints()))
		love.graphics.setColor(255,255,255)
	end
end

function drawPlatforms(platforms)
	for _, platform in ipairs(platforms) do
		love.graphics.setColor(255,0,0)
		love.graphics.polygon("fill", platform.body:getWorldPoints(platform.shape:getPoints()))
		love.graphics.setColor(255,255,255)
	end
end

function loadMapFromFile(fn)
	local data = json.decode(io.open(fn, "r"):read("*all"))
	if data["platforms"] == nil or
		data["map_width"] == nil or
		data["map_height"] == nil then
		print("Corrupt map file:"..fn)
	else
	    print("Data read from file:"..fn)
	end
	return data
end
