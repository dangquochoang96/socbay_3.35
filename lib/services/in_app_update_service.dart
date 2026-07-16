import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:socbay/services/navigation_service.dart';
import 'package:socbay/utils/logger_util.dart';

class InAppUpdateService {
  static final InAppUpdateService instance = InAppUpdateService._internal();

  InAppUpdateService._internal();

  StreamSubscription<InstallStatus>? _subscription;
  bool _isDownloading = false;

  /// Check for app update on Google Play Store (Android only)
  Future<void> checkForUpdate() async {
    if (!Platform.isAndroid) {
      LoggerUtil.info('In-App Update feature is only supported on Android.');
      return;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();
      LoggerUtil.info('InAppUpdate availability: ${info.updateAvailability}');

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        if (info.immediateUpdateAllowed) {
          // Trigger immediate blocking update flow
          LoggerUtil.info('Starting immediate update flow...');
          await InAppUpdate.performImmediateUpdate();
        } else if (info.flexibleUpdateAllowed) {
          // Trigger flexible update flow (background download)
          LoggerUtil.info('Starting flexible update flow...');
          _listenToInstallStatus();
          await InAppUpdate.startFlexibleUpdate();
        }
      }
    } catch (e) {
      LoggerUtil.error('Failed to check or perform in-app update: $e');
    }
  }

  /// Listen to background download status for Flexible Updates
  void _listenToInstallStatus() {
    if (_subscription != null) return;

    _subscription = InAppUpdate.installUpdateListener.listen(
      (InstallStatus status) {
        LoggerUtil.info('InstallStatus changed: $status');
        if (status == InstallStatus.downloading) {
          if (!_isDownloading) {
            _isDownloading = true;
            Fluttertoast.showToast(
              msg: 'Đang tải bản cập nhật mới...',
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        } else if (status == InstallStatus.downloaded) {
          _isDownloading = false;
          _showUpdateDownloadedDialog();
        } else if (status == InstallStatus.failed ||
            status == InstallStatus.canceled) {
          _isDownloading = false;
          _subscription?.cancel();
          _subscription = null;
        }
      },
      onError: (dynamic error) {
        LoggerUtil.error('Error listening to install status: $error');
        _isDownloading = false;
        _subscription?.cancel();
        _subscription = null;
      },
    );
  }

  /// Display dialog when flexible update is downloaded and ready to install
  void _showUpdateDownloadedDialog() {
    final context = NavigationService.instance.navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Bản cập nhật sẵn sàng'),
        content: const Text(
          'Đã tải xong phiên bản mới. Bạn có muốn khởi động lại ứng dụng ngay để hoàn tất cập nhật?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Để sau'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await InAppUpdate.completeFlexibleUpdate();
              } catch (e) {
                LoggerUtil.error('Error completing flexible update: $e');
                Fluttertoast.showToast(
                  msg: 'Không thể hoàn tất cập nhật. Vui lòng thử lại.',
                );
              }
            },
            child: const Text('Cập nhật ngay'),
          ),
        ],
      ),
    );
  }

  /// Cancel stream subscription when no longer needed
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}
