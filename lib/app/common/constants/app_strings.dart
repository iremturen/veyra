abstract final class AppStrings {
  AppStrings._();

  static const String appName = 'Veyra';
  static const String notificationChannelName = 'Veyra alerts';
  static const String notificationChannelDescription =
      'Important updates and activity from Veyra.';
  static const String customImageSourceAssertion =
      'Provide either imageUrl or assetPath, not both.';

  static const String onboardingTitleOne = 'Every Moment Tells a Story';
  static const String onboardingDescriptionOne =
      'Capture the little things that make life special.';

  static const String onboardingTitleTwo = 'Find Your People';
  static const String onboardingDescriptionTwo =
      'Connect with friends and discover new perspectives.';

  static const String onboardingWelcomeTitle = 'Welcome to Veyra';
  static const String onboardingWelcomeDescription =
      'Your people. Your moments. Your world.';

  static const String signUp = 'Sign Up';
  static const String signIn = 'Sign In';
  static const String continueWithGoogle = 'Continue with Google';
  static const String continueWithApple = 'Continue with Apple';
  static const String socialSignInDivider = 'OR';
  static const String googleSignInUnavailable =
      'Google sign-in is not configured yet.';
  static const String appleSignInUnavailable =
      'Apple sign-in is not configured yet.';
  static const String createAccount = 'Create your account';
  static const String signUpSubtitle = 'Join Veyra and find your people.';
  static const String welcomeBack = 'Welcome back';
  static const String signInSubtitle = 'Sign in to continue to Veyra.';
  static const String crashlyticsTest = 'Crashlytics Test';
  static const String crashlyticsTestDescription =
      'Use this page to test Firebase Crashlytics reporting.';
  static const String crashApp = 'Crash App';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String forgotPassword = 'Forgot password?';
  static const String resetEmailSent = 'Password reset email sent.';
  static const String verifyYourEmail = 'Verify your email';
  static const String verificationInstructions =
      'We sent a verification link to your email. Verify your address, then sign in to continue.';
  static const String sendVerificationEmail = 'Send verification email';
  static const String verificationEmailSent = 'Verification email sent.';
  static const String checkVerification = 'I have verified my email';
  static const String emailNotVerified =
      'Please verify your email before signing in.';
  static const String loginSuccessful = 'Login Successful';
  static const String logout = 'Log Out';
  static const String settings = 'Settings';
  static const String settingsComingSoon = 'Settings are coming soon.';
  static const String email = 'Email';
  static const String emailHint = 'you@example.com';
  static const String emailRequired = 'Please enter your email address.';
  static const String emailInvalid = 'Enter a valid email address.';
  static const String password = 'Password';
  static const String passwordHint = 'At least 6 characters';
  static const String passwordTooShort =
      'Password must be at least 6 characters.';
  static const String passwordRequired = 'Please enter your password.';
  static const String confirmPassword = 'Confirm password';
  static const String confirmPasswordHint = 'Enter your password again';
  static const String passwordsDoNotMatch = 'Passwords do not match.';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String getStarted = 'Get Started';

  static const String navigationHome = 'Home';
  static const String navigationSearch = 'Search';
  static const String exploreTitle = 'Explore';
  static const String exploreBannerDefaultTitle = 'Discover Your Community';
  static const String exploreNoPosts = 'No posts yet';
  static const String navigationCreate = 'Create';
  static const String navigationNotifications = 'Notifications';
  static const String navigationProfile = 'Profile';
  static const String profileEdit = 'Edit Profile';
  static const String changeProfilePhoto = 'Change Profile Photo';
  static const String uploadingPhoto = 'Uploading photo...';
  static const String username = 'Username';
  static const String profileUsernameUnavailable = 'Not available';
  static const String usernameCannotBeChanged = 'Username cannot be changed.';
  static const String emailCannotBeChanged = 'Email address cannot be changed.';
  static const String bio = 'Bio';
  static const String profileBioHint = 'Tell people a little about yourself';
  static const String saveChanges = 'Save Changes';
  static const String profileSaved = 'Profile updated successfully.';
  static const String profileSaveFailed =
      'Could not save your profile. Please try again.';
  static const String profileDetailsLoadFailed =
      'Could not load your profile. Please try again.';
  static const String profileReadPermissionDenied =
      'Your profile could not be accessed. Check your Firestore permissions and try again.';
  static const String profileWritePermissionDenied =
      'Your profile could not be saved. Check your Firestore permissions and try again.';
  static const String profilePosts = 'Posts';
  static const String profileLikes = 'Likes';
  static const String profileNoPosts = 'No posts yet';
  static const String profileLoadFailed = 'Could not load your posts.';
  static const String profileUnavailable = 'Profile unavailable.';

  static const String feedEmpty =
      'No posts yet. Be the first to share a moment.';
  static const String feedLoadFailed =
      'Could not load posts. Please try again.';
  static const String feedMemberFallback = 'Veyra member';
  static const String newPost = 'New Post';
  static const String createPostSubtitle =
      'Choose a moment you would love to share.';
  static const String selectPhoto = 'Select Photo';
  static const String changePhoto = 'Change Photo';
  static const String choosePhotoHint = 'Your photo goes here';
  static const String optionalCaption = 'Caption (optional)';
  static const String sharePost = 'Share Post';
  static const String postShared = 'Your post was shared.';
  static const String photoSelectFailed =
      'Could not select this photo. Please try again.';
  static const String photoUploadFailed =
      'Could not upload your photo. Please try again.';
  static const String postPublishFailed =
      'Could not share your post. Please try again.';
  static const String postSignInRequired =
      'Please sign in again before sharing a post.';
  static const String postMoreOptions = 'More options';
  static const String postLike = 'Like';
  static const String postComment = 'Comment';
  static const String postShare = 'Share';
  static const String postSave = 'Save';
  static const String downloadImage = 'Download Image';
  static const String downloadingPhoto = 'Downloading image...';
  static const String photoDownloaded = 'Image saved to gallery.';
  static const String photoDownloadFailed =
      'Could not download image. Please try again.';
  static const String photoPermissionDenied =
      'Photo library permission is required to save images.';
  static const String storageFull = 'Not enough storage space on your device.';
  static const String networkError =
      'Network error. Please check your connection.';
  static const String noImageToDownload = 'No image available to download.';
  static const String cancel = 'Cancel';
  static const String comments = 'Comments';
  static const String viewComments = 'View comments';
  static const String addCommentHint = 'Add a comment...';
  static const String postAction = 'Post';
  static const String noCommentsYet = 'No comments yet.';
  static const String beFirstToComment = 'Be the first to share your thoughts.';
  static const String commentsLoadFailed =
      'Could not load comments. Please try again.';
  static const String commentSubmitFailed =
      'Could not post comment. Please try again.';
  static const String commentSignInRequired =
      'Please sign in and verify your email to comment.';
  static const String likesCountSingular = 'like';
  static const String likesCountPlural = 'likes';
  static const String noNotificationsYet = 'No notifications yet';
  static const String noNotificationsSubtitle =
      'When people like or comment on your posts, you will see them here.';
  static const String notificationsLoadFailed =
      'Could not load notifications. Please try again.';
  static const String likedYourPost = 'liked your post.';
  static String commented(String text) => 'commented: "$text"';
  static const String retry = 'Retry';
  static const String justNow = 'Just now';
}
