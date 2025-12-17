import 'package:audiobooks/core/error/failures.dart';
import 'package:audiobooks/domain/entities/user_entity.dart';
import 'package:audiobooks/domain/entities/user_profile_entity.dart';
import 'package:audiobooks/domain/usecases/get_user_profile_usecase.dart';
import 'package:audiobooks/domain/usecases/google_sign_in_usecase.dart';
import 'package:audiobooks/domain/usecases/google_sign_out_usecase.dart';
import 'package:audiobooks/domain/usecases/update_user_profile_usecase.dart';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final GoogleSignInUseCase _googleSignInUseCase;
  final GoogleSignOutUseCase _googleSignOutUseCase;
  final GetUserProfileUsecase _getUserProfileUsecase;
  final UpdateUserProfileUsecase _updateUserProfileUsecase;
  AuthCubit(
    this._googleSignInUseCase,
    this._googleSignOutUseCase,
    this._getUserProfileUsecase,
    this._updateUserProfileUsecase,
  ) : super(AuthInitial()) {
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        print(
          '--- Supabase AuthStateChange: User is signed in. Fetching profile... ---',
        );
        // Khi có session, fetch profile
        _fetchProfileAndAuthenticate(session.user);
      } else {
        print('--- Supabase AuthStateChange: User is signed out. ---');
        // Khi không có session, emit unauthenticated
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> googleSignInRequested() async {
    emit(AuthLoading());
    final result = await _googleSignInUseCase();

    result.fold(
      (failure) {
        // Không emit gì, chờ listener xử lý
      },
      (_) {}, // Thành công, không cần làm gì cả, chờ listener
    );
  }

  Future<Either<Failure, void>> updateUserProfile(
    UserProfileEntity updatedProfile,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      return Left(ServerFailure('User not authenticated'));
    }

    // Gọi usecase để lưu thay đổi vào database
    final result = await _updateUserProfileUsecase(updatedProfile);

    result.fold(
      (failure) {
        print("Failed to update profile in AuthCubit: ${failure.message}");
        // Không emit state mới nếu lỗi
      },
      (_) {
        // Nếu thành công, emit lại state AuthAuthenticated với profile mới
        print("Profile updated successfully. Emitting new AuthState.");
        emit(AuthAuthenticated(currentState.user, updatedProfile));
      },
    );
    return result;
  }

  /// Cập nhật chỉ giọng đọc ưa thích
  Future<void> updatePreferredVoice(String voiceName) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    // Tạo entity mới chỉ với thông tin cần cập nhật
    final profileToUpdate = UserProfileEntity(
      id: currentState.userProfile.id,
      preferredVoice: voiceName,
    );

    // Tạo entity đầy đủ cho UI (cập nhật lạc quan)
    final newFullProfile = UserProfileEntity(
      id: currentState.userProfile.id,
      fullName: currentState.userProfile.fullName,
      avatarUrl: currentState.userProfile.avatarUrl,
      preferredVoice: voiceName,
    );

    // Cập nhật UI ngay lập tức
    emit(AuthAuthenticated(currentState.user, newFullProfile));

    // Gọi usecase để lưu thay đổi vào database (không cần chờ đợi kết quả ở UI)
    await _updateUserProfileUsecase(profileToUpdate);
  }

  /// Phương thức để refresh lại profile từ DB, hữu ích sau khi edit xong
  Future<void> forceRefreshUserProfile() async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      await _fetchProfileAndAuthenticate(currentState.user as User);
    }
  }

  // Future<void> _checkInitialSession() async {
  //   final currentSession = Supabase.instance.client.auth.currentSession;

  //   if (currentSession != null) {
  //     print('--- Session restored. Fetching profile... ---');
  //     // Chỉ cần gọi _fetchProfileAndAuthenticate là đủ, không emit gì thêm ở đây
  //     await _fetchProfileAndAuthenticate(currentSession.user);
  //   } else {
  //     print('--- No active session. User is unauthenticated. ---');
  //     emit(AuthUnauthenticated());
  //   }
  // }

  Future<void> _fetchProfileAndAuthenticate(User user) async {
    final profileResult = await _getUserProfileUsecase();
    final userEntity = UserEntity.fromSupabaseUser(user);
    profileResult.fold(
      (failure) {
        // Nếu không fetch được profile, vẫn cho đăng nhập nhưng báo lỗi
        print("Error fetching user profile: ${failure.message}");
        // Có thể tạo một UserProfileEntity rỗng để tránh lỗi null
        final emptyProfile = UserProfileEntity(id: user.id);
        emit(AuthAuthenticated(userEntity, emptyProfile));
      },
      (profile) {
        // Fetch thành công, emit state với đầy đủ thông tin
        emit(AuthAuthenticated(userEntity, profile));
      },
    );
  }

  Future<void> signOutRequested() async {
    emit(AuthLoading()); // Chuyển sang trạng thái loading

    final result = await _googleSignOutUseCase();

    result.fold(
      (failure) {
        // Nếu đăng xuất thất bại, có thể hiển thị lỗi
        // nhưng vẫn giữ người dùng ở trạng thái đăng nhập.
        // Hoặc đơn giản là chuyển về unauthenticated với thông báo lỗi.
        emit(AuthUnauthenticated());
      },
      (_) {
        // Nếu đăng xuất thành công, chuyển sang trạng thái unauthenticated
        emit(AuthUnauthenticated());
      },
    );
  }
}
