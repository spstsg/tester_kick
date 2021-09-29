library constants;

const FINISHED_ON_BOARDING = 'finishedOnBoarding';

/// database table/field names, use constants to avoid spelling mistakes
const USERS = 'users';
const FRIENDSHIP = 'friendships';
const PENDING_FRIENDSHIPS = 'pending_friendships';
const CHANNEL_PARTICIPATION = "channel_participation";
const CHANNELS = "channels";
const CONVERSATION = "conversations";
const THREAD = 'thread';
const BLOCKED = 'blocked';
const BLOCKEDBY = 'blockedBy';
const STORIES = 'socialnetwork_stories';
const FEED = 'social_feeds';
const MAIN_FEED = 'main_feed';
const STORIES_FEED = 'stories_feed';
const POSTS_COMMENTS = 'posts_comments';
const SOCIAL_REACTIONS = 'posts_reactions';
const SOCIAL_POSTS = 'posts';
const SOCIAL_FILES = 'images';
const NOTIFICATIONS = 'notifications';
const SOCIAL_GRAPH = 'social_graph';
const RECEIVED_FRIEND_REQUESTS = 'inbound_users';
const SENT_FRIEND_REQUESTS = 'outbound_users';
const FOLLOWERS = 'followers';
const FOLLOWING = 'following';
const LIVESCORES_CHAT = 'livescores_chat';
const AUDIO_LIVE_ROOMS = 'audio_live_rooms';
const AUDIO_ROOM_CHAT = 'audio_rooms_messages';
const USER_VIDEOS = 'videos';

/// helpful formatting constants
const SECOND_MILLIS = 1000;
const MINUTE_MILLIS = 60 * SECOND_MILLIS;
const HOUR_MILLIS = 60 * MINUTE_MILLIS;

/// an empty avatar url
const DEFAULT_AVATAR_URL = 'https://www.iosapptemplates.com/wp-content/uploads/2019/06/empty-avatar.jpg';

/// google api key, this is required when using google services such as
/// google maps, google places etc...
const GOOGLE_API_KEY = '';
