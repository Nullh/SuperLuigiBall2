time = 0
score = 0
gameover = false
objects = {} -- table to hold objects
world = nil
luigi = nil
bgm = nil
bark = nil
growl = nil
background = nil


function love.load()

	love.graphics.setBackgroundColor(0, 100, 100)
	love.keyboard.setKeyRepeat(true)
	love.window.setMode(650, 650)

	--load our boys
	luigi = love.graphics.newImage('assets/luigi.png')
	background = love.graphics.newImage('assets/jake.png')

	--physics stuff
	love.physics.setMeter(64)
	world = love.physics.newWorld(0, 9.81*64, true)
	world:setCallbacks(beginContact, endContact, preSolve, postSolve)

	--load audio
	bgm = love.audio.newSource('assets/theme.mp3')
	bark = love.audio.newSource('assets/bark.wav', 'static')
	growl = love.audio.newSource('assets/sadluigi.wav', 'static')

	--play the bgm
	bgm:setVolume(0.8)
	bgm:setLooping(true)
	bgm:play()

	--ground
	objects.ground = {}
	objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2)
	objects.ground.shape = love.physics.newRectangleShape(650, 50)
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape)
	objects.ground.fixture:setUserData("Ground")
	-- ball
	objects.ball = {}
	objects.ball.body = love.physics.newBody(world, 650/2, 650/2, "dynamic")
	objects.ball.shape = love.physics.newCircleShape(20)
	objects.ball.fixture = love.physics.newFixture(objects.ball.body, objects.ball.shape,1)
	objects.ball.fixture:setRestitution(0.9)
	objects.ball.fixture:setUserData("Ball")
	--luigi
	objects.luigi = {}
	objects.luigi.body = love.physics.newBody(world, 100, 150, "dynamic")
	objects.luigi.shape = love.physics.newCircleShape(41)
	objects.luigi.fixture = love.physics.newFixture(objects.luigi.body, objects.luigi.shape, 1.5)
	objects.luigi.fixture:setRestitution(0.5)
	objects.luigi.fixture:setUserData("Luigi")
	--ceiling
	objects.ceiling = {}
	objects.ceiling.body = love.physics.newBody(world, 0, 0)
	objects.ceiling.shape = love.physics.newEdgeShape(0, 0, 640, 0)
	objects.ceiling.fixture = love.physics.newFixture(objects.ceiling.body, objects.ceiling.shape)
	objects.ceiling.fixture:setUserData("Ceiling")
	--left wall
	objects.lw = {}
	objects.lw.body = love.physics.newBody(world, 0, 0)
	objects.lw.shape = love.physics.newEdgeShape(0, 0, 0, 640)
	objects.lw.fixture = love.physics.newFixture(objects.lw.body, objects.lw.shape)
	objects.lw.fixture:setUserData("Left Wall")
	--right wall
	objects.rw = {}
	objects.rw.body = love.physics.newBody(world, 0, 0)
	objects.rw.shape = love.physics.newEdgeShape(640, 0, 640, 640)
	objects.rw.fixture = love.physics.newFixture(objects.rw.body, objects.rw.shape)
	objects.rw.fixture:setUserData("Right Wall")
end


function love.keypressed(key, scancode, isrepeat)
	if key == 'r' then
		objects.luigi.body:setPosition(640/2,620/2)
		objects.luigi.body:setLinearVelocity(0, 0)
	end
	if key == "escape" then
	 love.event.quit()
	end
end

function love.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(background,0,0)
	love.graphics.draw(luigi, objects.luigi.body:getX()-50, objects.luigi.body:getY()-40)

	love.graphics.print("ARROWS move. ESC to quit", 0, 0)
	--love.graphics.print(text, 0, 10)

	love.graphics.print("SCORE:", 550, 0, 0, 2, 2)
	love.graphics.print(score, 550, 20, 0, 2)

	love.graphics.print("TIME REMAINING", 300, 0, 0, 2)
	timeremaining = 30 - time
	if timeremaining > 0 then
		love.graphics.print(timeremaining, 300, 20, 0, 2)
	else
		love.graphics.print("0", 300, 20, 0, 2)
	end

	-- The ground
	love.graphics.setColor(72, 160, 14)
	love.graphics.polygon("fill", objects.ground.body:getWorldPoints(objects.ground.shape:getPoints()))

	-- The ball
	love.graphics.setColor(193, 47, 255)
	love.graphics.circle("fill", objects.ball.body:getX(), objects.ball.body:getY(), objects.ball.shape:getRadius())
	love.graphics.setColor(200, 150, 255)
	love.graphics.circle("fill", objects.ball.body:getX()-8, objects.ball.body:getY()-8, objects.ball.shape:getRadius()/5)

	love.graphics.setColor(0, 0, 0)
	love.graphics.print("CATCH THE BALL 25 TIMES IN 30 SECONDS!!!", 40, 615, 0, 2)

	if gameover == true then
		love.graphics.setColor(0, 0, 0, 200)
		love.graphics.rectangle("fill", 0, 0, 650, 650)
		love.graphics.setColor(255, 255, 255)
		love.graphics.print("GAME OVER!", 95, 150, 0, 5)
		love.graphics.print("Your final score was:", 100, 225, 0, 2)
		love.graphics.print(score, 400, 225, 0, 5)
		love.graphics.setColor(200, 200, 255)
		if score < 25 then
			love.graphics.print("You made Luigi sad!", 100, 300, 0, 2)
			growl:play()
		elseif score > 25 and score < 100 then
			love.graphics.print("Luigi is happy!!", 100, 300, 0, 2)
		elseif score >= 100 then
			love.graphics.print("Luigi drank his own wee in excitement!", 100, 300, 0, 2)
		end
		love.graphics.setColor(200, 200, 255)
		love.graphics.print("Press ESC to quit...", 10, 630)
	end

end

function love.update(dt)

	time = time + dt

	if time < 30 then
		-- Run physics
		world:update(dt)

		-- Grab scancodes for the movement keys
		if love.keyboard.isScancodeDown('right') then
			objects.luigi.body:applyLinearImpulse(400,0)
		end
		if love.keyboard.isScancodeDown('left') then
			objects.luigi.body:applyLinearImpulse(-400,0)
		end
		if love.keyboard.isScancodeDown('up') then
			objects.luigi.body:applyLinearImpulse(0,-200)
		end
		if love.keyboard.isScancodeDown('down') then
			objects.luigi.body:applyLinearImpulse(0,200)
		end
		if love.keyboard.isScancodeDown('q') then
			time = 30
		end
		if love.keyboard.isScancodeDown('w') then
			score = score + 25
		end
	else
		gameover = true
	end

	--if string.len(text) > 768 then
	--	text = ""
	--end

end

function beginContact(a, b, coll)
	--x, y = coll:getNormal()
	--text = text.."\n"..a:getUserData().." colliding with "..b:getUserData().." with a vector normal of "..x..", "..y
	if a:getUserData() == "Ball" and b:getUserData() == "Luigi"
	or a:getUserData() == "Luigi" and b:getUserData() == "Ball"	then
		score = score + 1
		bark:play()
	end
end

function endContact(a, b, coll)

end

function preSolve(a, b, coll)

end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)

end
