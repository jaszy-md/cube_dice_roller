import 'dart:math';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class DiceCube extends StatefulWidget {
  const DiceCube({super.key});

  @override
  State<DiceCube> createState() => _DiceCubeState();
}

class _DiceCubeState extends State<DiceCube>
    with SingleTickerProviderStateMixin {
  double xRotation = 0;
  double yRotation = 0;
  static const double size = 180;
  static const double half = size / 2;

  late AnimationController _controller;
  late Animation<double> _xAnimation;
  late Animation<double> _yAnimation;

  final List<String> images = [
    'assets/images/dice-1.png',
    'assets/images/dice-2.png',
    'assets/images/dice-3.png',
    'assets/images/dice-4.png',
    'assets/images/dice-5.png',
    'assets/images/dice-6.png',
  ];

  final List<_Rotation> predefinedRotations = [
    _Rotation(x: 0, y: 0),
    _Rotation(x: 0, y: pi),
    _Rotation(x: 0, y: -pi / 2),
    _Rotation(x: 0, y: pi / 2),
    _Rotation(x: -pi / 2, y: 0),
    _Rotation(x: pi / 2, y: 0),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _controller.addListener(() {
      setState(() {
        xRotation = _xAnimation.value;
        yRotation = _yAnimation.value;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Matrix4 base =
        Matrix4.identity()
          ..setEntry(3, 2, 0.0)
          ..rotateX(xRotation)
          ..rotateY(yRotation);

    final faces = <_FaceTransform>[
      _FaceTransform(
        asset: images[0],
        transform: base.clone()..translate(Vector3(0, 0, half)),
      ),
      _FaceTransform(
        asset: images[1],
        transform:
            base.clone()
              ..rotateY(pi)
              ..translate(Vector3(0, 0, half)),
      ),
      _FaceTransform(
        asset: images[2],
        transform:
            base.clone()
              ..rotateY(pi / 2)
              ..translate(Vector3(0, 0, half)),
      ),
      _FaceTransform(
        asset: images[3],
        transform:
            base.clone()
              ..rotateY(-pi / 2)
              ..translate(Vector3(0, 0, half)),
      ),
      _FaceTransform(
        asset: images[4],
        transform:
            base.clone()
              ..rotateX(-pi / 2)
              ..translate(Vector3(0, 0, half)),
      ),
      _FaceTransform(
        asset: images[5],
        transform:
            base.clone()
              ..rotateX(pi / 2)
              ..translate(Vector3(0, 0, half)),
      ),
    ];

    for (var face in faces) {
      face.zValue = face.transform.transformed3(Vector3.zero()).z;
    }

    faces.sort((a, b) => a.zValue.compareTo(b.zValue));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children:
                faces.map((face) {
                  return Positioned.fill(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: face.transform,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(face.asset),
                            fit: BoxFit.cover,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 60),
        _buildControls(),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        Text('X Rotation: ${(xRotation % (2 * pi)).toStringAsFixed(2)}'),
        Slider(
          value: xRotation % (2 * pi),
          min: 0,
          max: 2 * pi,
          onChanged: (v) => setState(() => xRotation = v),
        ),
        Text('Y Rotation: ${(yRotation % (2 * pi)).toStringAsFixed(2)}'),
        Slider(
          value: yRotation % (2 * pi),
          min: 0,
          max: 2 * pi,
          onChanged: (v) => setState(() => yRotation = v),
        ),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _rollDice, child: const Text('Roll')),
      ],
    );
  }

  void _rollDice() {
    final rand = Random();
    final rotation =
        predefinedRotations[rand.nextInt(predefinedRotations.length)];

    final offsetX = rand.nextInt(3) * 2 * pi;
    final offsetY = rand.nextInt(3) * 2 * pi;

    final newX = rotation.x + offsetX;
    final newY = rotation.y + offsetY;

    _xAnimation = Tween<double>(
      begin: xRotation,
      end: newX,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _yAnimation = Tween<double>(
      begin: yRotation,
      end: newY,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(from: 0);
  }
}

class _Rotation {
  final double x;
  final double y;
  _Rotation({required this.x, required this.y});
}

class _FaceTransform {
  final String asset;
  final Matrix4 transform;
  double zValue;

  _FaceTransform({
    required this.asset,
    required this.transform,
    this.zValue = 0,
  });
}
