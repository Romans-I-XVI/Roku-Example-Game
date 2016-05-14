function obj_pause_handler(object)

	object.onCreate = function(args)
		m.persistent = true
		m.pauseable = false
	end function

	object.onButton = function(button)
		if button = 13
			if not m.game.isPaused()
				m.game.Pause()
			else
				m.game.Resume()
			end if
		end if
	end function

	object.onDrawBegin = function(canvas)
		if m.game.isPaused()
			DrawText(canvas, "Paused", canvas.GetWidth()/2, canvas.GetHeight()/2-20, m.game.getFont("default"), "center")
		end if
	end function
	
end function