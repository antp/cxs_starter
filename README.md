# CxsStarter

Initial application template for Phoenix LiveView websites.
It represents what I want as a set of defaults when starting a new development.

It has lent on [Patrick Thompson's](https://github.com/pthompson/liveview_tailwind_modal) work with Tailwind, Alpine and LiveView.

This application has been created with:

* Authentication (mix_gen_auth)
* Email (Bamboo)

For testing

* ExMachina
* Faker
* mox
* Mix test watch
* Elogram (screen capture)

It has been refactored to provide a liveview interface to the settings page.

* Add the ability for a user to delete their account.
* Users must confirm their email before signing in.
* If a user does not receive the confirmation email, they can reconfirm by resetting their password.


## Adjusting for your APP

* Delete the .git directory before you start - you will want your own!!!
* Rename the directories to my_app and my_app_web
* Rename CxsStarter => MyApp
* Rename cxs_starter => my_app
* Rename cxs_starter_web => my_app_web
* Update your database settings
  
## Screen capture in tests

1. Run chrome 
* /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --headless --disable-gpu --remote-debugging-port=9222

2. Import
* import Elogram.CaptureScreenshot

2. Capture the screen
* capture_screenshot(view, name: "<my_file>.png")


