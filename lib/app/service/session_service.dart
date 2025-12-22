import 'dart:async';

import 'package:get/get.dart';
import 'package:local_session_timeout/local_session_timeout.dart';

class SessionService extends GetxService {
  static SessionService get to => Get.find();
  late final StreamController<SessionState> _sessionStateStream;
  Stream<SessionState> get stream => _sessionStateStream.stream;
  late final SessionConfig _sessionConfig;
  SessionConfig get sessionConfig => _sessionConfig;

  final RxBool isIdle = false.obs;

  @override
  void onInit() {
    super.onInit();
    _sessionStateStream = StreamController<SessionState>.broadcast();
    _sessionConfig = SessionConfig(
      invalidateSessionForAppLostFocus: const Duration(minutes: 5), // 当应用失去焦点时超时
      invalidateSessionForUserInactivity: const Duration(minutes: 5), // 用户不活动超时
    );

    _sessionConfig.stream.listen((SessionTimeoutState timeoutEvent) {
      if (timeoutEvent == SessionTimeoutState.userInactivityTimeout ||
          timeoutEvent == SessionTimeoutState.appFocusTimeout) {
        isIdle.value = true;
      }
    });
  }

  void onUserActivity() {
    if (isIdle.value) {
      isIdle.value = false;
      _sessionStateStream.add(SessionState.startListening);
    }
  }

  @override
  void onReady() {
    _sessionStateStream.add(SessionState.startListening);
    super.onReady();
  }

  @override
  void onClose() {
    _sessionStateStream.close();
    super.onClose();
  }
}
