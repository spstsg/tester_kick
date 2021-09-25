- Add login/signup with Apple
- Add video upload
- Look for ways to validate email domain(So users won't use disposable emails). Decide if you need to send verification email.
- *Delete livescores chat from database after some days (This will be deleted from the admin dashboard)
- *Add stickers
- *Add notifications
- *Add pagination to posts page
- *Invite friends to the app via facebook, whatsapp, contacts

- File picker has issue on simulator. If i pick N files, it only selects N - 1 files. (Check this on a real device)

...........
- I have done the chat images delete feature
- I add getRandomString(20) to all Hero tag for image display
- Implemented post reactions
- Implemented password (when logged out) reset and change password (when logged in)


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