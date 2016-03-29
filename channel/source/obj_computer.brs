function obj_computer()
	return function(object)

		object.onCreate = function()
			m.x = 720-50
			m.y = 360
			m.addColliderRectangle("front", -16, -80, 1, 160)
			m.addColliderRectangle("top", -16, -80, 32, 1)
			m.addColliderRectangle("bottom", -16, 80-1, 32, 1)
			m.addImage(m.gameEngine.getBitmap("paddle"), 0, 0, 16, 80)
		end function

	end function
end function