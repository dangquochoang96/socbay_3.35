import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:socbay/utils/context_extension.dart';
import 'package:socbay/widgets/dialog/custom_alert_dialog.dart';


int maxSizeVideoKb = 50 * 1024 * 1024;
int maxSizePhotoKb = 50 * 1024 * 1024;

Future<File?> onGetPhotoFromGallery(
    {required BuildContext context,
    required ImagePicker picker,
    required Function funcPermission}) async {
  if (await Permission.photos.request().isGranted) {
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        File imageFile = File(pickedFile.path);
        return imageFile;
      } else {
        context.showSnackBar('You have not selected a photo');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  } else {
    funcPermission();
  }
  return null;
}

Future<List<File>?> onGetMultiPhoto(
    {required BuildContext context,
    required ImagePicker picker,
    required Function funcPermission}) async {
  if (await Permission.photos.request().isGranted) {
    try {
      final pickedFiles = await picker.pickMultiImage(
        imageQuality: 100,
      );

      if (pickedFiles.isNotEmpty) {
        final List<File> listFile = [];
        for (var item in pickedFiles) {
          File imageFile = File(item.path);
          listFile.add(imageFile);
        }
        return listFile;
      } else {
        // showSnackBarError(context: context, message: 'File error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  } else {
    funcPermission();
  }
  return null;
}

Future<File?> onGetVideo(
    {required BuildContext context, required ImagePicker picker}) async {
  if (await Permission.photos.request().isGranted) {
    try {
      final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

      if (pickedFile != null) {
        return File(pickedFile.path);
      } else {
        // showSnackBarError(context: context, message: 'File error');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  } else {
    _showPhotoPermissionAlertDialog(context);
  }
  return null;
}

_showPhotoPermissionAlertDialog(BuildContext context) {
  CustomAlertDialog.show(
    context,
    leftText: "Cài đặt",
    rightText: "Hủy",
    isLeftPositive: true,
    leftAction: () {
      Navigator.pop(context);
      openAppSettings();
    },
    content: 'Vui lòng cấp quyền truy cập thư viện.',
  );
}

Future<String> getAppPath() async {
  Directory appDocumentsDirectory =
      await getApplicationDocumentsDirectory(); // 1
  return appDocumentsDirectory.path;
}

Future saveAndShareImage(
    {required Uint8List image, String content = ''}) async {
  String filePath = await getAppPath() + '/screenshot_result.png';
  File file = File(filePath);
  await file.writeAsBytes(image);
  XFile xFile = XFile(filePath);
  await Share.shareXFiles([xFile], text: content);
}

Future shareText({required String content}) async {
  try {
    await Share.share(content);
  } catch (e) {
    print('Error sharing text: $e');
  }
}
