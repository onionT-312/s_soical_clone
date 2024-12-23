// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(username) => "Hello ${username}";

  static String m1(minLength) =>
      "The password must be longer than ${minLength} characters";

  static String m2(time) => "${time} ago";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "accept": MessageLookupByLibrary.simpleMessage("Accept"),
        "already_have_an_account":
            MessageLookupByLibrary.simpleMessage("Already have an account!"),
        "an_error_occur":
            MessageLookupByLibrary.simpleMessage("An error occur"),
        "anonymous": MessageLookupByLibrary.simpleMessage("Anonymous user"),
        "bio": MessageLookupByLibrary.simpleMessage("Bio"),
        "can_not_share_this_post":
            MessageLookupByLibrary.simpleMessage("Can not share this post"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "cancel_request":
            MessageLookupByLibrary.simpleMessage("Cancel request"),
        "cannot_delete_other_user_message":
            MessageLookupByLibrary.simpleMessage(
                "Cannot delete other user message"),
        "change_password":
            MessageLookupByLibrary.simpleMessage("Change password"),
        "change_password_success":
            MessageLookupByLibrary.simpleMessage("Change password success"),
        "close": MessageLookupByLibrary.simpleMessage("Close"),
        "comment": MessageLookupByLibrary.simpleMessage("Comment"),
        "confirm_password":
            MessageLookupByLibrary.simpleMessage("Confirm password"),
        "create_now": MessageLookupByLibrary.simpleMessage("Create now"),
        "dark_theme": MessageLookupByLibrary.simpleMessage("Dark theme"),
        "decline": MessageLookupByLibrary.simpleMessage("Decline"),
        "delete": MessageLookupByLibrary.simpleMessage("Delete"),
        "delete_message":
            MessageLookupByLibrary.simpleMessage("Delete message"),
        "delete_message_confirmation": MessageLookupByLibrary.simpleMessage(
            "Are you sure you want to delete this message?"),
        "do_not_have_account":
            MessageLookupByLibrary.simpleMessage("Don\'t have account?"),
        "edit": MessageLookupByLibrary.simpleMessage("Edit"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "english": MessageLookupByLibrary.simpleMessage("English"),
        "enter_new_password":
            MessageLookupByLibrary.simpleMessage("Enter your new password"),
        "enter_old_password":
            MessageLookupByLibrary.simpleMessage("Enter your old password"),
        "enter_your_email":
            MessageLookupByLibrary.simpleMessage("Enter your email"),
        "enter_your_password":
            MessageLookupByLibrary.simpleMessage("Enter your password"),
        "friends": MessageLookupByLibrary.simpleMessage("Friends"),
        "hello": m0,
        "hello_user": MessageLookupByLibrary.simpleMessage("Hello user"),
        "home": MessageLookupByLibrary.simpleMessage("Home"),
        "invalid_email_format":
            MessageLookupByLibrary.simpleMessage("Invalid email format"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "like": MessageLookupByLibrary.simpleMessage("Like"),
        "login": MessageLookupByLibrary.simpleMessage("Login"),
        "login_now": MessageLookupByLibrary.simpleMessage("Login now"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "mark_all_read":
            MessageLookupByLibrary.simpleMessage("Mark all as Read"),
        "message": MessageLookupByLibrary.simpleMessage("Message"),
        "new_password": MessageLookupByLibrary.simpleMessage("New password"),
        "new_post": MessageLookupByLibrary.simpleMessage("New post"),
        "new_post_box":
            MessageLookupByLibrary.simpleMessage("What\'s on your mind?"),
        "no_comment_yet":
            MessageLookupByLibrary.simpleMessage("No comment yet"),
        "no_email": MessageLookupByLibrary.simpleMessage("No email"),
        "no_image_selected":
            MessageLookupByLibrary.simpleMessage("No image selected"),
        "no_message": MessageLookupByLibrary.simpleMessage("No Message"),
        "no_notifications":
            MessageLookupByLibrary.simpleMessage("No notifications available."),
        "no_post_available":
            MessageLookupByLibrary.simpleMessage("No post a available"),
        "no_title": MessageLookupByLibrary.simpleMessage("No Title"),
        "no_username": MessageLookupByLibrary.simpleMessage("No username"),
        "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
        "old_password": MessageLookupByLibrary.simpleMessage("Old password"),
        "old_password_invalid":
            MessageLookupByLibrary.simpleMessage("Old password invalid"),
        "or": MessageLookupByLibrary.simpleMessage("Or"),
        "password": MessageLookupByLibrary.simpleMessage("Password"),
        "passwords_do_not_match":
            MessageLookupByLibrary.simpleMessage("Passwords do not match"),
        "post": MessageLookupByLibrary.simpleMessage("Post"),
        "post_by": MessageLookupByLibrary.simpleMessage("Post by"),
        "re_enter_password":
            MessageLookupByLibrary.simpleMessage("Re-enter password"),
        "save": MessageLookupByLibrary.simpleMessage("Save"),
        "send": MessageLookupByLibrary.simpleMessage("Send"),
        "send_message": MessageLookupByLibrary.simpleMessage("Send message"),
        "send_request": MessageLookupByLibrary.simpleMessage("Send request"),
        "sent_some_images":
            MessageLookupByLibrary.simpleMessage("sent some images"),
        "settings": MessageLookupByLibrary.simpleMessage("Settings"),
        "share": MessageLookupByLibrary.simpleMessage("Share"),
        "showing_name": MessageLookupByLibrary.simpleMessage("Showing name"),
        "sign_up": MessageLookupByLibrary.simpleMessage("Sign up"),
        "sign_up_success": MessageLookupByLibrary.simpleMessage(
            "Sign up success. Please login"),
        "the_password_must_be_longer_than": m1,
        "time_ago": m2,
        "type_message":
            MessageLookupByLibrary.simpleMessage("Type your message"),
        "unfriend": MessageLookupByLibrary.simpleMessage("Unfriend"),
        "update_avatar_and_other_information":
            MessageLookupByLibrary.simpleMessage(
                "Please update your profile image and others information."),
        "update_information":
            MessageLookupByLibrary.simpleMessage("Update user\'s information"),
        "vietnamese": MessageLookupByLibrary.simpleMessage("Vietnamese"),
        "write_comment":
            MessageLookupByLibrary.simpleMessage("Write a comment ..."),
        "you": MessageLookupByLibrary.simpleMessage("You"),
        "you_sent_some_images":
            MessageLookupByLibrary.simpleMessage("You sent some images")
      };
}
