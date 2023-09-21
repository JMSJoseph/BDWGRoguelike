-- main.lua
local Player = require("player")
local Enemy = require("enemy")
local Weapon = require("weapon")
local Bullet = require("bullet")
local bump = require("lib/bump")
local sti = require("lib/sti")


-- Initialize game state, variables, and libraries
function love.load()
    -- Set up the game window
    world = bump.newWorld()
    screenHeight = 1056
    screenWidth = 1920
    player = Player.init(screenWidth/2, screenHeight/2)
    startingGun = Weapon.init("Trench Shotgun", 0, 0)
    startingMelee = Weapon.init("Fists", 0, 0)
    heldWeapons = {startingGun, startingMelee}
    weapon = heldWeapons[1]
    hands = 2
    heldIndex = 1
    timerWeapon = 0
    reloadTimer = 0
    tileSize = 64
    reloading = false
    meleeTimer = 0
    gameMap = sti('maps/test_map.lua')
    gameMap:resize(1920,1056)
    world:add(player, player.x, player.y, player.width, player.height)
    collisions = {}
    for _, object in ipairs(gameMap.layers["Collisions"].objects) do
        local collisionBox = {
            x = object.x,
            y = object.y,
            width = object.width,
            height = object.height,
            isBox = true
        }
        table.insert(collisions, collisionBox)
    end
    for _, collision in ipairs(collisions) do
        world:add(collision, collision.x, collision.y, collision.width, collision.height)
    end
    activeBullets = {}
    activeEnemies = {}
    love.window.setTitle("BWDG: Ain't no Game")
    love.window.setMode(screenWidth, screenHeight, {fullscreen = false})
    moveLeft = false
    moveRight = false
    moveDown = false
    moveUp = false
    
    -- Load game assets (images, sounds, fonts, etc.)
    
    -- Initialize game data (player stats, level data, etc.)
end

-- Update game logic (e.g., player movement, enemy AI)
function love.update(dt)
    -- Handle player input (keyboard, mouse, etc.)
    -- Update game objects and entities
    weapon = heldWeapons[1]
    weaponLogic(dt)
    weaponPosition(dt, weapon.type)
    playerMovement(dt)
    bulletLogic(dt)
    enemyLogic(dt)

    
    -- Check for collisions and resolve them
    
    -- Handle game events (e.g., player actions, enemy actions)
end

-- Render the game world
function love.draw()
    gameMap:draw()
    love.graphics.print("Player HP: " .. player.health, 0, 0)
    for _, bullet in ipairs(activeBullets) do
        love.graphics.draw(bullet.sprite, bullet.x, bullet.y)
    end
    love.graphics.draw(player.sprite, player.x, player.y)
    for _, enemy in ipairs(activeEnemies) do
        love.graphics.draw(enemy.sprite, enemy.x, enemy.y)
        love.graphics.print("HP: " .. enemy.health, enemy.x, enemy.y - 10)
    end
    if(weapon.isMelee == nil) then
        love.graphics.draw(weapon.sprite, weapon.x, weapon.y)
    end
    -- Draw the game map
    
    -- Draw game entities (player, enemies, items, etc.)
    
    -- Draw the HUD (health, score, etc.)
end

-- Handle keyboard input
function love.keypressed(key)
    if key == 'a' then
        moveLeft = true
    end
    if key == 'd' then
        moveRight = true
    end
    if key == 'w' then
        moveUp = true
    end
    if key == 's' then
        moveDown = true
    end
    if key == 'y' then
        local enemy = Enemy.init("Dummy", player.x, player.y)
        world:add(enemy, enemy.x, enemy.y, enemy.width, enemy.height)
        table.insert(activeEnemies, enemy)
    end
    if key == 'u' then
        local enemy = Enemy.init("Chaser", (player.x + 128), player.y)
        world:add(enemy, enemy.x, enemy.y, enemy.width, enemy.height)
        table.insert(activeEnemies, enemy)
    end


    -- Handle player movement and actions
end

function love.wheelmoved( x, y )
    if (y > 0) then
        local newTable = {}
        local j = 1
        newTable[hands] = heldWeapons[1]
        for i = 2, hands do
            newTable[j] = heldWeapons[i]
            j = j + 1
        end
        heldWeapons = newTable

    end
    if (y < 0) then
        local newTable = {}
        local j = 1
        newTable[1] = heldWeapons[hands]
        for i = 1, (hands-1) do
            newTable[i+1] = heldWeapons[i]
        end
        heldWeapons = newTable
    end
end

function love.keyreleased(key)
    if key == 'a' then
        moveLeft = false
    end
    if key == 'd' then
        moveRight = false
    end
    if key == 'w' then
        moveUp = false
    end
    if key == 's' then
        moveDown = false
    end

end

function weaponPosition(dt, type)
    local typeTable =
    {
        ["Trench Shotgun"] = function()
            weaponX = (player.x+(player.width/1.3))
            weaponY = (player.y+(player.height/3))
            weapon.x = weaponX
            weapon.y = weaponY
        end,
        ["Fists"] = function()
            weaponX = (player.x+(player.width/2) - (tileSize/6.4))
            weaponY = (player.y+(player.height/2))
            weapon.x = weaponX
            weapon.y = weaponY
        end,
    }
    if (typeTable[type]) then
        typeTable[type]()
    end
end

function weaponUse(type, x, y, button)
    local typeTable =
    {
        ["Trench Shotgun"] = function()
            if(timerWeapon >= weapon.cooldown and button == 1 and weapon.clip > 0) then 
                local spread = 0.08
                local shots = 3
                local r = 0
                while(shots > 0) do
                    local bullet = Bullet.init(weapon.bulletType, true, weapon.x, weapon.y, x, y)
                    if(shots < 3) then
                        r = math.random(-100, 100)
                        bullet.angle = bullet.angle + ((spread/100)*r)
                    end
                    world:add(bullet, bullet.x, bullet.y, bullet.width, bullet.height)
                    table.insert(activeBullets, bullet)
                    shots = shots - 1
                end
                weapon.clip = weapon.clip - 1
                timerWeapon = 0
            elseif(timerWeapon >= (weapon.cooldown-1.25) and button == 2 and weapon.clip > 0) then
                local spread = 0.16
                local shots = 3
                local r = 0
                while(shots > 0) do
                    local bullet = Bullet.init(weapon.bulletType, true, weapon.x, weapon.y, x, y)
                    r = math.random(-100, 100)
                    bullet.angle = bullet.angle + ((spread/100)*r)
                    world:add(bullet, bullet.x, bullet.y, bullet.width, bullet.height)
                    table.insert(activeBullets, bullet)
                    shots = shots - 1
                end
                weapon.clip = weapon.clip - 1
                timerWeapon = 0
            elseif(weapon.clip <= 0) then
                reloading = true
            end
        end,
        ["Fists"] = function()
            if (timerWeapon >= weapon.cooldown and button == 1) then
                weapon.range = weapon.trueRange
                local bullet = Bullet.init(weapon.bulletType, true, weapon.x, weapon.y, x, y)
                world:add(bullet, bullet.x, bullet.y, bullet.width, bullet.height)
                table.insert(activeBullets, bullet)
                timerWeapon = 0
            elseif (timerWeapon >= weapon.cooldown + 1 and button == 2) then
                weapon.range = weapon.altRange
                local bullet = Bullet.init(weapon.bulletType, true, weapon.x, weapon.y, x, y)
                bullet.damage = bullet.damage * 2
                world:add(bullet, bullet.x, bullet.y, bullet.width, bullet.height)
                table.insert(activeBullets, bullet)
                timerWeapon = 0
            end
        end,

    }
    if (typeTable[type]) then
        typeTable[type]()
    end
end

function playerMovement(dt)
    local vx = 0
    local vy = 0
    if moveLeft then
        vx = -1 * (player.speed*dt)
    end
    if moveRight then
        vx = (player.speed*dt)
    end
    if moveDown then
        vy = (player.speed*dt)
    end
    if moveUp then
        vy = -1 * (player.speed*dt)
    end
    local function playerCollisionFilter(item, other)
        if other.isBox then
            return 'slide'
        end
        return 'cross' 
    end
    local newX, newY, cols, len = world:move(player, player.x + vx, player.y + vy, playerCollisionFilter)
    player.x, player.y = newX, newY
    for _, col in ipairs(cols) do
        
    end 
end

function bulletLogic(dt)
    for i = #activeBullets, 1, -1 do
        local curBullet = activeBullets[i]
        local remove = false
        if(not(weapon.isMelee == nil) and not(curBullet.isMelee == nil)) then
            local distanceSquared = ((curBullet.x - weapon.x)^2 + (curBullet.y - weapon.y)^2)^0.5
            if (distanceSquared >= weapon.range * tileSize) then
                remove = true
            end
        end
        local vx = (curBullet.speed*dt)*(math.cos(curBullet.angle))
        local vy = (curBullet.speed*dt)*(math.sin(curBullet.angle))
        local function bulletCollisionFilter(item, other)
            return 'cross'
        end
        local newX, newY, cols, len = world:move(curBullet, curBullet.x + vx, curBullet.y + vy, bulletCollisionFilter)
        curBullet.x, curBullet.y = newX, newY
        for i=1,len do
            if not(cols[i].other.isEnemy == nil) then
                cols[i].other.health = cols[i].other.health - curBullet.damage
                remove = true
            elseif not(cols[i].other.isBox == nil) then
                remove = true
            end
        end
        if(remove) then
            world:remove(curBullet)
            table.remove (activeBullets, i)
        end

    end
end

function enemyLogic(dt)
    for i = #activeEnemies, 1, -1 do
        local remove = false
        local curEnemy = activeEnemies[i]
        enemyAI(curEnemy, dt)
        if(curEnemy.health <= 0) then
            remove = true
        end
        if(remove) then
            world:remove(curEnemy)
            table.remove(activeEnemies, i)
        end

    end
end

function enemyAI(curEnemy, dt)
    local type = curEnemy.type
    local typeTable =
    {
        ["Dummy"] = function()
        end,
        ["Chaser"] = function()
            local angle = math.atan2((player.y - curEnemy.y), (player.x - curEnemy.x))
            local vx = (curEnemy.speed*dt)*(math.cos(angle))
            local vy = (curEnemy.speed*dt)*(math.sin(angle))
            local function enemyCollisionFilter(item, other)
                if other.isBox then
                    return 'slide'
                end
                return 'cross'
            end
            local newX, newY, cols, len = world:move(curEnemy, curEnemy.x + vx, curEnemy.y + vy, enemyCollisionFilter)
            curEnemy.x, curEnemy.y = newX, newY
            for i=1,len do

            end
        end,
    }
    if (typeTable[type]) then
        typeTable[type]()
    end 
end

function weaponLogic(dt)
    timerWeapon = timerWeapon + dt
    if(reloading) then
        reloadTimer = reloadTimer + dt
    end
    if(weapon.isMelee == nil and reloadTimer >= weapon.reloadTime) then
        weapon.clip = weapon.ammo
        reloading = false
        reloadTimer = 0
    end
end

-- Handle mouse input
function love.mousepressed(x, y, button)
    -- Handle mouse interactions (e.g., clicking on items)
    if button == 1 then
        weaponUse(weapon.type, x, y, button)
    end
    if button == 2 then
        weaponUse(weapon.type, x, y, button)
    end
end

-- Handle game window resizing
function love.resize(w, h)
    -- Adjust the game's view when the window is resized
end

-- Cleanup and save data before quitting
function love.quit()
    -- Save game progress or perform cleanup tasks
end