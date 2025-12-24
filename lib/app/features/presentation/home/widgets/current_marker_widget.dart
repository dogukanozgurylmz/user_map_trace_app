import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      ..color = const Color(0xFF4285F4).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, outerCirclePaint);

    // Orta mavi daire
    final middleCirclePaint = Paint()
      ..color = const Color(0xFF4285F4).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.7, middleCirclePaint);

    // İç koyu mavi nokta
    final innerCirclePaint = Paint()
      ..color = const Color(0xFF1A73E8)
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

      // Yön göstergesi (cone-shaped gradient)
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFF4285F4).withValues(alpha: 0.4),
            const Color(0xFF4285F4).withValues(alpha: 0.0),
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius * 0.9))
        ..style = PaintingStyle.fill;

      // Cone şeklinde path oluştur (yukarı doğru)
      final path = Path();
      path.moveTo(center.dx, center.dy - radius * 0.5);
      path.lineTo(center.dx - radius * 0.4, center.dy + radius * 0.3);
      path.lineTo(center.dx + radius * 0.4, center.dy + radius * 0.3);
      path.close();

      canvas.drawPath(path, gradientPaint);

      // Canvas'ı geri yükle
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CurrentMarkerPainter oldDelegate) {
    return oldDelegate.heading != heading;
  }
}
