function obj_ball()
	return function(object)

		' ################ What we are doing here is modifying the empty object with our ball specific function overrides ###################

		object.onCreate = function()
			m.x = 640
			m.y = 360
			m.dead = false
			m.xspeed = (5.5*60)*m.direction
			if rnd(2) = 1 then : m.yspeed = ((rnd(100)/20)*60)*-1 : else : m.yspeed = (rnd(100)/20)*60 : end if
			m.addColliderRectangle("main_collider", -16, -16, 32, 32)
			m.addImage(m.gameEngine.getBitmap("ball"), 0, 0, 16, 16)
			m.gameEngine.cameraSetFollow(m)
		end function


		' Detect collision with other object
		object.onCollision = function(collider, other_collider, other_object)

			if not m.dead and other_object.name = "player" and other_collider = "front" then
				m.xspeed = Abs(m.xspeed)
			end if

			if not m.dead and other_object.name = "computer" and other_collider = "front" then
				m.xspeed = Abs(m.xspeed)*-1
			end if

			if (other_object.name = "player" or other_object.name = "computer") then
				if other_collider = "top" then
					m.yspeed = Abs(m.yspeed)*-1
				end if
				if other_collider = "bottom" then
					m.yspeed = Abs(m.yspeed)
				end if
			end if

		end function


		' This is run on every frame
		object.onUpdate = function(dt)
			' Handle Movement

			if m.x-16 <= 50 then
			    m.dead = true
			    if m.x <= -100
			    	computer = m.gameEngine.getAllInstances("computer")[0]
			    	computer.score = computer.score+1
			    	m.gameEngine.removeInstance(m.id)
			    end if
			end if

			if m.x+16 >= 1280-50 then
				m.dead = true
			    if m.x >= 720+100
			    	player = m.gameEngine.getAllInstances("player")[0]
			    	player.score = player.score+1
			    	m.gameEngine.removeInstance(m.id)
			    end if
			end if

			if m.y-16 <= 50 then
			    m.yspeed = abs(m.yspeed)
			end if

			if m.y+16 >= 720-50 then
				m.yspeed = abs(m.yspeed)*-1
			end if

		end function

		' This function is called when I get destroyed
		object.onDestroy = function()
			m.gameEngine.currentRoom.ball = invalid
			m.gameEngine.currentRoom.ball_spawn_timer.Mark()
		end function
	end function
end function