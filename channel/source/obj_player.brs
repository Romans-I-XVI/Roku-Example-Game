function obj_player()
	return function(object)
	
		object.onCreate = function()
			m.hue = 0
			m.x = 50
			m.y = 360
			m.score = 0
			m.addColliderRectangle("front", 15, -80, 1, 160)
			m.addColliderRectangle("top", -16, -80, 32, 1)
			m.addColliderRectangle("bottom", -16, 80-1, 32, 1)
			m.addImage(m.gameEngine.getBitmap("paddle"), {origin_x: 16, origin_y: 80})
		end function

		object.onDrawEnd = function(frame)
			frame.DrawText(m.score.ToStr(), 640-200, 100, &hFFFFFFFF, m.gameEngine.getFont("default"))
		end function

		object.onUpdate = function(dt)
			if m.y < 50+80
				m.y = 50+80
			end if
			if m.y > 720-50-80
				m.y = 720-50-80
			end if
		end function

		object.onButton = function(button)
			if button = 2 then
				m.yspeed = -3.5*60
			else if button = 102 then
				m.yspeed = 0
			else if button = 3 then
				m.yspeed = 3.5*60
			else if button = 103
				m.yspeed = 0
			end if
		end function

	end function
end function
