import 'dart:math';

import 'package:flutter/material.dart';

class StarBackgroundPainter extends CustomPainter {
  final int starCount = 100; // Number of stars
  final Random random =
      Random(); // we gonna randomize star color...its a good idea... right?
  final Color starColor = Colors.yellow;
  final double minStarSize = 2.0;
  final double maxStarSize = 5.0;

  List<Star>? stars;

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    stars ??= List.generate(
        starCount,
        (index) => Star(
              random.nextDouble() * size.width,
              random.nextDouble() * size.height,
              random.nextDouble() * (maxStarSize - minStarSize) + minStarSize,
              random.nextDouble() * 2 * pi, // Initial rotation angle
            ));

    // Update star positions and rotation angles
    for (Star star in stars!) {
      star.x += star.speed * cos(star.rotationAngle);
      star.y += star.speed * sin(star.rotationAngle);

      // Wrap around the screen edges
      if (star.x < 0) {
        star.x = size.width;
      } else if (star.x > size.width) {
        star.x = 0;
      }
      if (star.y < 0) {
        star.y = size.height;
      } else if (star.y > size.height) {
        star.y = 0;
      }

      star.rotationAngle += star.angularSpeed; // Update rotation angle

      final Paint starPaint = Paint()
        ..color = const Color.fromRGBO(255, 255, 116,
            1) // Colors.primaries[random.nextInt(Colors.primaries.length)]
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(star.x, star.y), star.radius, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Trigger repaints for animation
  }
}

class Star {
  double x;
  double y;
  double radius;
  double rotationAngle; // Angle in radians
  double speed = 0.5; // Pixel movement per frame
  double angularSpeed = 0.01; // Radians added per frame

  Star(this.x, this.y, this.radius, this.rotationAngle);
}
