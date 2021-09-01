' Copyright (c) 2021 true[X], Inc. All rights reserved.
'----------------------------------------------------------------------------------------------
' TruexAdRendererScene
'----------------------------------------------------------------------------------------------
' This is a Bridge between the BrightScript main logic, and the SceneGraph TruexLibrary.
' Interfaces:
'   * truexInitSettings - the Ad init settings passed in from BrightSript
'   * truexEvent - TrueX Ad Renderer events surface up from the library
'
' Member Variables:
'   * spinner as BusySpinner - used to indicate background work is being done
'   * tarLibrary as ComponentLibrary - used to track the True[X] Component library load status
'   * adRenderer as TruexAdRenderer - instance of the true[X] renderer, used to present true[X] ads
'----------------------------------------------------------------------------------------------

'------------------------------------------------------------------------------------------------------
' Begins True[X] ComponentLibrary loading process, ensures global fields are initialized, and presents
' the LoadingFlow to indicate that a (potentially) long running operation is being performed.
'------------------------------------------------------------------------------------------------------
sub init()
  ? "TRUE[X] >>> TruexAdRendererScene::init()"

  ' listen for Truex library load events
  m.tarLibrary = m.top.findNode("TruexAdRendererLib")
  m.tarLibrary.observeField("loadStatus", "onTruexLibraryLoadStatusChanged")

  ' create/set global fields with Channel dimensions (m.global.channelWidth/channelHeight)
  setChannelWidthHeightFromRootScene()

  ' immediately begin loading the spinner image
  m.spinner = m.top.FindNode("busySpinner")
  m.spinner.poster.uri = m.top.spinnerImageUri
  m.spinner.poster.ObserveField("loadStatus", "onSpinnerLoadStatusChanged")
  centerLayout()

end sub

'---------------------------------------------------------------------------------
' Checks m.spinner's 'loadStatus', updating UI element positions once it's ready.
'---------------------------------------------------------------------------------
sub onSpinnerLoadStatusChanged()
    if m.spinner = invalid then return
    ? "TRUE[X] >>> LoadingFlow::onSpinnerLoadStatusChanged(loadStatus=";m.spinner.poster.loadStatus;")"
    if m.spinner.poster.loadStatus = "ready" or m.spinner.poster.loadStatus = "failed" then centerLayout()
end sub

'--------------------------------------------------------------------------------
' Positions UI text elements in the middle of the screen, below the BusySpinner.
'--------------------------------------------------------------------------------
sub centerLayout()
  ? "TRUE[X] >>> TruexAdRendererScene::centerLayout()"

  ' calculate center position for busy spinner based on the Channel resolution
  ' the bitmap's origin is (0, 0), in order to center it correctly we need to account for its width/height
  ' center = (channelWidth|Height / 2) - (bitmapWidth|Height / 2) = (channelWidth|Height - bitmapWidth|Height) / 2
  centerX = (m.global.channelWidth - m.spinner.poster.bitmapWidth) / 2
  centerY = (m.global.channelHeight - m.spinner.poster.bitmapHeight) / 2
  m.spinner.translation = [ centerX, centerY ]
  m.spinner.visible = true

  pleaseWaitLabel = m.top.FindNode("pleaseWait")
  pleaseWaitLabel.width = m.global.channelWidth
  pleaseWaitLabel.height = m.global.channelHeight
  pleaseWaitLabel.translation = [0, (m.spinner.poster.bitmapHeight / 2) + 62]

  loadingLabel = m.top.FindNode("loadingResources")
  loadingLabel.width = m.global.channelWidth
  loadingLabel.height = m.global.channelHeight
  loadingLabel.translation = [0, (m.spinner.poster.bitmapHeight / 2) + 128]
end sub

'---------------------------------------------------------------------------------
' Callback triggered when the True[X] ComponentLibrary's loadStatus field is set.
'
' Replaces LoadingFlow with DetailsFlow upon success.
'
' Params:
'   * event as roSGNodeEvent - use event.GetData() to get the loadStatus
'---------------------------------------------------------------------------------
sub onTruexLibraryLoadStatusChanged(event as Object)
  ' make sure tarLibrary has been initialized
  if m.tarLibrary = invalid then return
  ? "TRUE[X] >>>  TruexAdRendererScene::onTruexLibraryLoadStatusChanged(loadStatus=";m.tarLibrary.loadStatus;")"

  ' check the library's loadStatus
  if m.tarLibrary.loadStatus = "none" then
      ? "TRUE[X] >>> TruexAdRendererLib is not currently being downloaded"
  else if m.tarLibrary.loadStatus = "loading" then
      ? "TRUE[X] >>> TruexAdRendererLib is currently being downloaded and compiled"
  else if m.tarLibrary.loadStatus = "ready" then
      ? "TRUE[X] >>> TruexAdRendererLib has been loaded successfully!"

      ' Launch the Ad as soon as the Truex library is ready
      launchTruexAd()
  else if m.tarLibrary.loadStatus = "failed" then
      ? "TRUE[X] >>> TruexAdRendererLib failed to load"

      ' Host app should use other ads since the Truex library couldn't be loaded
      m.top.truexEvent = "adError"
  else
      ' should not occur
      ? "TRUE[X] >>> TruexAdRendererLib loadStatus unrecognized, ignoring"
  end if
end sub

'--------------------------------------------------------------------------------------------------------
' Launches the true[X] renderer based on the current ad break as detected by onVideoPositionChange
'--------------------------------------------------------------------------------------------------------
sub launchTruexAd()
  ? "TRUE[X] >>> TruexAdRendererScene::launchTruexAd() - instantiating TruexAdRenderer ComponentLibrary..."

  if m.top.truexInitSettings = invalid or type(m.top.truexInitSettings) <> "roAssociativeArray" then
    m.top.truexEvent = "adError"
    return
  end if

  ' instantiate TruexAdRenderer and register for event updates
  m.adRenderer = m.top.createChild("TruexLibrary:TruexAdRenderer")
  m.adRenderer.observeFieldScoped("event", "onTruexEvent")

  ' use the companion ad data to initialize the true[X] renderer
  tarInitAction = m.top.truexInitSettings
  tarInitAction.type = "init"

  ? "TRUE[X] >>> TruexAdRendererScene::launchTruexAd() - initializing TruexAdRenderer with action=";tarInitAction
  m.adRenderer.action = tarInitAction

  ? "TRUE[X] >>> TruexAdRendererScene::launchTruexAd() - starting TruexAdRenderer..."
  m.adRenderer.action = { type: "start" }
  m.adRenderer.focusable = true
  m.adRenderer.SetFocus(true)
end sub

'------------------------------------------------------------------------------------------------
' Callback triggered when TruexAdRenderer updates its 'event' field.
'------------------------------------------------------------------------------------------------
sub onTruexEvent(event as object)
  ? "TRUE[X] >>> TruexAdRendererScene::onTruexEvent()"

  data = event.getData()
  if data = invalid then return else ? "TRUE[X] >>> TruexAdRendererScene::onTruexEvent(eventData=";data;")"

  ' Passing the TrueX events to the BrightScript to handle
  m.top.truexEvent = data.type
end sub