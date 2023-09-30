local Enemy = {}

function Enemy.init(type, startX, startY)
    local enemy = 
    {
        type = type,
        x = startX,
        y = startY,
        isEnemy = true,
        path = nil,
        pathTimer = 0,
        pathTimerInital = 1,
        currentNode = 2
    }

    if(type == "Dummy") then
        enemy.health = 40
        enemy.speed = 0
        enemy.sprite = love.graphics.newImage("sprites/enemies/placeholder_dummy.png")
        enemy.width = enemy.sprite:getWidth()
        enemy.height = enemy.sprite:getHeight()
    end
    if(type == "Chaser") then
        enemy.health = 100
        enemy.speed = 200
        enemy.sprite = love.graphics.newImage("sprites/enemies/placeholder_chaser.png")
        enemy.width = enemy.sprite:getWidth()
        enemy.height = enemy.sprite:getHeight()
    end

    return enemy
end

return Enemy