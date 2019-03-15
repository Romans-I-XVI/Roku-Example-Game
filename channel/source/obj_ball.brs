function obj_ball(object)

	' ################ What we are doing here is modifying the empty object with our ball specific function overrides ###################

	object.onCreate = function(args)
		m.Append(args)
		m.x = 640
		m.y = 360
		m.dead = false
		m.xspeed = (5.5*60)*m.direction
    	m.computer = m.game.getInstanceByName("computer")
    	m.player = m.game.getInstanceByName("player")
		if rnd(2) = 1 then : m.yspeed = 5*60*-1 : else : m.yspeed = 5*60 : end if
		m.addColliderRectangle("main_collider", -16, -16, 32, 32)
		m.addImage(m.game.getBitmap("ball"), {color: &hffffff, origin_x: 16, origin_y: 16, alpha: 0})
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
		room = m.game.getRoom()
		' Handle Movement
		image = m.getImage()
		if image.alpha < 255 then
			image.alpha = image.alpha+3
		end if

		if m.x-16 <= 50 then
		    m.dead = true
		    if m.x <= -100
		    	room.ball_direction = 1
		    	m.computer.score = m.computer.score+1
		    	m.game.destroyInstance(m)
		    	return void
		    end if
		end if

		if m.x+16 >= 1280-50 then
			m.dead = true
		    if m.x >= 1280+100
		    	room.ball_direction = -1
		    	m.player.score = m.player.score+1
		    	m.game.destroyInstance(m)
		    	return void
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
		room = m.game.getRoom()
		room.ball = invalid
		m.computer.ball = invalid
		room.ball_spawn_timer.Mark()
	end function

end function