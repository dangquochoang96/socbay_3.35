import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart' as ms;
import 'package:image_picker/image_picker.dart';

/// Sử dụng trước需已经获取相关权限
/// Relevant privileges must be obtained before use
class QrcodeReaderView extends StatefulWidget {
  final Widget? headerWidget;
  final Future Function(String) onScan;
  final double scanBoxRatio;
  final Color boxLineColor;
  final Widget? helpWidget;
  final bool allowGallery;
  const QrcodeReaderView({
    super.key,
    required this.onScan,
    this.headerWidget,
    this.boxLineColor = Colors.cyanAccent,
    this.helpWidget,
    this.scanBoxRatio = 0.85,
    this.allowGallery = false,
  });

  @override
  State<QrcodeReaderView> createState() => _QrcodeReaderViewState();
}

class _ScannerOverlayPainter extends CustomPainter {
  final Rect scanWindow;
  final Color boxLineColor;

  _ScannerOverlayPainter({
    required this.scanWindow,
    required this.boxLineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Làm mờ viền nhạt hơn (0.2 thay vì 0.5) để người dùng thấy rõ toàn màn hình đều có thể quét
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.2);

    final borderPaint = Paint()
      ..color = boxLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final scanWindowRRect = RRect.fromRectAndRadius(
      scanWindow,
      const Radius.circular(16.0),
    );

    // Draw the semi-transparent overlay with a cutout
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(scanWindowRRect),
      ),
      overlayPaint,
    );

    // Draw the border around the cutout
    canvas.drawRRect(scanWindowRRect, borderPaint);
  }

  @override
  bool shouldRepaint(_ScannerOverlayPainter oldDelegate) {
    return oldDelegate.scanWindow != scanWindow ||
        oldDelegate.boxLineColor != boxLineColor;
  }
}

/// 扫码后的后续操作
/// ```dart
/// GlobalKey<QrcodeReaderViewState> qrViewKey = GlobalKey();
/// qrViewKey.currentState.startScan();
/// ```
class _QrcodeReaderViewState extends State<QrcodeReaderView>
    with WidgetsBindingObserver {
  ms.MobileScannerController? cameraController;
  bool isScan = false;
  bool isFlashOn = false;
  bool isLoading = false;
  bool isCameraInitialized = false;
  Timer? _initTimer;
  StreamSubscription? _cameraStateSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _initTimer?.cancel();
    _cameraStateSubscription?.cancel();
    cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (cameraController == null || !isCameraInitialized) return;

    switch (state) {
      case AppLifecycleState.paused:
        cameraController?.stop();
        break;
      case AppLifecycleState.resumed:
        if (!isScan) {
          _restartScan();
        }
        break;
      default:
        break;
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Khởi tạo camera controller với cấu hình tối ưu cho iOS và Android
      cameraController = ms.MobileScannerController(
        formats: const [
          ms.BarcodeFormat.all,
        ], // Hỗ trợ quét cả QR code và Barcode
        detectionSpeed: ms
            .DetectionSpeed
            .normal, // Thay normal thay vì noDuplicates để nhạy hơn
        facing: ms.CameraFacing.back,
        torchEnabled: false,
        returnImage: false, // Không trả về image để tăng tốc
        autoStart: true, // Tự động start để giảm delay
      );

      // Đặt camera sẵn sàng ngay lập tức
      // MobileScanner sẽ tự xử lý việc khởi tạo camera
      setState(() {
        isCameraInitialized = true;
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        _showErrorDialog('Không thể khởi tạo camera: $e');
      }
    }
  }

  void _onDetect(ms.BarcodeCapture capture) async {
    // Bỏ check !isCameraInitialized để không chặn những luồng quét đầu tiên (nhạy hơn)
    if (isScan) return;
    final List<ms.Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      isScan = true;
      cameraController?.stop();
      await widget.onScan(barcodes.first.rawValue ?? '');
    }
  }

  Future<void> _scanImage() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100, // Đảm bảo chất lượng ảnh tốt cho việc quét QR
      );

      if (image == null) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
        return;
      }

      // Thêm delay nhỏ để đảm bảo file được lưu hoàn toàn
      await Future.delayed(const Duration(milliseconds: 100));

      final capture = await cameraController?.analyzeImage(
        image.path,
        formats: const [ms.BarcodeFormat.all],
      );
      final barcodes = capture?.barcodes ?? const <ms.Barcode>[];

      if (mounted) {
        if (barcodes.isNotEmpty) {
          isScan = true;
          cameraController?.stop();
          await widget.onScan(barcodes.first.rawValue ?? '');
        } else {
          _showNoBarcodeDialog();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi khi quét ảnh: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showNoBarcodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Không tìm thấy mã'),
        content: const Text(
          'Ảnh bạn chọn không chứa mã QR hoặc Barcode hợp lệ.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() async {
    if (cameraController == null || !isCameraInitialized) return;
    try {
      await cameraController!.toggleTorch();
      setState(() {
        isFlashOn = !isFlashOn;
      });
    } catch (e) {
      _showErrorDialog('Không thể bật/tắt đèn flash: $e');
    }
  }

  void _restartScan() {
    if (cameraController == null || !isCameraInitialized) return;
    setState(() {
      isScan = false;
    });
    try {
      cameraController!.start();
    } catch (e) {
      _showErrorDialog('Không thể khởi động lại camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final qrScanSize = constraints.maxWidth * widget.scanBoxRatio;
          final left = (constraints.maxWidth - qrScanSize) / 2;
          final top = (constraints.maxHeight - qrScanSize) * 0.333333;
          final scanWindow = Rect.fromLTWH(left, top, qrScanSize, qrScanSize);

          return Stack(
            children: [
              if (cameraController != null)
                Positioned.fill(
                  child: ms.MobileScanner(
                    controller: cameraController!,
                    onDetect: _onDetect,
                    fit: BoxFit.cover,
                    // Đã bỏ scanWindow: scanWindow để cho phép quét TOÀN MÀN HÌNH thay vì bó buộc trong khung
                  ),
                ),

              // Overlay painter
              Positioned.fill(
                child: CustomPaint(
                  painter: _ScannerOverlayPainter(
                    scanWindow: scanWindow,
                    boxLineColor: widget.boxLineColor,
                  ),
                ),
              ),

              if (isLoading)
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),

              if (widget.headerWidget != null) widget.headerWidget!,

              // Help text
              Positioned(
                left: 0,
                right: 0,
                top: top + qrScanSize + 20,
                child: Align(
                  alignment: Alignment.center,
                  child: DefaultTextStyle(
                    style: const TextStyle(color: Colors.white),
                    child:
                        widget.helpWidget ??
                        const Text(
                          "Đưa mã QR/Barcode vào khu vực camera để quét.\n(Đã tối ưu tự động lấy nét toàn màn hình)",
                          textAlign: TextAlign.center,
                        ),
                  ),
                ),
              ),

              // Buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.allowGallery)
                      IconButton(
                        icon: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: (isLoading || !isCameraInitialized)
                            ? null
                            : _scanImage,
                      ),
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: (isLoading || !isCameraInitialized)
                          ? null
                          : _restartScan,
                    ),
                    IconButton(
                      icon: Icon(
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: (isLoading || !isCameraInitialized)
                          ? null
                          : _toggleFlash,
                    ),
                  ],
                ),
              ),

              if (isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}
