# `TruexAdRenderer` + Roku Game: Example Integration
1. Demonstrates integrating the `TruexAdRenderer` Roku SDK into a Roku game app
    1. [Read more about integrating with `TruexAdRenderer` on Roku](https://github.com/socialvibe/truex-roku-integrations)
1. This app demonstrates integrating true[X] into a [`BrightScript`](https://developer.roku.com/docs/references/brightscript/language/brightscript-language-reference.md) powered app
    1. Whereas the standard true[X] integration assumes it's running in a [`BrightScript`](https://developer.roku.com/docs/references/brightscript/language/brightscript-language-reference.md) + [`SceneGraph`](https://developer.roku.com/docs/developer-program/core-concepts/core-concepts.md) application
    2. This example app uses pure `BrightScript` logic to check if ads are available 
    3. _Only if there are ads available_, it loads the full `TruexAdRenderer` library ( `BrightScript` + `SceneGraph`) to display the retrieved ad
1. The app leverages the open source [Roku-gameEngine](https://github.com/Romans-I-XVI/Roku-gameEngine) framework to power its game logic

## In Your Own App

Add this code snippet before the ["standard" true[X] flow to render and display an ad](https://github.com/socialvibe/truex-roku-integrations/blob/develop/DOCS.md#init):

```brightscript
tmpAdConfigLocation = "tmp:/truexAdResponse.json"
tmpTruexAdRendererBrs = "tmp:/TruexAdRenderer-availability-v1.brs"
httpRequest = createObject("roUrlTransfer")
httpRequest.SetUrl("https://ctv.truex.com/roku/v1/release/TruexAdRenderer-availability-v1.brs")
httpRequest.SetCertificatesFile("common:/certs/ca-bundle.crt")
httpRequest.GetToFile(tmpTruexAdRendererBrs)
hasTruexAd = Run(tmpTruexAdRendererBrs, adPayload, tmpAdConfigLocation)

if (hasTruexAd <> true) then return false
```

## Setup

1. After cloning this repo, be sure to run `git submodule update --init --recursive` to also pull the code for the `Roku-gameEngine`
1. `cd channel`
1. Ensure your Roku device is [enabled for development](https://developer.roku.com/docs/developer-program/getting-started/developer-setup.md)
    1. Take note of your devices IP's address (`ROKU_DEV_TARGET`) and the `DEVPASSWORD` you set when you enabled developer mode

1. `./configure.sh`
    1. This should allow you to set the `ROKU_DEV_TARGET` and `DEVPASSWORD` environment variables
1. `make install`
1. The example app should now be installed on your Roku device
