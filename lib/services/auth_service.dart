import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:googleapis/drive/v3.dart' as drive;

class AuthService {
  GoogleSignInAccount? _currentUser;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }
  }

  static bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    await _ensureInitialized();

    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate(
      scopeHint: [
        drive.DriveApi.driveFileScope,
      ],
    );
    _currentUser = googleUser;

    final googleAuth = googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final userCredential =
        await _firebaseAuth.signInWithCredential(credential);

    return userCredential;
  }

  Future<drive.DriveApi?> getDriveApi() async {
    await _ensureInitialized();
    final account = _currentUser;
    if (account == null) {
      // Try lightweight auth first
      final result = await attemptLightweightSignIn();
      if (!result) return null;
    }

    final user = _currentUser;
    if (user == null) return null;

    final clientAuthorization =
        await user.authorizationClient.authorizeScopes(
      [drive.DriveApi.driveFileScope],
    );

    final authClient = clientAuthorization.authClient(
      scopes: [drive.DriveApi.driveFileScope],
    );

    return drive.DriveApi(authClient);
  }

  Future<bool> attemptLightweightSignIn() async {
    await _ensureInitialized();
    try {
      final googleUser =
          await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (googleUser == null) return false;
      _currentUser = googleUser;

      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> silentSignIn() async {
    return attemptLightweightSignIn();
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _firebaseAuth.signOut();
    _currentUser = null;
  }

  User? get currentUser => _firebaseAuth.currentUser;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  GoogleSignInAccount? get googleAccount => _currentUser;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
}
