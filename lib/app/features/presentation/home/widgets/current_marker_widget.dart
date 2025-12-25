import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_map_trace_app/app/common/constants/app_colors.dart';
import 'package:user_map_trace_app/app/features/presentation/home/cubit/home_cubit.dart';

class CurrentMarkerWidget extends StatelessWidget {
  const CurrentMarkerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return CustomPaint(
          size: const Size(40, 40),
          painter: CurrentMarkerPainter(heading: state.currentHeading),
        );
      },
    );
  }
}

class CurrentMarkerPainter extends CustomPainter {
  final double? heading;

  CurrentMarkerPainter({this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Dış açık mavi daire
    final outerCirclePaint = Paint()
      ..color = AppColors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, outerCirclePaint);

    // Orta mavi daire
    final middleCirclePaint = Paint()
      ..color = AppColors.blue.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.7, middleCirclePaint);

    // İç koyu mavi nokta
    final innerCirclePaint = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.35, innerCirclePaint);

    // Yön göstergesi varsa çiz
    if (heading != null) {
      // Canvas'ı kaydet
      canvas.save();

      // Merkeze taşı ve heading'e göre döndür
      canvas.translate(center.dx, center.dy);
      // Heading: Kuzeyden saat yönünde (0 = Kuzey, 90 = Doğu)
      // Flutter rotate: Pozitif değer saat yönünde döndürür
      // Canvas'ta yukarı = kuzey, bu yüzden heading'i direkt kullanabiliriz
      // Ancak Flutter'da y ekseni aşağı doğru olduğu için negatif yapıyoruz
      canvas.rotate(-heading! * 3.14159265359 / 180);
      canvas.translate(-center.dx, -center.dy);

      // Yön göstergesi (daha belirgin ok şekli)
      final arrowPaint = Paint()
        ..color = AppColors.blue
        ..style = PaintingStyle.fill;

      // Ok şeklinde path oluştur (yukarı doğru)
      final path = Path();
      final arrowLength = radius * 0.6;
      final arrowWidth = radius * 0.35;

      // Ok başı (üst)
      path.moveTo(center.dx, center.dy - arrowLength);
      path.lineTo(center.dx - arrowWidth, center.dy - arrowLength * 0.3);
      path.lineTo(center.dx - arrowWidth * 0.5, center.dy);
      path.lineTo(center.dx + arrowWidth * 0.5, center.dy);
      path.lineTo(center.dx + arrowWidth, center.dy - arrowLength * 0.3);
      path.close();

      canvas.drawPath(path, arrowPaint);

      // Ok kenarları (daha net görünüm için)
      final arrowBorderPaint = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawPath(path, arrowBorderPaint);

      // Canvas'ı geri yükle
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CurrentMarkerPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}
