local Bullet = {}

function Bullet.init(type, good, startX, startY, targetX, targetY)
    local bullet = 
    {
        type = type,
        good = good,
        x = startX,
        y = startY,
        targetX = targetX,
        targetY = targetY,
        angle = math.atan2((targetY - startY), (targetX - startX))
    }

    if(type == "buck") then
        bullet.sprite = love.graphics.newImage("sprites/weapons/bullet/buck.png")
        bullet.speed = 500
        bullet.width = bullet.sprite:getWidth()
        bullet.height = bullet.sprite:getHeight()
        bullet.damage = 5
    end
    if(type == "fists") then
        bullet.sprite = love.graphics.newImage("sprites/weapons/bullet/meleetest.png")
        bullet.speed = 1000
        bullet.width = bullet.sprite:getWidth()
        bullet.height = bullet.sprite:getHeight()
        bullet.damage = 5
        bullet.isMelee = true
    end

    return bullet
end

return Bullet