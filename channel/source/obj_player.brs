function obj_player()
	return function(object)
	
		object.onCreate = function()
			m.x = 50
			m.y = 360
			m.addColliderRectangle("front", 15, -80, 1, 160)
			m.addColliderRectangle("top", -16, -80, 32, 1)
			m.addColliderRectangle("bottom", -16, 80-1, 32, 1)
			m.addImage(m.gameEngine.getBitmap("paddle"), 0, 0, 16, 80)
		end function

		object.onButton = function(button)
			if button = 2 or button = 1002 then
				if m.y > 50+80
					m.y = m.y - 5
				else
					m.y = 50+80
				end if
			end if
			if button = 3 or button = 1003 then
				if m.y < 720-50-80
					m.y = m.y + 5
				else
					m.y = 720-50-80
				end if
			end if
		end function

	end function
end function
