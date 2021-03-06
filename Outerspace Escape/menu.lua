-----------------------------------------------------------------------------------------
--
-- menu.lua
--
-----------------------------------------------------------------------------------------

local composer = require( "composer" )
local scene = composer.newScene()

-- include Corona's "widget" library
local widget = require "widget"

--------------------------------------------

-- forward declarations and other locals
local playBtn,background,background2,background3
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
local scrollSpeed=2

-- 'onRelease' event listener for playBtn
local function onPlayBtnRelease()
	
	-- go to level1.lua scene
	composer.gotoScene( "level1", "fade", 500 )
	
	return true	-- indicates successful touch
end

function scene:create( event )
	local sceneGroup = self.view

	-- Called when the scene's view does not exist.
	-- 
	-- INSERT code here to initialize the scene
	-- e.g. add display objects to 'sceneGroup', add touch listeners, etc.

	-- display a background image
	--local background = display.newImageRect( "background.jpg", display.actualContentWidth, display.actualContentHeight )
	--background.anchorX = 0
	--background.anchorY = 0
	--background.x = 0 + display.screenOriginX 
	--background.y = 0 + display.screenOriginY
	--^^Default Background
	
	---Created background
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
	-- create/position logo/title image on upper-half of the screen
	local titleLogo = display.newText( "Outerspace Escape", 264, 42,"prstart.ttf",32 )
	titleLogo.x = display.contentCenterX
	titleLogo.y = 100
	titleLogo:setFillColor(.5,.5,.8)
	
	-- create a widget button (which will loads level1.lua on release)
	playBtn = widget.newButton{
		label="Play",
		labelColor = { default={255}, over={128} },
		default="button.png",
		over="button-over.png",
		width=154, height=40,
		onRelease = onPlayBtnRelease	-- event listener function
	}
	playBtn.x = display.contentCenterX
	playBtn.y = display.contentHeight - 125
	
	-- all display objects must be inserted into group
	sceneGroup:insert(background)
	sceneGroup:insert(background2)
	sceneGroup:insert(background3)
	sceneGroup:insert( titleLogo )
	sceneGroup:insert( playBtn )
end

function scene:show( event )
	local sceneGroup = self.view
	local phase = event.phase
	
	if phase == "will" then
		-- Called when the scene is still off screen and is about to move on screen
	elseif phase == "did" then
		-- Called when the scene is now on screen
		-- 
		-- INSERT code here to make the scene come alive
		-- e.g. start timers, begin animation, play audio, etc.
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
	elseif phase == "did" then
		-- Called when the scene is now off screen
	end	
end

function scene:destroy( event )
	local sceneGroup = self.view
	
	-- Called prior to the removal of scene's "view" (sceneGroup)
	-- 
	-- INSERT code here to cleanup the scene
	-- e.g. remove display objects, remove touch listeners, save state, etc.
	
	if playBtn then
		playBtn:removeSelf()	-- widgets must be manually removed
		playBtn = nil
	end
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

-----------------------------------------------------------------------------------------

return scene