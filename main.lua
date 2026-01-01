local utf8 = require("utf8")  -- [JOURNAL]
function love.load()
    gameState = "menu" -- can be "menu" or "playing"

    -- runs ONCE when the game starts
    anim8 = require 'libraries/anim8'
	love.graphics.setDefaultFilter("nearest", "nearest")
    SCALE = 4

	player = {}
	player.x = 400
	player.y = 200
    player.w = 32 * SCALE
    player.h = 32 * SCALE
	player.speed = 5
	player.spriteSheet = love.graphics.newImage('sprites/player-sheet3.png')
	player.grid = anim8.newGrid(32, 32, player.spriteSheet:getWidth(),player.spriteSheet:getHeight())

	player.animations = {}
	player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)  
								     
	player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)  
	
	player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2) 
	player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2) 

	player.anim = player.animations.left

    cat = {}
    cat.x = 400
    cat.y = 400
    cat.spriteSheet = love.graphics.newImage('sprites/cat.png')
    cat.scale = 2  -- half the size of character

    -- Each frame is 32x32 pixels
    cat.w = 32 * cat.scale
    cat.h = 32 * cat.scale

    cat.grid = anim8.newGrid(32, 32, cat.spriteSheet:getWidth(), cat.spriteSheet:getHeight())

    cat.anim = anim8.newAnimation(cat.grid('1-10', 1), 0.2)


    tree = {}
    tree.x = 500
    tree.y = 100
    tree.sprite = love.graphics.newImage('sprites/tree.png')


	background = love.graphics.newImage('sprites/background.png')

    house = {}
    house.x = 0
    house.y = 0
    house.image = love.graphics.newImage("sprites/house.png")

    -- Wall Colliders (top, left, right) leaving space for door
    house.walls = {
    -- Left wall
    {
        x = house.x + 8 * SCALE,
        y = house.y + 8 * SCALE,
        w = 12 * SCALE,
        h = 30 * SCALE
    },

    -- Right wall
    {
        x = house.x + 35 * SCALE,
        y = house.y + 8 * SCALE,
        w = 12 * SCALE,
        h = 30 * SCALE
    },

    -- Top wall
    {
        x = house.x + 8 * SCALE,
        y = house.y + 8 * SCALE,
        w = 48 * SCALE,
        h = 12 * SCALE
    }
}
    -- Scene
    currentScene = "outside"  -- "outside" or "inside"

    interiorBackground = love.graphics.newImage("sprites/bedroom.png")

    exitButton = {
    x = 700,   -- position on screen
    y = 20,
    w = 80,
    h = 30,
    text = "Exit"
}
 


    -- Time of day
    timeOfDay = 3 -- 1=morning, 2=afternoon, 3=evening

    paper = {}
    paper.image = love.graphics.newImage("sprites/paper.png")
    paper.scale = 0.8
    paper.w = paper.image:getWidth() * paper.scale  -- scale width
    paper.h = paper.image:getHeight() * paper.scale -- scale height
    paper.x = 200
    paper.y = 200
  
    paper.clicked = false
    paper.text = "" -- current typed entry
    paper.showEntry = nil  -- stores text to show on paper

    -- Close button for full-screen paper
    paper.closeButton = { w = 100, h = 30, text = "Close" }

    -- Load music
    music = love.audio.newSource("sounds/lofi music.mp3", "stream")
    music:setLooping(true)   -- loop it
    music:setVolume(0.5)  -- 0.0 = silent, 1.0 = full volume
    music:play()  


    -- Meow Sound
    meowSound = love.audio.newSource("sounds/meow.mp3", "static")

end


function love.update(dt)
    -- runs every frame (logic)

    local oldX = player.x
    local oldY = player.y
    local isMoving = false

    -- Movement
    if love.keyboard.isDown("right") and not love.keyboard.isDown("left") then
	    player.x = player.x + player.speed
	    player.anim = player.animations.right
	    isMoving = true
    end

    if love.keyboard.isDown("left") and not love.keyboard.isDown("right") then
        player.x = player.x - player.speed
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("down") then
       player.y = player.y + player.speed
       player.anim = player.animations.down
       isMoving = true
    end

    if love.keyboard.isDown("up") then
       player.y = player.y - player.speed
       player.anim = player.animations.up
       isMoving = true
    end

    -- House wall collision
    if currentScene == "outside" then

        -- horizontal movement
        local newX = player.x
        if love.keyboard.isDown("right") then newX = newX + player.speed end
        if love.keyboard.isDown("left") then newX = newX - player.speed end

        -- check horizontal collisions
        player.x = newX
        for _, wall in ipairs(house.walls) do
            if aabb(player, wall) then player.x = oldX end
        end
        if aabb(player, cat) then player.x = oldX end

        -- vertical movement
        local newY = player.y
        if love.keyboard.isDown("down") then newY = newY + player.speed end
        if love.keyboard.isDown("up") then newY = newY - player.speed end

        -- check vertical collisions
        player.y = newY
        for _, wall in ipairs(house.walls) do
            if aabb(player, wall) then
                player.y = oldY  
            end
            
        end
        if aabb(player, cat) then player.y = oldY end
        
    end

    
    -- Update animation
    if isMoving then
        player.anim:update(dt)
    end

    cat.anim:update(dt)

     -- Door detection (only outside)
    if currentScene == "outside" then
        player.nearDoor = nearDoor(player, house)
    else
        player.nearDoor = false
    end
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    player.x = math.max(0, math.min(player.x, screenW - player.w))
    player.y = math.max(0, math.min(player.y, screenH - player.h))
end

function love.draw()
    -- runs every frame (drawing)
    function love.draw()
    if gameState == "menu" then
        -- Background color
        love.graphics.setBackgroundColor(0.2, 0.2, 0.2)
        
        -- Draw title
        love.graphics.setColor(1,1,1)
        love.graphics.printf("Chill Game/Meimei's Journal", 0, 100, love.graphics.getWidth(), "center")
        
        -- Draw start button
        local buttonW, buttonH = 200, 50
        local buttonX = (love.graphics.getWidth() - buttonW)/2
        local buttonY = 250
        love.graphics.setColor(0.7,0.7,0.7) -- gray button
        love.graphics.rectangle("fill", buttonX, buttonY, buttonW, buttonH)
        love.graphics.setColor(0,0,0)
        love.graphics.printf("Start Game", buttonX, buttonY + 15, buttonW, "center")
        love.graphics.setColor(1,1,1)
    else
        -- your normal game draw code
        if currentScene == "outside" then
            love.graphics.draw(background, 0, 0, 0, SCALE, SCALE)
            love.graphics.draw(house.image, house.x, house.y, 0, SCALE, SCALE)
            love.graphics.draw(tree.sprite, tree.x, tree.y, 0, SCALE, SCALE)
        

        -- Door hint
            if player.nearDoor then
                love.graphics.print("Press E to enter", player.x, player.y - 20)
            end
       
        elseif currentScene == "inside" then

        -- change bedroom
            love.graphics.draw(interiorBackground, 0, 0) 

        -- draw exit button
            love.graphics.setColor(0.7, 0.7, 0.7) -- gray button
            love.graphics.rectangle("fill", exitButton.x, exitButton.y, exitButton.w, exitButton.h)
            love.graphics.setColor(0, 0, 0) -- black text
            love.graphics.printf(exitButton.text, exitButton.x, exitButton.y + 7, exitButton.w, "center")
            love.graphics.setColor(1, 1, 1) -- reset color
    
         -- draw small paper if not clicked and no journal entry
            if not paper.clicked and not paper.showEntry then
                love.graphics.draw(paper.image, paper.x, paper.y, 0, paper.scale, paper.scale)
            end

            -- full-screen paper when clicked or showing entry
            if paper.clicked or paper.showEntry then
                local screenW = love.graphics.getWidth()
                local screenH = love.graphics.getHeight()
        
            -- draw paper image centered and scaled to fit screen
                local scaleX = screenW / paper.image:getWidth() * 0.8
                local scaleY = screenH / paper.image:getHeight() * 0.8
                local scale = math.min(scaleX, scaleY)
                local px = (screenW - paper.image:getWidth() * scale) / 2
                local py = (screenH - paper.image:getHeight() * scale) / 2

            -- Draw full screen paper
                love.graphics.draw(paper.image, px, py, 0, scale, scale)

              -- [JOURNAL] Draw typed or finalized entry
                love.graphics.setColor(0,0,0)
                local displayText = paper.showEntry or paper.text
                love.graphics.printf(displayText, px + 50, py + 50, paper.image:getWidth() * scale - 100, "left")
                love.graphics.setColor(1,1,1)

            -- Draw Close button
                paper.closeButton.x = px + paper.image:getWidth() * scale - paper.closeButton.w - 20
                paper.closeButton.y = py + paper.image:getHeight() * scale - paper.closeButton.h - 20
                love.graphics.setColor(0.7,0.7,0.7)
                love.graphics.rectangle("fill", paper.closeButton.x, paper.closeButton.y, paper.closeButton.w, paper.closeButton.h)
                love.graphics.setColor(0,0,0)
                love.graphics.printf(paper.closeButton.text, paper.closeButton.x, paper.closeButton.y + 7, paper.closeButton.w, "center")
                love.graphics.setColor(1,1,1)

            end
        
            -- draw time-of-day tint
            drawTimeTint()
        end
    
        cat.anim:draw(cat.spriteSheet, cat.x, cat.y, 0, cat.scale, cat.scale)
        player.anim:draw(player.spriteSheet, player.x, player.y, nil, SCALE, SCALE)
    
    end
end



    
    

end

function love.keypressed(key)
    if key == "e" and player.nearDoor and currentScene == "outside" then
        enterHouse()
    end

    -- [JOURNAL] Backspace deletes last character
    if key == "backspace" and paper.clicked and not paper.showEntry then
        local byteoffset = utf8.offset(paper.text, -1)
        if byteoffset then
            paper.text = string.sub(paper.text, 1, byteoffset - 1)
        end
    end

    -- [JOURNAL] Enter finalizes journal entry
    if key == "return" and paper.clicked and not paper.showEntry then
        paper.showEntry = paper.text
        table.insert(journalEntries, paper.showEntry)
        paper.clicked = false
        paper.text = ""
         -- advance time
        timeOfDay = math.min(timeOfDay + 1, 3)
        
    end
end


function nearDoor(player, house)
    local door = {
        x = house.x + 20 * SCALE,
        y = house.y + 32 * SCALE,
        w = 24 * SCALE,
        h = 32 * SCALE
    }

    return player.x < door.x + door.w and
           player.x + player.w > door.x and
           player.y < door.y + door.h and
           player.y + player.h > door.y
end

function aabb(a, b)
    return a.x < b.x + b.w and
           a.x + a.w > b.x and
           a.y < b.y + b.h and
           a.y + a.h > b.y
end

function enterHouse()
    currentScene = "inside"
    -- Set player start position inside the house
    player.x = 200
    player.y = 150
end


-- MOUSE PRESSES
function love.mousepressed(mx, my, button)

    if button == 1 and gameState == "menu" then
        local buttonW, buttonH = 200, 50
        local buttonX = (love.graphics.getWidth() - buttonW)/2
        local buttonY = 250
        if mx >= buttonX and mx <= buttonX + buttonW and
           my >= buttonY and my <= buttonY + buttonH then
            gameState = "playing"
        end
    end

    if button == 1 then -- left mouse button
        -- check if click is on the cat
        if mx >= cat.x and mx <= cat.x + cat.w and
           my >= cat.y and my <= cat.y + cat.h then
            meowSound:play()
        end
    end
    if button == 1 and currentScene == "inside" then -- left mouse button
        -- exit button
        if mx >= exitButton.x and mx <= exitButton.x + exitButton.w and
           my >= exitButton.y and my <= exitButton.y + exitButton.h then
            -- exit the house
            currentScene = "outside"
            -- reset player position outside the house
            player.x = 100
            player.y = 200
        end

        -- Click small paper for full screen
        if not paper.clicked and not paper.showEntry then
            if mx >= paper.x and mx <= paper.x + paper.w and
               my >= paper.y and my <= paper.y + paper.h then
                paper.clicked = true
            end
        end
        -- [JOURNAL] Close button click works for typed or shown entry
        if (paper.clicked or paper.showEntry) and paper.closeButton.x and paper.closeButton.y then
            if mx >= paper.closeButton.x and mx <= paper.closeButton.x + paper.closeButton.w and
               my >= paper.closeButton.y and my <= paper.closeButton.y + paper.closeButton.h then
                paper.clicked = false
                paper.showEntry = nil
                paper.text = ""
                return
            end
        end
        
    end
end

-- TIME OF DAY TINT
function drawTimeTint()
    if timeOfDay == 2 then
        love.graphics.setColor(1, 0.9, 0.8, 0.15) -- afternoon tint
    elseif timeOfDay == 3 then
        love.graphics.setColor(0.4, 0.4, 0.6, 0.25) -- evening tint
    else
        love.graphics.setColor(1,1,1,0)
    end
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1,1,1)
end

-- [JOURNAL] Capture typed letters
function love.textinput(t)
    if paper.clicked and not paper.showEntry then
        paper.text = paper.text .. t
    end
end