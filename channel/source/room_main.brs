function room_main(object)

	object.onCreate = function(args)
		m.game.createInstance("pause_handler")
		m.game.createInstance("score_handler")
		m.game.createInstance("player")
		m.game.createInstance("computer")
		m.game_started = false
		m.ball_spawn_timer = CreateObject("roTimespan")
		m.ball_direction = -1
		m.ball = invalid

		m.message = "Press OK To Play"
		m.truexCredit = false
	end function

	object.onUpdate = function(dt)
		if m.game_started and m.ball = invalid and m.ball_spawn_timer.TotalMilliseconds() > 1000
			m.ball = m.game.createInstance("ball", {direction: m.ball_direction})
		end if
	end function

	object.onDrawBegin = function(canvas)
		canvas.DrawRect(0, 0, 1280, 50, &hFFFFFFFF)
		canvas.DrawRect(0, 720-50, 1280, 50, &hFFFFFFFF)
		if not m.game_started then
			DrawText(canvas, m.message, canvas.GetWidth()/2, canvas.GetHeight()/2-20, m.game.getFont("default"), "center")
		end if
	end function

	object.onButton = function(button)
		if button = 0 then
			m.game.End()
		end if
		if not m.game_started and button = 6 then
			' This should adPayload come from your ad server
			adPayload = {
				"vast_config_url": "get.truex.com/74fca63c733f098340b0a70489035d683024440d/vast/config?asnw=&cpx_url=&dimension_2=0&flag=%2Bamcb%2Bemcr%2Bslcb%2Bvicb%2Baeti-exvt&fw_key_values=&metr=0&network_user_id=dc0fe879-8168-5069-b77d-82886f75afb1&prof=g_as3_truex&ptgt=a&pvrn=&resp=vmap1&slid=fw_truex&ssnw=&vdur=&vprn="
			}
			truexStarted = m.startTruexAd(adPayload)
			if truexStarted and m.truexCredit then 
				m.game_started = true
			else 
				m.message = "Press OK To Interact With The AD To Play"
			end if
		end if
	end function

	object.onGameEvent = function(event as string, data as object)
		if event = "score"
			if data.team = 0
				m.ball_direction = -1
			else
				m.ball_direction = 1
			end if
			m.ball = invalid
			m.ball_spawn_timer.Mark()
		end if
	end function

	'------------------------------------------------------------------------------------------------
	' Start TruexAdRenderer with adPayload
	'
	' This function will create the TruexAdRendererScene scene graph and run the TrueX expericence from there
	'
	' Params:
	'   * eventType as String - contains the TruexAdRenderer event
	'------------------------------------------------------------------------------------------------
	object.startTruexAd = function(adPayload) as Boolean
		tmpAdConfigLocation = "tmp:/truexAdResponse.json"
		tmpTruexAdRendererBrs = "tmp:/TruexAdRenderer-availability-v1.brs"
		httpRequest = createObject("roUrlTransfer")
		httpRequest.SetUrl("https://ctv.truex.com/roku/v1/release/TruexAdRenderer-availability-v1.brs")
		httpRequest.SetCertificatesFile("common:/certs/ca-bundle.crt")
		httpRequest.GetToFile(tmpTruexAdRendererBrs)
		hasTruexAd = Run(tmpTruexAdRendererBrs, adPayload, tmpAdConfigLocation)

		if (hasTruexAd <> true) then return false
		adPayload["vast_config_url"] = tmpAdConfigLocation
	
		' Start the TruexAdRenderer SceneGraph Wrapper
		screen = CreateObject("roSGScreen")
		m.port = CreateObject("roMessagePort")
		screen.setMessagePort(m.port)
		m.scene = screen.CreateScene("TruexAdRendererScene")
		screen.show()
		m.scene.observeField("truexEvent", m.port)
		slotType = "preroll"
		m.scene.truexInitSettings = {
			type: "init",
			adParameters: adPayload,
			supportsUserCancelStream: true, ' enables cancelStream event types, disable if Channel does not support
			slotType: slotType,
			logLevel: 1, ' Optional parameter, set the verbosity of true[X] logging, from 0 (mute) to 5 (verbose), defaults to 5
			channelWidth: 1920, ' Optional parameter, set the width in pixels of the channel's interface, defaults to 1920
			channelHeight: 1080 ' Optional parameter, set the height in pixels of the channel's interface, defaults to 1080
		}
	
		m.truexActive = true
		while(m.truexActive)
			msg = wait(0, m.port)
			msgType = type(msg)
			if msgType = "roSGNodeEvent"
				if msg.getField() = "truexEvent" then
					m.onTruexEvent(msg.getData())
				end if
			end if
			if msgType = "roSGScreenEvent"
				if msg.isScreenClosed() then 
					m.truexActive = false
				end if
			end if
		end while
		return true
	end function

	
	'------------------------------------------------------------------------------------------------
	' Callback triggered when TruexAdRenderer updates its 'event' field.
	'
	' The following event types are supported:
	'   * adFreePod - user has met engagement requirements, skips past remaining pod ads
	'   * adStarted - user has started their ad engagement
	'   * adFetchCompleted - TruexAdRenderer received ad fetch response
	'   * optOut - user has opted out of true[X] engagement, show standard ads
	'   * optIn - this event is triggered when a user decides opt-in to the true[X] interactive ad
	'   * adCompleted - user has finished the true[X] engagement, resume the video stream
	'   * adError - TruexAdRenderer encountered an error presenting the ad, resume with standard ads
	'   * noAdsAvailable - TruexAdRenderer has no ads ready to present, resume with standard ads
	'   * userCancel - This event will fire when a user backs out of the true[X] interactive ad unit after having opted in.
	'   * userCancelStream - user has requested the video stream be stopped
	'
	' Params:
	'   * eventType as String - contains the TruexAdRenderer event
	'------------------------------------------------------------------------------------------------
	object.onTruexEvent = function(eventType as String)
	  ? "TRUE[X] >>> ContentFlow::onTruexEvent()"
	
	  if eventType = "adFreePod" then
		m.truexCredit = true
	  else if eventType = "adStarted" then
	      ' this event is triggered when the true[X] Choice Card is presented to the user
	  else if eventType = "adFetchCompleted" then
	      ' this event is triggered when TruexAdRenderer receives a response to an ad fetch request
	  else if eventType = "optOut" then
	      ' this event is triggered when a user decides not to view a true[X] interactive ad
	      ' that means the user was presented with a Choice Card and opted to watch standard video ads
	  else if eventType = "optIn" then
	      ' this event is triggered when a user decides opt-in to the true[X] interactive ad
	  else if eventType = "adCompleted" then
	      ' this event is triggered when TruexAdRenderer is done presenting the ad
	      ' if the user earned credit (via "adFreePod") their content will already be seeked past the ad break
	      ' if the user has not earned credit their content will resume at the beginning of the ad break
	      m.truexActive = false
		  ' if (not m.truexCredit) then playLinearAds()
	  else if eventType = "adError" then
	      ' this event is triggered whenever TruexAdRenderer encounters an error
	      ' usually this means the video stream should continue with normal video ads
	      m.truexActive = false
		  ' playLinearAds()
	  else if eventType = "noAdsAvailable" then
	      ' this event is triggered when TruexAdRenderer receives no usable true[X] ad in the ad fetch response
	      ' usually this means the video stream should continue with normal video ads
	      m.truexActive = false
		  ' playLinearAds()
	  else if eventType = "userCancel" then
	      ' This event will fire when a user backs out of the true[X] interactive ad unit after having opted in. 
	  else if eventType = "userCancelStream" then
	      ' this event is triggered when the user performs an action interpreted as a request to end the video playback
	      ' this event can be disabled by adding supportsUserCancelStream=false to the TruexAdRenderer init payload
	      ' there are two circumstances where this occurs:
	      '   1. The user was presented with a Choice Card and presses Back
	      '   2. The user has earned an adFreePod and presses Back to exit engagement instead of Watch Your Show button
	      ? "TRUE[X] >>> ContentFlow::onTruexEvent() - user requested video stream playback cancel..."
		  m.truexActive = false 
	  end if
	end function
end function