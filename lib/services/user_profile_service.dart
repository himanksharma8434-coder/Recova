import 'package:shared_preferences/shared_preferences.dart';

/// User profile representing baseline demographic & anthropometric attributes.
class UserProfile {
  final int? age;
  final String? gender; // 'male' | 'female'
  final double? heightCm;
  final double? weightKg;
  final double? waistCircumferenceCm;
  final double? hipCircumferenceCm;
  final String? smokingStatus;
  final int? stressLevel;

  const UserProfile({
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.waistCircumferenceCm,
    this.hipCircumferenceCm,
    this.smokingStatus,
    this.stressLevel,
  });

  bool get hasRequiredForBodyAge => age != null && age! >= 18;

  bool get isComplete =>
      age != null && gender != null && heightCm != null && weightKg != null;

  UserProfile copyWith({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    double? waistCircumferenceCm,
    double? hipCircumferenceCm,
    String? smokingStatus,
    int? stressLevel,
  }) {
    return UserProfile(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      waistCircumferenceCm: waistCircumferenceCm ?? this.waistCircumferenceCm,
      hipCircumferenceCm: hipCircumferenceCm ?? this.hipCircumferenceCm,
      smokingStatus: smokingStatus ?? this.smokingStatus,
      stressLevel: stressLevel ?? this.stressLevel,
    );
  }
}

/// Service to persist and retrieve the user's demographic profile.
class UserProfileService {
  static const String _keyAge = 'user_profile_age';
  static const String _keyGender = 'user_profile_gender';
  static const String _keyHeight = 'user_profile_height_cm';
  static const String _keyWeight = 'user_profile_weight_kg';

  static const String _keyWaist = 'user_profile_waist_cm';
  static const String _keyHip = 'user_profile_hip_cm';
  static const String _keySmoking = 'user_profile_smoking';
  static const String _keyStress = 'user_profile_stress';

  /// Load the user profile from local storage.
  static Future<UserProfile> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final age = prefs.getInt(_keyAge);
    final gender = prefs.getString(_keyGender);
    final height = prefs.getDouble(_keyHeight);
    final weight = prefs.getDouble(_keyWeight);
    final waist = prefs.getDouble(_keyWaist);
    final hip = prefs.getDouble(_keyHip);
    final smoking = prefs.getString(_keySmoking);
    final stress = prefs.getInt(_keyStress);

    return UserProfile(
      age: age,
      gender: gender,
      heightCm: height,
      weightKg: weight,
      waistCircumferenceCm: waist,
      hipCircumferenceCm: hip,
      smokingStatus: smoking,
      stressLevel: stress,
    );
  }

  /// Save the user profile to local storage.
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();

    if (profile.age != null) {
      await prefs.setInt(_keyAge, profile.age!);
    } else {
      await prefs.remove(_keyAge);
    }

    if (profile.gender != null) {
      await prefs.setString(_keyGender, profile.gender!);
    } else {
      await prefs.remove(_keyGender);
    }

    if (profile.heightCm != null) {
      await prefs.setDouble(_keyHeight, profile.heightCm!);
    } else {
      await prefs.remove(_keyHeight);
    }

    if (profile.weightKg != null) {
      await prefs.setDouble(_keyWeight, profile.weightKg!);
    } else {
      await prefs.remove(_keyWeight);
    }
    
    if (profile.waistCircumferenceCm != null) {
      await prefs.setDouble(_keyWaist, profile.waistCircumferenceCm!);
    } else {
      await prefs.remove(_keyWaist);
    }
    
    if (profile.hipCircumferenceCm != null) {
      await prefs.setDouble(_keyHip, profile.hipCircumferenceCm!);
    } else {
      await prefs.remove(_keyHip);
    }
    
    if (profile.smokingStatus != null) {
      await prefs.setString(_keySmoking, profile.smokingStatus!);
    } else {
      await prefs.remove(_keySmoking);
    }
    
    if (profile.stressLevel != null) {
      await prefs.setInt(_keyStress, profile.stressLevel!);
    } else {
      await prefs.remove(_keyStress);
    }
  }
}
