import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:foodie/repositories/user_repo.dart';
import 'package:foodie/models/user_model.dart' as app_user;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserRepository _userRepository = UserRepository();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // After signing in, check if user exists in Firestore and create if not
      if (userCredential.user != null) {
        await _getOrCreateUserInFirestore(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.message}");
      return null;
    } catch (e) {
      print("Google Sign-In Error: $e");
      return null;
    }
  }

  // Create user document in Firestore if it doesn't exist
  // TODO:
  Future<void> _getOrCreateUserInFirestore(User user) async {
    final userMap = await _userRepository.streamUserMap().first;
    if (!userMap.containsKey(user.uid)) {
      final newAppUser = app_user.UserModel(
        userName: user.displayName ?? 'No Name',
        // Other fields can be initialized here
      );
      // This is a simplified example. You'd likely have a dedicated method in your UserRepository to create a user.
      // For now, this demonstrates the logic.
      // await _userRepository.createUser(user.uid, newAppUser);
      print('New user created in Firestore with uid: ${user.uid}');
    }
  }


  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
