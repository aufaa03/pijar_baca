import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pijar_baca/core/services/book_api_service.dart';
import 'package:pijar_baca/features/book/presentation/add_book_screen.dart';

class ScanIsbnScreen extends StatefulWidget {
  const ScanIsbnScreen({super.key});

  @override
  State<ScanIsbnScreen> createState() => _ScanIsbnScreenState();
}

class _ScanIsbnScreenState extends State<ScanIsbnScreen> {
  final BookApiService _apiService = BookApiService();
  bool _isProcessing = false;
  MobileScannerController? _controller;
  String? _lastScannedIsbn;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcode = capture.barcodes.first;
    final isbn = barcode.rawValue;

    // Cegah scan berulang pada ISBN yang sama
    if (isbn == null || isbn == _lastScannedIsbn) return;

    setState(() {
      _isProcessing = true;
      _lastScannedIsbn = isbn;
    });

    try {
      // Tampilkan feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 2,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mencari data buku untuk ISBN: $isbn...',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade700,
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Panggil API untuk mendapatkan data buku
      final book = await _apiService.getBookByIsbn(isbn);

      if (book != null && mounted) {
        // SUKSES - Navigate ke AddBookScreen
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddBookScreen(prefilledBook: book),
          ),
        );
      } else if (mounted) {
        // GAGAL - Tampilkan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Buku dengan ISBN $isbn tidak ditemukan',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Reset state setelah delay
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isProcessing = false;
          _lastScannedIsbn = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gagal terhubung. Periksa koneksi internet',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        await Future.delayed(const Duration(seconds: 2));
        setState(() {
          _isProcessing = false;
          _lastScannedIsbn = null;
        });
      }
    }
  }

  void _switchCamera() {
    if (_controller != null) {
      _controller!.switchCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan ISBN Buku'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onBackground,
        actions: [
          // Camera Switch saja
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.cameraswitch_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay dengan frame scan
          _buildScannerOverlay(),

          // Loading indicator saat processing
          if (_isProcessing) _buildLoadingOverlay(),

          // Instructions
          _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 3,
          ),
        ),
        child: CustomPaint(
          painter: _ScannerCornerPainter(),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(height: 20),
            Text(
              'Memproses ISBN...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_lastScannedIsbn',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white.withOpacity(0.8), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Tips Scanning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Arahkan kamera ke barcode ISBN di samping buku. '
              'Pastikan barcode berada dalam frame dan pencahayaan cukup.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter untuk corner effect pada frame scanner
class _ScannerCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 20.0;

    // Top left corner
    canvas.drawLine(const Offset(0, 0), const Offset(cornerLength, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, cornerLength), paint);

    // Top right corner
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - cornerLength, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, cornerLength), paint);

    // Bottom left corner
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - cornerLength), paint);
    canvas.drawLine(Offset(0, size.height), Offset(cornerLength, size.height), paint);

    // Bottom right corner
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - cornerLength), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - cornerLength, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}