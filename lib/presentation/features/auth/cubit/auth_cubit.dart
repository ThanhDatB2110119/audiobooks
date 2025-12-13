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
    _checkInitialSession();
  }

  Future<void> googleSignInRequested() async {
    emit(AuthLoading());

    final result = await _googleSignInUseCase();

    result.fold((failure) => emit(AuthUnauthenticated()), (user) {
      // Trên mobile, user object sẽ có dữ liệu
      // Trên web, nó có thể là rỗng, ta sẽ dựa vào auth state listener
      // để chuyển sang trạng thái authenticated sau.
      // Để đơn giản, ta có thể kiểm tra nếu user id không rỗng thì coi là thành công.
      if (user.id.isNotEmpty) {
        emit(AuthAuthenticated(user, UserProfileEntity(id: user.id)));
      }
      // Nếu không, ta có thể giữ state loading hoặc chuyển về unauthenticated,
      // chờ listener xử lý.
      else {
        // Trên web, quá trình redirect đã bắt đầu, giữ loading hoặc chờ listener
        // Không emit gì ở đây nếu ta có listener riêng
      }
    });
  }

  Future<Either<Failure, void>> updateUserProfile(UserProfileEntity updatedProfile) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) {
      return Left(ServerFailure( 'User not authenticated'));
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
    final profileToUpdate = UserProfileEntity(id: currentState.userProfile.id, preferredVoice: voiceName);
    
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

  Future<void> _checkInitialSession() async {
    final currentSession = Supabase.instance.client.auth.currentSession;

    if (currentSession != null) {
      print('--- Session restored. User is authenticated. ---');
      await _fetchProfileAndAuthenticate(currentSession.user);
      // ======================= SỬA LỖI TẠI ĐÂY =======================
      // 1. Lấy đối tượng User của Supabase
      final supabaseUser = currentSession.user;
      // 2. Chuyển đổi nó thành UserEntity của chúng ta
      final userEntity = UserEntity.fromSupabaseUser(supabaseUser);
      // 3. Truyền UserEntity vào state
      emit(AuthAuthenticated(userEntity, UserProfileEntity(id: userEntity.id)));
      // ===============================================================
    } else {
      print('--- No active session. User is unauthenticated. ---');
      emit(AuthUnauthenticated());
    }
  }


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
