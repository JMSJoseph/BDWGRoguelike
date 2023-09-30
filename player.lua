local Player = {}

function Player.init(startX, startY)
    local player = 
    {
            health = 40,
            x = startX,
            y = startY,
            speed = 900,
            isPlayer = true,
            sprite = love.graphics.newImage("sprites/player/placeholder_player.png")
    }
    player.width = player.sprite:getWidth()
    player.height = player.sprite:getHeight()
    return player
end

return Player