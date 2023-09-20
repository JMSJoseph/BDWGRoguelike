local Enemy = {}

function Enemy.init(type, startX, startY)
    local enemy = 
    {
        type = type,
        x = startX,
        y = startY,
        isEnemy = true
    }

    if(type == "Dummy") then
        enemy.health = 40
        enemy.sprite = love.graphics.newImage("sprites/enemies/placeholder_dummy.png")
        enemy.width = enemy.sprite:getWidth()
        enemy.height = enemy.sprite:getHeight()
    end

    return enemy
end

return Enemy