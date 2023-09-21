local Rooms = {}

function Rooms.init()
    local rooms = 
    {
       "test_boss",
       "test_map",
       "test_map2",
       "test_map3",
       "test_shop",
       "test_treasure",
    }
    rooms.size = 6
    return rooms
end

return Rooms