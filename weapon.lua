local Weapon = {}

function Weapon.init(type, startX, startY)
    local weapon = 
    {
        type = type,
        x = startX,
        y = startY,
        
    }

    if(type == "Trench Shotgun") then
        weapon.sprite = love.graphics.newImage("sprites/weapons/trench_shotgun.png")
        weapon.cooldown = 1.5
        weapon.clip = 8
        weapon.ammo = 8
        weapon.reloadTime = 3
        weapon.bulletType = "buck"
    end
    if(type == "Fists") then
        weapon.cooldown = .5
        weapon.isMelee = true
        weapon.bulletType = "fists"
        weapon.trueRange = 1
        weapon.range = 1
        weapon.altRange = 0.5
    end

    return weapon
end

return Weapon