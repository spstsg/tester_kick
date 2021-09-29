- Add login/signup with Apple
- Look for ways to validate email domain(So users won't use disposable emails). Decide if you need to send verification email.
- After sharing a screenshot, delete from the users device
- *Delete livescores chat from database after some days (This will be deleted from the admin dashboard)
- *Add stickers
- *Add notifications
- *Add pagination to posts page
- *Invite friends to the app via facebook, whatsapp, contacts

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


This is the github url for the agora chat 
https://github.com/InolabSF/flutter_voice_chat_using_agora

This is the link for ios device
https://github.com/filsv/iPhoneOSDeviceSupport

Audio chat logic
- *Try to see if you can persist the stopwatch timer as long as the room is not ended

.......................................................
* Not needed because i am not using a count down timer
.......................................................
- Make room timer continue from where it is on the creators page. It should not start from begininning every time a user enters the room.
- Show a notification in the room if the time is remaining 5 minutes
- Make the time update automatically when a creator adds more time
- Make the add more button show up immediately the time hits zero