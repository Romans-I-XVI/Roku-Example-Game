function obj_computer()
	return function(object)

		object.onCreate = function()
			m.ball = invalid
			m.x = 1280-50
			m.y = 360
			m.score = 0
			m.addColliderRectangle("front", -16, -80, 1, 160)
			m.addColliderRectangle("top", -16, -80, 32, 1)
			m.addColliderRectangle("bottom", -16, 80-1, 32, 1)
			m.addImage(m.gameEngine.getBitmap("paddle"), 0, 0, 16, 80)
		end function

		object.onDrawEnd = function(frame)
			frame.DrawText(m.score.ToStr(), 640-200, 100, &hFFFFFFFF, m.gameEngine.getFont("default"))
		end function

		object.onUpdate = function(dt)
			if m.ball <> invalid and m.ball.xspeed > 0 and m.ball.x < m.x then
				if m.ball.y < m.y-20 then
					if m.y > 50+80 then
						m.y = m.y-3*60*dt
					else
						m.y = 50+80
					end if
				else if m.ball.y > m.y+20 then
					if m.y < 720-50-80
						m.y = m.y+3*60*dt
					else 
						m.y = 720-50-80
					end if
				end if
			end if
		end function

	end function
end function