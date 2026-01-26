import 'package:get_it/get_it.dart';
import 'package:my_bomb_wishes/data/repositories/profile_repository.dart';
import 'package:my_bomb_wishes/data/repositories/supabase_auth_repository.dart';
import 'package:my_bomb_wishes/data/repositories/supabase_subscription_repository.dart';
import 'package:my_bomb_wishes/data/repositories/supabase_wish_repository.dart';
import 'package:my_bomb_wishes/data/telegram/telegram_service_fake.dart';
import 'package:my_bomb_wishes/data/telegram/telegram_service_impl.dart';
import 'package:my_bomb_wishes/domain/repositories/auth_repository.dart';
import 'package:my_bomb_wishes/domain/repositories/profile_repository.dart';
import 'package:my_bomb_wishes/domain/repositories/subscription_repository.dart';
import 'package:my_bomb_wishes/domain/repositories/wish_repository.dart';
import 'package:my_bomb_wishes/domain/telegram/telegram_service.dart';
import 'package:my_bomb_wishes/domain/usecases/add_wish_usecase.dart';
import 'package:my_bomb_wishes/domain/usecases/delete_wish_use_case.dart';
import 'package:my_bomb_wishes/domain/usecases/get_followers_use_case.dart';
import 'package:my_bomb_wishes/domain/usecases/update_wish_use_case.dart';
import 'package:my_bomb_wishes/presentation/friends/friends_search_view_model.dart';
import 'package:my_bomb_wishes/presentation/friends/friends_view_model.dart';
import 'package:my_bomb_wishes/presentation/profile/auth_view_model.dart';
import 'package:my_bomb_wishes/presentation/profile/profile_view_model.dart';
import 'package:my_bomb_wishes/presentation/wishes/wishes_view_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telegram_web_app/telegram_web_app.dart';

final getIt = GetIt.instance;

void setupDependencyInjection() {
  final supabaseClient = Supabase.instance.client;

  // Telegram
  if (TelegramWebApp.instance.isSupported) {
    getIt.registerLazySingleton<TelegramService>(() => TelegramServiceImpl(TelegramWebApp.instance));
  } else {
    getIt.registerLazySingleton<TelegramService>(() => TelegramServiceFake());
  }

  // --- REPOSITORIES ---
  getIt.registerLazySingleton<AuthRepository>(() => SupabaseAuthRepository(supabaseClient));
  getIt.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(supabaseClient));
  getIt.registerLazySingleton<WishRepository>(() => SupabaseWishRepository(supabaseClient));
  getIt.registerLazySingleton<SubscriptionRepository>(() => SupabaseSubscriptionRepository(supabaseClient));

  // --- USE CASES ---
  getIt.registerLazySingleton<AddWishUseCase>(() => AddWishUseCase(getIt<WishRepository>()));
  getIt.registerLazySingleton<DeleteWishUseCase>(() => DeleteWishUseCase(getIt<WishRepository>()));
  getIt.registerLazySingleton<UpdateWishUseCase>(() => UpdateWishUseCase(getIt<WishRepository>()));
  getIt.registerLazySingleton<GetFollowersUseCase>(() => GetFollowersUseCase(getIt<SubscriptionRepository>()));
  getIt.registerLazySingleton<GetFollowingUseCase>(() => GetFollowingUseCase(getIt<SubscriptionRepository>()));

  // --- VIEW MODELS ---
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(getIt<AuthRepository>(), getIt<TelegramService>(), getIt<ProfileRepository>()),
  );
  getIt.registerFactoryParam<WishesViewModel, String, void>((userId, _) => WishesViewModel(userId));
  getIt.registerFactoryParam<ProfileViewModel, String, void>((profileId, _) => ProfileViewModel(profileId));
  getIt.registerFactory<FriendsSearchViewModel>(() => FriendsSearchViewModel(getIt<SubscriptionRepository>()));
  getIt.registerFactoryParam<FriendsViewModel, String, void>(
    (userId, _) => FriendsViewModel(
      userId: userId,
      myId: supabaseClient.auth.currentUser?.id ?? '',
      getFollowersUseCase: getIt<GetFollowersUseCase>(),
      getFollowingUseCase: getIt<GetFollowingUseCase>(),
    ),
  );
}
