function room_main()
	return function(room)

		room.onCreate = function(args)
			m.game_started = false
			m.ball_spawn_timer = CreateObject("roTimespan")
			m.ball_direction = -1
			m.ball = invalid
		end function

		room.onUpdate = function(dt)
			if m.game_started and m.ball = invalid and m.ball_spawn_timer.TotalMilliseconds() > 1000
				m.ball = m.gameEngine.createInstance("ball", {direction: m.ball_direction})
			end if
		end function

		room.onDrawBegin = function(frame)
			frame.DrawRect(0, 0, 1280, 50, &hFFFFFFFF)
			frame.DrawRect(0, 720-50, 1280, 50, &hFFFFFFFF)
			if not m.game_started then
				frame.DrawText("Press OK To Play", 640-m.gameEngine.getFont("default").GetOneLineWidth("Press OK To Play", 1000)/2, 720/2, &hFFFFFFFF, m.gameEngine.getFont("default"))
			end if
		end function

		room.onButton = function(button)
			if not m.game_started and button = 6 then
				m.game_started = true
			end if
		end function

	end function
end function