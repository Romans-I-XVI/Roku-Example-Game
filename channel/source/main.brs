sub Main()
	game = new_game(1280, 720, false, true) ' This initializes the game engine
	game.loadBitmap("ball", "pkg:/sprites/ball.png")
	game.loadBitmap("paddle", "pkg:/sprites/paddle.png")
	game.defineRoom("room_main", room_main)
	game.defineObject("ball", obj_ball)
	game.defineObject("player", obj_player)
	game.defineObject("computer", obj_computer)
	game.defineObject("pause_handler", obj_pause_handler)
	game.changeRoom("room_main")
	game.Play()
end sub