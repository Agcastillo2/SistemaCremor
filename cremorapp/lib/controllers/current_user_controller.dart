import '../models/user_model.dart';

class CurrentUserController {
  static UserModel? _currentUser;

  static void setCurrentUser(UserModel user) {
    _currentUser = user;
  }

  static UserModel? get currentUser => _currentUser;

  static void clearCurrentUser() {
    _currentUser = null;
  }
}
