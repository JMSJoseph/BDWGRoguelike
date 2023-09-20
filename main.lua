-- main.lua
local Player = require("player")
local Enemy = require("enemy")
local Weapon = require("weapon")
local Bullet = require("bullet")
local bump = require("lib/bump")
sti = require("lib/sti")
local world = bump.newWorld()
local screenWidth, screenHeight
screenHeight = 1056
screenWidth = 1920
local player = Player.init(screenWidth/2, screenHeight/2)
local weapon = Weapon.init("Trench Shotgun", (player.x + 50), (player.y + 40), "buck")
local timerWeapon = 0
local reloadTimer = 0

-- Initialize game state, variables, and libraries
function love.load()
    -- Set up the game window
    reloading = false
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
    timerWeapon = timerWeapon + dt
    if(reloading) then
        reloadTimer = reloadTimer + dt
    end
    if(reloadTimer >= weapon.reloadTime) then
        weapon.clip = weapon.ammo
        reloading = false
        reloadTimer = 0
    end

    weapon.x = (player.x + 50)
    weapon.y = (player.y+40)
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
    local filterFunc = function(item)
        return item.isEnemy
    end
    local filterCol = function(item)
        return item.isBox
    end
    for i = #activeBullets, 1, -1 do
        world:update(activeBullets[i], activeBullets[i].x, activeBullets[i].y, activeBullets[i].width, activeBullets[i].height)
        activeBullets[i].x = activeBullets[i].x + (activeBullets[i].speed*dt)*(math.cos(activeBullets[i].angle))
        activeBullets[i].y = activeBullets[i].y + (activeBullets[i].speed*dt)*(math.sin(activeBullets[i].angle))
        local cols, len = world:queryRect(activeBullets[i].x, activeBullets[i].y, activeBullets[i].width, activeBullets[i].height, filterFunc)
        local hitEnemy = cols[1]
        if len > 0 then
            -- Bullet has hit an enemy, handle the collision here
            world:remove(activeBullets[i])
            table.remove (activeBullets, i)
            hitEnemy.health = hitEnemy.health - 5
            break
        end
        local cols2, len2 = world:queryRect(activeBullets[i].x, activeBullets[i].y, activeBullets[i].width, activeBullets[i].height, filterCol)
        if len2 > 0 then
            world:remove(activeBullets[i])
            table.remove (activeBullets, i)
        end
    end
    for i = #activeEnemies, 1, -1 do
        if(activeEnemies[i].health <= 0) then
            world:remove(activeEnemies[i])
            table.remove(activeEnemies, i)
        end
    end

    
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
    love.graphics.draw(weapon.sprite, weapon.x, weapon.y)
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


    -- Handle player movement and actions
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

function weaponUse(type, x, y, button)
    local typeTable =
    {
        ["Trench Shotgun"] = function()
            if(timerWeapon >= weapon.cooldown and button == 1 and weapon.clip > 0) then 
                local spread = 0.08
                local bullet = Bullet.init("buck", true, weapon.x, weapon.y, x, y)
                world:add(bullet, bullet.x, bullet.y, bullet.width, bullet.height)
                table.insert(activeBullets, bullet)
                local r = math.random(-100, 100)
                local bullet2 = Bullet.init("buck", true, weapon.x, weapon.y, x, y)
                world:add(bullet2, bullet2.x, bullet2.y, bullet2.width, bullet2.height)
                bullet2.angle= bullet2.angle + ((spread/100)*r)
                table.insert(activeBullets, bullet2)
                r = math.random(-100, 100)
                local bullet3 = Bullet.init("buck", true, weapon.x, weapon.y, x, y)
                world:add(bullet3, bullet3.x, bullet3.y, bullet3.width, bullet3.height)
                bullet3.angle= bullet3.angle + ((spread/100)*r)
                table.insert(activeBullets, bullet3)
                weapon.clip = weapon.clip - 1
                timerWeapon = 0
            elseif(timerWeapon >= (weapon.cooldown-1.25) and button == 2 and weapon.clip > 0) then
                local spread = 0.16
                local r = math.random(-100, 100)
                local bullet = Bullet.init("buck", true, weapon.x, weapon.y, x, y)
                bullet.angle = bullet.angle + ((spread/100)*r)
                world:add(bullet, bullet.x, bullet.y, bullet.width, bullet.height)
                table.insert(activeBullets, bullet)
                r = math.random(-100, 100)
                local bullet2 = Bullet.init("buck", true, weapon.x, weapon.y, x, y)
                world:add(bullet2, bullet2.x, bullet2.y, bullet2.width, bullet2.height)
                bullet2.angle= bullet2.angle + ((spread/100)*r)
                table.insert(activeBullets, bullet2)
                r = math.random(-100, 100)
                local bullet3 = Bullet.init("buck", true, weapon.x, weapon.y, x, y)
                world:add(bullet3, bullet3.x, bullet3.y, bullet3.width, bullet3.height)
                bullet3.angle= bullet3.angle + ((spread/100)*r)
                table.insert(activeBullets, bullet3)
                weapon.clip = weapon.clip - 1
                timerWeapon = 0
            elseif(weapon.clip <= 0) then
                reloading = true
            end
        end,

    }
    if (typeTable[type]) then
        typeTable[type]()
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