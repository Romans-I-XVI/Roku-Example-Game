function obj_computer()
	return function(object)

		object.onCreate = function()
			m.ball = invalid
			m.x = 720-50
			m.y = 360
			m.addColliderRectangle("front", -16, -80, 1, 160)
			m.addColliderRectangle("top", -16, -80, 32, 1)
			m.addColliderRectangle("bottom", -16, 80-1, 32, 1)
			m.addImage(m.gameEngine.getBitmap("paddle"), 0, 0, 16, 80)
		end function

		object.onUpdate = function(dt)
			if m.ball <> invalid and m.ball.x > 640 and m.ball.x < m.x then
				if m.ball.y < m.y-20 then
					m.y = m.y-2*60*dt
				else if m.ball.y > m.y+20 then
					m.y = m.y+2*60*dt
				end if
			end if
	end function
end function