import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showShadow;

  const AppLogo({
    Key? key,
    this.size = 120,
    this.backgroundColor,
    this.iconColor,
    this.showShadow = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: showShadow ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ] : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo de fondo decorativo
          Container(
            width: size * 0.8,
            height: size * 0.8,
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF3C2FCF)).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
          ),
          // Icono principal
          Icon(
            Icons.savings,
            size: size * 0.5,
            color: iconColor ?? const Color(0xFF3C2FCF),
          ),
          // Elemento decorativo (moneda pequeña)
          Positioned(
            top: size * 0.15,
            right: size * 0.15,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.monetization_on,
                size: size * 0.12,
                color: const Color(0xFFB8860B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedAppLogo extends StatefulWidget {
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool showShadow;
  final Duration animationDuration;

  const AnimatedAppLogo({
    Key? key,
    this.size = 120,
    this.backgroundColor,
    this.iconColor,
    this.showShadow = true,
    this.animationDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 0.1, // Rotación sutil
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(widget.size * 0.25),
                boxShadow: widget.showShadow ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ] : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de fondo decorativo
                  Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      color: (widget.iconColor ?? const Color(0xFF3C2FCF))
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Icono principal
                  Icon(
                    Icons.savings,
                    size: widget.size * 0.5,
                    color: widget.iconColor ?? const Color(0xFF3C2FCF),
                  ),
                  // Elemento decorativo (moneda pequeña)
                  Transform.rotate(
                    angle: -_rotationAnimation.value * 0.5,
                    child: Positioned(
                      top: widget.size * 0.15,
                      right: widget.size * 0.15,
                      child: Container(
                        width: widget.size * 0.2,
                        height: widget.size * 0.2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.monetization_on,
                          size: widget.size * 0.12,
                          color: const Color(0xFFB8860B),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
