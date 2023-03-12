import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

Future<User> signInWithApple() async {
  // Request credential for the currently signed in Apple account.
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    // nonce: nonce;
  );

  print("처음 name : ${appleCredential.givenName}, ${appleCredential.familyName}");

  final fixDisplayNameFromApple = [
    appleCredential.givenName ?? '',
    appleCredential.familyName ?? '',
  ].join(' ').trim();

  // Create an `OAuthCredential` from the credential returned by Apple.
  final oauthCredential = OAuthProvider("apple.com").credential(
    idToken: appleCredential.identityToken,
    accessToken: appleCredential.authorizationCode,
  );

  // Sign in the user with Firebase. If the nonce we generated earlier does
  // not match the nonce in `appleCredential.identityToken`, sign in will fail.
  UserCredential firebaseAuthUser = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  print("profile : ${firebaseAuthUser.additionalUserInfo?.profile}");
  print("username : ${firebaseAuthUser.additionalUserInfo?.username}");
  print("providerId : ${firebaseAuthUser.additionalUserInfo?.providerId}");
  print("credential : ${firebaseAuthUser.credential}");

  if (firebaseAuthUser.user!.displayName == null) {
    await firebaseAuthUser.user!.updateDisplayName(fixDisplayNameFromApple);
    await firebaseAuthUser.user!.reload();
  }

  return firebaseAuthUser.user!;
}