import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kick_chat/colors/color_palette.dart';
import 'package:kick_chat/constants.dart';
import 'package:kick_chat/models/audio_room_model.dart';
import 'package:kick_chat/models/user_model.dart';
import 'package:kick_chat/redux/actions/selected_room_action.dart';
import 'package:kick_chat/redux/actions/user_action.dart';
import 'package:kick_chat/redux/app_state.dart';
import 'package:kick_chat/redux/reducers/app_reducers.dart';
import 'package:kick_chat/services/audio/audio_chat_service.dart';
import 'package:kick_chat/services/dynamic_links/dynamic_link_service.dart';
import 'package:kick_chat/services/helper.dart';
import 'package:kick_chat/services/notifications/handle_notification_service.dart';
// import 'package:kick_chat/services/mock/mock_user_service.dart';
import 'package:kick_chat/services/notifications/notification_service.dart';
import 'package:kick_chat/services/sharedpreferences/shared_preferences_service.dart';
import 'package:kick_chat/services/user/user_service.dart';
import 'package:kick_chat/ui/auth/login/LoginScreen.dart';
import 'package:kick_chat/ui/auth/signup/SignUpScreen.dart';
import 'package:kick_chat/ui/home/nav_screen.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux_dev_tools/redux_dev_tools.dart';

// import 'services/mock/mock_post_service.dart';

HandleNotificationService _handleNotificationService = HandleNotificationService();

void main() async {
  await dotenv.load(fileName: "assets/.env");
  WidgetsFlutterBinding.ensureInitialized();
  // Wait for Firebase to initialize and set `_initialized` state to true
  await Firebase.initializeApp();

  _handleNotificationService.initializeFlutterNotificationPlugin();

  FirebaseMessaging.onBackgroundMessage(_handleNotificationService.backgroundMessageHandler);

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /// this key is used to navigate to the appropriate screen when the
  /// notification is clicked from the system tray
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey(debugLabel: "Main Navigator");
  static User? currentUser;
  static DevToolsStore<AppState>? reduxStore;

  /// a stream to listen for firebase messaging token changes
  late StreamSubscription tokenStream;
  // /// true when firebase has been initialized
  bool _initialized = false;
  // /// true if firebase had an error during initialization
  bool _error = false;
  UserService _userService = UserService();
  AudioChatService _audioChatService = AudioChatService();
  DynamicLinkService _dynamicLinkService = DynamicLinkService();

  @override
  void initState() {
    initializeFlutterFire();
    initDynamicLinks();
    WidgetsBinding.instance?.addObserver(this);
    super.initState();
    // MockPostService _mockPostService = MockPostService();
    // for (int i = 0; i < 60; i++) {
    //   _mockPostService.generatePosts();
    // }
  }

  @override
  void dispose() {
    /// cancel the stream to avoid memory leaks
    tokenStream.cancel();
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    SharedPreferencesService _sharedPreferences = SharedPreferencesService();
    String roomCreatorId = await _sharedPreferences.getSharedPreferencesString('roomCreatorId');
    String selectedRoomId = await _sharedPreferences.getSharedPreferencesString('roomId');

    if (roomCreatorId.isNotEmpty && selectedRoomId.isNotEmpty && roomCreatorId != MyAppState.currentUser!.userID) {
      _audioChatService.removeSpeaker(selectedRoomId);
      _audioChatService.removeParticipant(
        roomCreatorId,
        selectedRoomId,
      );
      MyAppState.reduxStore!.dispatch(CreateSelectedRoomAction(Room()));
      _sharedPreferences.deleteSharedPreferencesItem('roomId');
      _sharedPreferences.deleteSharedPreferencesItem('roomCreatorId');
    }

    /// if we are logged in, we attempt to update the user online status and
    /// lastSeenTimestamp based on AppLifecycleState state
    if (auth.FirebaseAuth.instance.currentUser != null && currentUser != null) {
      if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
        /// user is offline
        /// pause token stream
        tokenStream.pause();

        /// set active flag to false
        currentUser!.active = false;

        /// update lastOnlineTimestamp field
        currentUser!.lastOnlineTimestamp = Timestamp.now();

        /// update user object in the firestore database to persist changes
        _userService.updateCurrentUser(currentUser!);
      } else if (state == AppLifecycleState.resumed) {
        NotificationSettings settings = await NotificationService.firebaseMessaging.getNotificationSettings();
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          currentUser!.settings.notifications = false;
        } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          currentUser!.settings.notifications = true;
        }

        SharedPreferencesService _sharedPreferences = SharedPreferencesService();
        await _sharedPreferences.setSharedPreferencesBool('notification', currentUser!.settings.notifications);

        /// user is online
        /// resume token stream
        tokenStream.resume();

        /// set active flag to true
        currentUser!.active = true;

        MyAppState.reduxStore!.dispatch(currentUser);

        /// update user object in the firestore database to persist changes
        _userService.updateCurrentUser(currentUser!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {}

    /// Show a loader until FlutterFire is initialized
    if (!_initialized) {
      return Container(
        color: Colors.white,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final store = DevToolsStore<AppState>(appStateReducer, initialState: AppState.initialState());
    MyAppState.reduxStore = store;

    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'KickChat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: ColorPalette.white,
        ),
        home: OnBoarding(),
      ),
    );
  }

  /// we attempt to initialize firebase app
  void initializeFlutterFire() async {
    try {
      await _handleNotificationService.listenForNotifications(navigatorKey);

      /// listen to firebase token changes and update the user object in the
      /// database with it's new token
      tokenStream = NotificationService.firebaseMessaging.onTokenRefresh.listen((event) {
        if (currentUser != null) {
          currentUser!.fcmToken = event;
          _userService.updateCurrentUser(currentUser!);
        }
      });
      setState(() {
        _initialized = true;
      });
    } catch (e) {
      /// Set `_error` state to true if Firebase initialization fails
      setState(() {
        _error = true;
      });
    }
  }

  initDynamicLinks() async {
    await _dynamicLinkService.handleDynamicLink();
  }
}

class OnBoarding extends StatefulWidget {
  @override
  State createState() {
    return OnBoardingState();
  }
}

class OnBoardingState extends State<OnBoarding> {
  UserService _userService = UserService();

  @override
  void initState() {
    super.initState();

    /// check which screen should the user navigate to
    hasFinishedOnBoarding();
  }

  @override
  Widget build(BuildContext context) {
    /// this is a placeholder widget that has a spinning indicator while we
    /// determine which screens should the user navigate to
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.5,
          image: AssetImage('assets/images/splash.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future hasFinishedOnBoarding() async {
    /// first we check if the user has seen the onBoarding screen or not
    SharedPreferencesService _sharedPreferences = SharedPreferencesService();
    bool finishedOnBoarding = await _sharedPreferences.getSharedPreferencesBool(FINISHED_ON_BOARDING);

    // MockUserService _mockUserService = MockUserService();
    // for (int i = 0; i < 25; i++) {
    //   _mockUserService.generateUsers();
    // }

    if (finishedOnBoarding) {
      /// user saw onBoarding, now we check if the user is logged into
      /// firebase or not
      auth.User? firebaseUser = auth.FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        /// we try to retrieve the user object from the database
        User? user = await _userService.getCurrentUser(firebaseUser.uid);
        if (user != null) {
          /// user is logged in already
          /// we set the active flag to true
          user.active = true;

          /// update the user object in the database to persist changes
          await _userService.updateCurrentUser(user);

          /// set the current user to this newly retrieved user object
          MyAppState.currentUser = user;

          /// we navigate to the ContainerScreen of the app, this screen
          /// has a navigation drawer that can navigate you to various
          /// screens inside the app
          MyAppState.reduxStore!.dispatch(CreateUserAction(user));
          pushReplacement(context, new NavScreen());
        } else {
          /// user isn't logged in, authentication is required
          /// We navigate to the authentication screen, we only navigate to
          /// this screen if the user is not logged in so we ask them either
          /// to login or sign up for a new user
          pushReplacement(context, new LoginScreen());
        }
      } else {
        /// user isn't logged in, authentication is required
        /// We navigate to the authentication screen, we only navigate to
        /// this screen if the user is not logged in so we ask them either
        /// to login or sign up for a new user
        pushReplacement(context, new LoginScreen());
      }
    } else {
      /// user hasn't seen the onBoarding screen yet, we navigate to this
      /// screen one time only at first installation of the app
      pushReplacement(context, new SignUpScreen());
    }
  }
}
