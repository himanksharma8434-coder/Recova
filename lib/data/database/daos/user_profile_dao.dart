import 'package:drift/drift.dart';

import '../tables/user_profiles.dart';
import '../app_database.dart';

part 'user_profile_dao.g.dart';

@DriftAccessor(tables: [UserProfiles])
class UserProfileDao extends DatabaseAccessor<AppDatabase>
    with _$UserProfileDaoMixin {
  UserProfileDao(super.db);

  /// Upsert profile for the user.
  Future<void> upsertProfile(UserProfilesCompanion profile) async {
    await into(userProfiles).insert(
      profile,
      onConflict: DoUpdate(
        (_) => profile,
        target: [userProfiles.userId],
      ),
    );
  }

  /// Get the active profile.
  Future<UserProfile?> getProfile([String userId = 'local_user']) {
    return (select(userProfiles)..where((p) => p.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Watch active profile for reactive updates.
  Stream<UserProfile?> watchProfile([String userId = 'local_user']) {
    return (select(userProfiles)..where((p) => p.userId.equals(userId)))
        .watchSingleOrNull();
  }
}

