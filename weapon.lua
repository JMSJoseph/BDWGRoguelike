local Weapon = {}

function Weapon.init(type, startX, startY, bulletType)
    local weapon = 
    {
        type = type,
        x = startX,
        y = startY,
        bulletType = bulletType,
        
    }

    if(type == "Trench Shotgun") then
        weapon.sprite = love.graphics.newImage("sprites/weapons/trench_shotgun.png")
        weapon.cooldown = 1.5
        weapon.clip = 8
        weapon.ammo = 8
        weapon.reloadTime = 3
    end

    return weapon
end

return Weapon