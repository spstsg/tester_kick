- Add login/signup with Apple
<!-- - A page with different users best eleven
  - Users should be able to comment and like -->
- Moderator should be able to mute everyone at once
- make sure only admin sees the create poll page. Right now it is on the home page appbar.
<!-- - Take a look at agora setAudioProfile method if you can use it -->
- Invite to audio chat
- Find a way to know which of your contacts have kickchat installed

- Dynamic links
* In other for dynamic links to work on IOS, make sure you enable "Associated domains" under identifiers on apple developer account.
* Any profile associated with the identifier that you are enabling the associated domains, will become invalid. You will have to create a new profile.
* Open project on xcode and add a new url type with $(PRODUCT_BUNDLE_IDENTIFIER) as url schemes
* Go to signing & capabilities and add associated domains. Make sure you have the correct provisioning profile
* Add your firebase link to the domain section of the associated domain capability
  - It has to be in the format: applinks:<firebase-dynamic-link>

- For upcoming audio room chat
  - when it gets to the time, notify the creator and other users
  - the creator has to click a start button to start the room - done
  - if the start time has passed and room has not been started, show a message that says "room was due to start x minutes ago"
  - if creator has not started room, notify them that it will be ended in x minutes.

<!-- - Send verification code to email on signup -->
<!-- - After sharing a screenshot, delete from the users device -->
- *Delete livescores chat from database after some days (This will be deleted from the admin dashboard)
- *Add stickers
- *Add dynamic links thats take a user directly to a specific page when the user clicks on a notification
- *Add pagination to posts page
- *Invite friends to the app via facebook, whatsapp, contacts
- *Add video controls to player
- *Consider using topics that users subscribe to send notifications

<!-- - If a user is sending a message to another user for the first time, the page remains in a loading state after the message is sent. -->

WHERE TO ADD NOTIFICATION
- post reaction - done
- post comment - done
- follow user - done
- Send notification when a user share another user's post - done
- Create a page for displaying user's chat notification - done

<!-- - When a user creates a post, notify all his followers
- Send chat
  - Only send push notification if the receiver is not online
  - If the receiver is still on the app but on a different page, use local notification
- Any post related to the teams you are following
- Any audio room related to the team you are following
- * Randomly send notifications to all users to see other users best eleven
- Breaking news
- Voting -->

...........
- The gif select for post create is not working - done
- Work on edit post with video - done
- Display user's added videos on profile page - done
- If a user wants to delete a video, ask them if the want to permanently delete the video or make it private so only them can see it - done
- Change the "flutter/social_network/videos/" storage url used for the video to something better and also for thumbnails - done
- It seems if a video on profile page has hide set to false, the videos are not aligned in the grid properly. Login another user to check this out properly - done
- Remove the create new post button from the post container - done
- If a user wants to delete a video from a post in edit mode, prevent it. Instead show an alert telling the user to delete the entire post and create a new one. They should be able to only edit its text - done
- I have done the chat images delete feature
- I add getRandomString(20) to all Hero tag for image display
- Implemented post reactions
- Implemented password (when logged out) reset and change password (when logged in)
- Implemented video upload
- Add notifications
- Fix cache image issue most espacially the one on the create_post_container - done
- The reactions images are too small - done
- Scroll to bottom for post comments - done
- Try to find out how you users can turn off notifications from settings page - done
- Conversation list sometimes shows duplicate - done
- If I follow a user from the user's profile page, the whole page reloads and sometimes the posts remain in loading state - done
- Fix bottom tab display on different devices - done
- Following number is not properly displayed on friends tab - done
- Change height of video thumbnail - done
- Remove video loop - done
- Don't send notifications to yourself - done
- Look for ways to validate email domain(So users won't use disposable emails). Decide if you need to send verification email (Not perfect but at least emails with domains @me, @test etc can be validated) - done
- Instead of a loading when user is signing up or logging in, add the loader to the button - done
- The back button from audio room to AudioHomeScreen does not work well - done
- Try to see if you can integrate games into flutter app - done
- Display users team on profile page - done
- Create audio room tags and title is always null when i click the create room button - done
- Add polls - done
- All users will see polls that are created - done
- On their profile, they will only see polls they voted on - done
- Add two properties to the polls model - done
  - a date when it will end - done
  - a boolean value called to specify its status - done
- Invite from phone contacts - done


This is the github url for the agora chat 
https://github.com/InolabSF/flutter_voice_chat_using_agora

This is the link for ios device
https://github.com/filsv/iPhoneOSDeviceSupport

https://stackoverflow.com/questions/53630136/using-cocoapods-libraries-in-flutter-ios-platform-specific-code

Audio chat logic
- *Try to see if you can persist the stopwatch timer as long as the room is not ended

.......................................................
* Not needed because i am not using a count down timer
.......................................................
- Make room timer continue from where it is on the creators page. It should not start from begininning every time a user enters the room.
- Show a notification in the room if the time is remaining 5 minutes
- Make the time update automatically when a creator adds more time
- Make the add more button show up immediately the time hits zero


Note
This was added to AppDelegate.swift for IOS in other for flutter_local_notification to work. There is a corresponding code for android. Check the docs.
if #available(iOS 10.0, *) {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
}

TEMPORAL FIX FOR AGORA IOS SDK ISSUE
- Change platform version inside Podfile to something higher than 8
- Add after flutter_additional_ios_build_settings(target) in the Podfile
  target.build_configurations.each do |config|
    config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = 'i386 arm64'
  end
- Go into ios folder and delete Podfile.lock
- Go to the root folder and run
  - flutter clean
  - flutter pub get