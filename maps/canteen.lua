local CanteenMap = {}

CanteenMap.width = 20
CanteenMap.height = 15
CanteenMap.tilewidth = 32
CanteenMap.tileheight = 32
CanteenMap.backgroundColor = {0.9, 0.8, 0.7} -- Light beige/cream color for restaurant vibe

CanteenMap.tilesets = {}
CanteenMap.layers = {
    {
        name = "Floor",
        type = "tilelayer",
        x = 0, y = 0,
        width = 20, height = 15,
        visible = true,
        opacity = 1,
        offsetx = 0, offsety = 0,
        properties = {},
        encoding = "lua",
        data = {}, 
        objects = {}
    },
    {
        name = "Counter",
        type = "objectgroup",
        x = 0, y = 0,
        visible = true,
        opacity = 1,
        offsetx = 0, offsety = 0,
        properties = {},
        objects = {
            -- Shop Counter Interaction
            {
                name = "Counter",
                x = 200, y = 100,
                width = 240, height = 60, -- Wide counter
                shape = "rectangle",
                visible = true,
                properties = {}
            }
        }
    }
}

-- Simple Draw Function to fill background since we have no tiles
function CanteenMap:drawLayer(layer)
    -- Manual drawing if needed, but GameState uses generic tile drawing.
    -- We can set a global background in GameState if map has 'backgroundColor' property.
end

return CanteenMap
