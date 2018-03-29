-----------------------------------------------------------------------------------------
--
-- level1.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()
local function showMainScene()
	score = 0
	local options = {
		effect="fade",
		time= 500
	}
	composer.gotoScene("menu", options )
end
-- include Corona's "physics" library
local physics = require "physics"
local backgroundMusic= audio.loadSound("BackgroundMusic.mp3",1)
--------------------------------------------

-- forward declarations and other locals
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local scrollSpeed=2
--declare all local variables
local spaceShipProperties,spaceShipSheet,spaceShipSprite,spaceshipTable,powerUpsProperties,powerUpsSheet,powerUpsSprite,powerUpsTable,asteroidProperties,asteroidSheet,asteroidSprite,asteroidTable,fuelProperties,fuelSprite,fuelTable,sequenceData
local offscreen,score,asteroidSound,floorObject

-- Declare table for these objects because they will be spawned randomly after game runs and this will make it easier to destroy them or reference them
local asteroidsTable={}
local fuelsTable={}
local powerZUp1Table={}
local powerZUp2Table={}

function scene:create( event )

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	local sceneGroup = self.view

	-- We need physics started to add bodies, but we don't want the simulaton
	-- running until the scene is on the screen.
	physics.start()
	physics.pause()
	--Floor Object
	--local floorObject = display.newRect(screenW/2,screenH,screenW+400,50)
	--physics.addBody(floorObject,"static")
	--floorObject.myName="floorObject"

	--CREATE A MOVING BACKGROUND---------------------------------------------------------------------------
	local background = display.newImageRect( "Spacebg.png" , screenW, screenH )
	background.anchorX = 0 
	background.anchorY = 0
	background.x = -20 + display.screenOriginX 
	background.y = 0 + display.screenOriginY
	local background2 = display.newImageRect( "Spacebg.png" , screenW, screenH )
	background2.anchorX = 0 
	background2.anchorY = 0
	background2.x = background.x+screenW/2
	background2.y = 0 + display.screenOriginY
	local background3 = display.newImageRect( "Spacebg.png" , screenW, screenH )
	background3.anchorX = 0 
	background3.anchorY = 0
	background3.x = background2.x+screenW/2
	background3.y = 0 + display.screenOriginY
	
	local function move(event)
	background.x=background.x-scrollSpeed-25
	background2.x=background2.x-scrollSpeed-25
	background3.x=background3.x-scrollSpeed-25
	
	if(background.x+background.contentWidth) < 200   then
		background:translate(screenW+300,0)
		end
	if(background2.x+background2.contentWidth) < 200   then
		background2:translate(screenW+300,0)
		end
	if(background3.x+background3.contentWidth) < 200   then
		background3:translate(screenW+300,0)
		end
	end
	Runtime:addEventListener("enterFrame",move)
	---------------------------------------------------------------------------------------------------------------------
	-- Add Display Objects
	--Properties for objects
	local spaceShipProperties={0,-13,8,-11,14,-6,17,-3,17,2,17,7,14,11,9,14,0,14,-15,14,-17,10,-21,5,-21,14}
	local powerUpsProperties={0,-17,13,-12,15,-3,14,6,10,14,-11,14,-18,9,-18,-2,-15,-12,-12,-15}
	local asteroidProperties={-2,-14,2,-13,6,-9,9,-2,9,0,1,8,-3,8,-9,5,-12,1,-12,-6,-10,-12,-8,-14}
	local fuelProperties={0,-8,3,-8,4,-7,4,6,3,7,-5,7,-6,6,-6,-7,-5,-8}
	-- Score Object
	score = 0
	scoreText = display.newText(score, screenW/3+60, screenH/7,"prstart.ttf")
	scoreText:setFillColor(1,1,1)
	

	
	
	--SpaceShip Object, PowerUps Object, Asteroid Object
	--Spaceship Object
	 local spaceshipTable= {
			width =96,
			height=96,
			numFrames=14,
			sheetContentHeight=672,
			sheetContentWidth=192
	}
	local spaceShipSheet= graphics.newImageSheet("Spaceship.png",spaceshipTable)
	--Sequence Data for objects must be declared before objects are declared,
	 local sequenceData={
	{
	name="moveShipxd",
	sheet=spaceShipSheet,
	frames={1,2,3},
	time=200,
	loop=-1
	},
	{
	name="explode",
	sheet=spaceShipSheet,
	frames={3,8,14,9,10,11,12,14},
	time=1000,
	loop=1
	},
	{
	name="poweredUp1",
	frames={3,4,5},
	sheet=spaceShipSheet,
	time=500
	},
	{
	name="poweredUp2",
	sheet=spaceShipSheet,
	frames={3,6,7},
	time=500
	},
	{
	name="powerUp1",
	sheet=PowerUpsSheet,
	frames={1},
	time=2000,
	},
	{
	name="powerUp2",
	sheet=powerUpsSheet,
	frames={2},
	time=2000,
	},
	{
	name="asteroid",
	sheet=asteroidSheetSheet,
	frames={1},
	time=2000,
	},
	{
	name="fuel",
	sheet=asteroidSheet,
	frames={2},
	time=2000,
	}
	}
	-- Spaceship object declared
	spaceShipSprite=display.newSprite(spaceShipSheet,sequenceData)
	spaceShipSprite.x= 0+50
	spaceShipSprite.xScale=.5
	spaceShipSprite.yScale=.5
	spaceShipSprite.y=screenH/2
	physics.addBody(spaceShipSprite,"static",{radius=18})-- Using ship properties was glitchy so just used radius
	spaceShipSprite.myName = "spaceShip"
	--PowerUps Object
	local powerUpsTable= {
			width =96,
			height=96,
			numFrames=2,
			sheetContentHeight=192,
			sheetContentWidth=96
	}
	local powerUpsSheet= graphics.newImageSheet("PowerUps.png",powerUpsTable)
	--------------------------------------------------------------------------powerUpsSprite=display.newSprite(powerUpsSheet,sequenceData)
	---------------------------------------------------------------------------powerUpsSprite.xScale=.5
	----------------------------------------------------------------------------powerUpsSprite.yScale=.5
	-----------------------------------------------------------------------------physics.addBody(powerUpsSprite,"dynamic",{shape=powerUpsProperties})
	--Asteroid/Fuel Object (Named both asteroid for simplicity)
	local asteroidTable= {
			width =64,
			height=64,
			numFrames=2,
			sheetContentHeight=128,
			sheetContentWidth=64
	}
	local asteroidSheet= graphics.newImageSheet("Asteroid.png",asteroidTable)
	
	
	
	
	--------------------------------------------------------------------fuelSprite=display.newSprite(asteroidSheet,sequenceData)
	--------------------------------------------------------------------fuelSprite:setSequence("fuel")
	---------------------------------------------------------------------fuelSprite.xScale=.5
	----------------------------------------------------------------------fuelSprite.yScale=.5
	--------------------------------------------------------------------------physics.addBody(fuelSprite,"dynamic",{shape=fuelProperties})
	-----------------------------------------------------------------------asteroidSprite=display.newSprite(asteroidSheet,sequenceData)
	-----------------------------------------------------------------------asteroidSprite:setSequence("asteroid")
	------------------------------------------------------------------------asteroidSprite.xScale=.5
	-------------------------------------------------------------------------asteroidSprite.yScale=.5
	-----------------------------------------------------------------------------physics.addBody(asteroidSprite,"dynamic",{shape=asteroidProperties})
	------------------------------------------------------------------------------------------------------------------------------------------------
	--*******IMPORTANT: I made all of these objects comments because they are only created when the scene is on screen, not before hand------
	------------------------------------------------------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------------
	-- Audio for objects
	local asteroidSound = audio.loadStream("162470__kastenfrosch__sprunginnen.mp3")
	local spaceShipSound 
	local powerUp1Sound
	local powerUp2Sound
	local fuelSound
	
	
	
	-- Functions for objects---------------------------------------------
	

	---------------------------------------------------------------
	
	
	
	
	function moveShip(event)
	if score >=200 and score <500 then
	spaceShipSprite:setSequence("poweredUp1")
	spaceShipSprite:setFillColor(1)-- reset fill color if you lose points
	spaceShipSprite:play()
	transition.to(spaceShipSprite,{y=event.y,x=event.x, time=300})
	spaceShipSprite.myName= "spaceShip"
	elseif score >= 500 and score <750  then
	spaceShipSprite:setSequence("poweredUp2")
	spaceShipSprite:setFillColor(1)-- reset fill color if you lose points
	spaceShipSprite:play()
	transition.to(spaceShipSprite,{y=event.y,x=event.x, time=300})
	spaceShipSprite.myName ="spaceShip"
	elseif score >= 750 and score < 1500 then
	spaceShipSprite:setSequence("poweredUp2")
	spaceShipSprite:setFillColor(1)
	spaceShipSprite:setFillColor(1,0,1)-- Purple Ship
	spaceShipSprite:play()
	transition.to(spaceShipSprite,{y=event.y,x=event.x, time=300})
	spaceShipSprite.myName ="spaceShip"
	elseif score >= 1500 and score < 3000 then
	spaceShipSprite:setSequence("poweredUp1")
	spaceShipSprite:setFillColor(1)
	spaceShipSprite:setFillColor(1,0,1)-- Red with Purple Window
	spaceShipSprite:play()
	transition.to(spaceShipSprite,{y=event.y,x=event.x, time=300})
	spaceShipSprite.myName ="spaceShip"
	elseif score >= 3000 then
	spaceShipSprite:setSequence("poweredUp2")
	spaceShipSprite:setFillColor(1)
	spaceShipSprite:setFillColor(1,0,.7)
	spaceShipSprite:play()
	transition.to(spaceShipSprite,{y=event.y,x=event.x, time=300})
	spaceShipSprite.myName ="spaceShip"
	elseif score < 200 and score > -200 then
	spaceShipSprite:setSequence("moveShipxd")
	spaceShipSprite:setFillColor(1)-- Reset Fill Color if you lose points
	spaceShipSprite:play()
	transition.to(spaceShipSprite,{y=event.y,x=event.x, time=300})
	spaceShipSprite.myName= "spaceShip"
	else
	spaceShipSprite:setSequence("explode")-- You are close to dying
	spaceShipSprite:setFillColor(1)-- Reset Fill Color if you lose points
	spaceShipSprite:play()
	transition.to(spaceShipSprite,{y=event.y,x=event.x, time=300})
	spaceShipSprite.myName= "spaceShip"
	return true
	end
	
		--if event.x <= screenW/2 then
		--transition.to(spaceShipSprite,{x=event.x,y=event.y, time=500})
		--else if event.x >= screenW/2 then
		--transition.to(spaceShipSprite,{x=screenW/2,time=500})
		--end
		-- Had other plans with function before but changed mind
		
	
	end
	----------- Make play invulnerable in beginning
	--local function startShip()
	--spaceShipSprite.isBodyActive= false
	--spaceShipSprite.alpha = 0
	--transition.to(spaceShipSprite,{alpha=1,time=1500,
	--onComplete = function() spaceShipSprite.isBodyActive=true
	--				end})
	--end
	
	-- Make function so body can not have as many collisions
	
	local function bodyActivexd()
	self.isBodyActive=true
	end
	
	--------------collision to ship that happens when anything hits it
	local function onCollision(self,event)-- If you are hit by something you explode
	if (event.phase== "began") then
			--print("I was hit") -- Confirm a bunch of collisions are happening
			--spaceShipSprite:removeEventListener("touch",moveShip)
        	spaceShipSprite:setSequence("explode")
			spaceShipSprite:play()
		score = score-1
	end
	if score <= -1000 then 
	score=0
	showMainScene()
	end
	
end
	----------------------------------------
	function createAsteroid()
	newAsteroid=display.newSprite(asteroidSheet,sequenceData)
		newAsteroid:setSequence("asteroid")
		table.insert( asteroidsTable, newAsteroid )--insert into table for easy deletion of object
		sceneGroup:insert(newAsteroid)-- Insert into group so object goes away when you change scenes
		newAsteroid.xScale=.5
		newAsteroid.yScale=.5
		newAsteroid.x=xco
		newAsteroid.y=yco
		physics.addBody(newAsteroid,"dynamic",{shape=asteroidProperties,bounce=0})
		newAsteroid.myName = "asteroidNew"
		newAsteroid.gravityScale= math.random( 1,2)
	
	end
	function createFuel()
	newFuel=display.newSprite(asteroidSheet,sequenceData)
		newFuel:setSequence("fuel")
		table.insert( fuelsTable, newFuel )--insert into table for easy deletion of object
		sceneGroup:insert(newFuel)-- Insert into group so object goes away when you change scenes
		newFuel.xScale=.5
		newFuel.yScale=.5
		newFuel.x=xco
		newFuel.y=yco
		physics.addBody(newFuel,"dynamic",{shape=fuelProperties,bounce=0})
		newFuel.myName = "fuelNew"
	end
	function createPowerUp1()
	newPowerUp1=display.newSprite(powerUpsSheet,sequenceData)
		newPowerUp1:setSequence("powerUp1")
		table.insert( powerZUp1Table, newPowerUp1 )--insert into table for easy deletion of object
		sceneGroup:insert(newPowerUp1)-- Insert into group so object goes away when you change scenes
		newPowerUp1.xScale=.5
		newPowerUp1.yScale=.5
		newPowerUp1.x=xco
		newPowerUp1.y=yco
		physics.addBody(newPowerUp1,"dynamic",{shape=powerUpsProperties,bounce=0})
		newPowerUp1.myName = "powerUp1New"
	
	end
	function createPowerUp2()
	newPowerUp2=display.newSprite(powerUpsSheet,sequenceData)
		newPowerUp2:setSequence("powerUp2")
		table.insert( powerZUp2Table, newPowerUp2 )--insert into table for easy deletion of object
		sceneGroup:insert(newPowerUp2)-- Insert into group so object goes away when you change scenes
		newPowerUp2.xScale=.5
		newPowerUp2.yScale=.5
		newPowerUp2.x=xco
		newPowerUp2.y=yco
		physics.addBody(newPowerUp2,"dynamic",{shape=powerUpsProperties,bounce=0})
		newPowerUp2.myName = "powerUp2New"
	end
	
	
	-- Function controlling the spawns of stuff
	function asteroidCreate(event)
	xco= math.random( -20, screenW-50)
	yco= math.random(screenH/20, screenH/10)
	spawnSprite = math.random(1,1100)
	powerUpPicker=math.random(1,2)
	if spawnSprite < 201 then
		createFuel()
			for i = #fuelsTable, 1, -1 do
			local thisFuel = fuelsTable[i]
 
			if ( thisFuel.x < -100 or
             thisFuel.x > display.contentWidth + 100 or
             thisFuel.y < -100 or
             thisFuel.y > display.contentHeight + 300 )
			then
				display.remove( thisFuel )
				table.remove( fuelsTable, i )
				score = score+20
				scoreText.text = score
				end
			end
		
	elseif spawnSprite < 1001 then
		createAsteroid()
			for i = #asteroidsTable, 1, -1 do
			local thisAsteroid = asteroidsTable[i]
 
			if ( thisAsteroid.x < -100 or
				thisAsteroid.x > display.contentWidth + 100 or
				thisAsteroid.y < -100 or
				thisAsteroid.y > display.contentHeight + 300 )
				then
				display.remove( thisAsteroid )
				table.remove( asteroidsTable, i )
				score = score+10
				scoreText.text = score
				end
			end
		
		
	else if powerUpPicker >1 then
		createPowerUp1()
		for i = #powerZUp1Table, 1, -1 do
			local thisPowerUp1 = powerZUp1Table[i]
 
			if ( thisPowerUp1.x < -100 or
				thisPowerUp1.x > display.contentWidth + 100 or
				thisPowerUp1.y < -100 or
				thisPowerUp1.y > display.contentHeight + 300 )
				then
				display.remove( thisPowerUp1 )
				table.remove( powerZUp1Table, i )
				score = score+30
				scoreText.text = score
				end
			end
	else
		createPowerUp2()
		for i = #powerZUp2Table, 1, -1 do
			local thisPowerUp2 = powerZUp2Table[i]
 
			if ( thisPowerUp2.x < -100 or
				thisPowerUp2.x > display.contentWidth + 100 or
				thisPowerUp2.y < -100 or
				thisPowerUp2.y > display.contentHeight + 300 )
				then
				display.remove( thisPowerUp2 )
				table.remove( powerZUp2Table, i )
				score = score+40
				scoreText.text = score
				end
			end
	
		end
		return true
			
end
	-- MAKE COLLISION EVENT THE myNames for all objects are "spaceShip", "fuelNew","powerUp1New","powerUp2New","asteroidNew"
	spaceShipSprite.collision = onCollision-- If ship is hit then you lose points
 	spaceShipSprite:addEventListener("collision",spaceShipSprite)
		
		
		
end
	

	
-------------------------------------------------------------------------------------------------------------------------
	
	
	-- all display objects must be inserted into group
	--sceneGroup:insert(floorObject)
	sceneGroup:insert( background)
	sceneGroup:insert( background2)
	sceneGroup:insert( background3)
	sceneGroup:insert(spaceShipSprite)
	sceneGroup:insert(scoreText)
	
	--sceneGroup:insert(powerUpsSprite)
	--sceneGroup:insert(asteroidSprite)
	--sceneGroup:insert(fuelSprite)
	-- Made these comments because they are not created until after the game screen starts
end


function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
	-- Spaceship object declared
	
		-- Called when the scene is still off screen and is about to move on screen
		physics.start()
		if score < 0 then-- reset score after death
		score = 0
		scoreText.text = 0
		end
		spaceShipSprite.x= 0+50
		spaceShipSprite.y=screenH/2
		spaceShipSprite:setSequence("moveShipxd")-- Make sure sprite is on right animation if user dies and restarts game
		spaceShipSprite:setFillColor(1)-- Reset Fill Color to Normal
		spaceShipSprite:pause()-- pauses animation
		
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
		physics.start()
		Runtime:addEventListener("touch",moveShip)
		--timer.performWithDelay( 100,startShip, 0 )
		timer1 = timer.performWithDelay( 300, asteroidCreate, 0 )
		
		
	
		audio.play(backgroundMusic,{loops=-1})
		
	end
end

function scene:hide( event )
	local sceneGroup = self.view
	
	local phase = event.phase
	
	if event.phase == "will" then
		-- Called when the scene is on screen and is about to move off screen
		--
		-- INSERT code here to pause the scene
		-- e.g. stop timers, stop animation, unload sounds, etc.)
		physics.pause()
		timer.pause(timer1)
		audio.stop(1)
		
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
	
end

function scene:destroy( event )

	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	local sceneGroup = self.view
	
	package.loaded[physics] = nil
	physics = nil
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene