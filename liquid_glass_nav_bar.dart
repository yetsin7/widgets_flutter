// ignore_for_file: unnecessary_import
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LIQUID GLASS NAV BAR
// Barra de navegación inferior con efecto glassmorphism estilo Apple.
// Píldora flotante translúcida con BackdropFilter blur, borde sutil
// semi-transparente e indicador circular animado.
//
// Se adapta automáticamente a modo claro y oscuro.
// Sin dependencias externas — solo Flutter SDK.
//
// ─── CÓMO USAR ───────────────────────────────────────────────────────────────
//
//   1. Copia este archivo completo a tu proyecto (ej: lib/widgets/).
//   2. Impórtalo donde lo necesites:
//        import 'package:tu_app/widgets/liquid_glass_nav_bar.dart';
//   3. Úsalo como bottomNavigationBar de tu Scaffold:
//
//      Scaffold(
//        extendBody: true,  // IMPORTANTE: permite ver contenido detrás del glass
//        body: pages[_currentIndex],
//        bottomNavigationBar: LiquidGlassNavBar(
//          currentIndex: _currentIndex,
//          onTabChanged: (i) => setState(() => _currentIndex = i),
//          tabs: const [
//            LiquidGlassTab(
//              icon: CupertinoIcons.house,
//              activeIcon: CupertinoIcons.house_fill,
//              label: 'Home',
//            ),
//            LiquidGlassTab(
//              icon: CupertinoIcons.cart,
//              activeIcon: CupertinoIcons.cart_fill,
//              label: 'Shop',
//            ),
//            LiquidGlassTab(
//              icon: CupertinoIcons.person,
//              activeIcon: CupertinoIcons.person_fill,
//              label: 'Profile',
//            ),
//          ],
//        ),
//      )
//
//   4. Añade padding inferior a tu contenido scrollable para que el último
//      elemento no quede oculto detrás de la barra:
//        padding: EdgeInsets.only(
//          bottom: MediaQuery.of(context).padding.bottom + 80,
//        )
//
// ─────────────────────────────────────────────────────────────────────────────


// ─── MODELO DE DATOS ─────────────────────────────────────────────────────────

/// Define una pestaña del nav bar: ícono inactivo, ícono activo y label.
class LiquidGlassTab {
  /// Ícono cuando la pestaña NO está seleccionada (outline).
  final IconData icon;

  /// Ícono cuando la pestaña SÍ está seleccionada (filled).
  final IconData activeIcon;

  /// Texto corto debajo del ícono.
  final String label;

  const LiquidGlassTab({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}


// ─── WIDGET PRINCIPAL ────────────────────────────────────────────────────────

/// Barra de navegación inferior con efecto Liquid Glass (glassmorphism).
///
/// Se adapta automáticamente a modo claro/oscuro usando el [Brightness]
/// del tema actual. Diseñada para usarse como [Scaffold.bottomNavigationBar]
/// con `extendBody: true` para que el contenido se vea detrás del blur.
class LiquidGlassNavBar extends StatelessWidget {
  /// Lista de pestañas a mostrar (mínimo 2, máximo 6).
  final List<LiquidGlassTab> tabs;

  /// Índice de la pestaña actualmente seleccionada.
  final int currentIndex;

  /// Se invoca al tocar una pestaña con su índice.
  final ValueChanged<int> onTabChanged;

  /// Altura interna de la barra (sin contar safe area). Default: 62.
  final double height;

  /// Radio de las esquinas de la píldora. Default: 50.
  final double borderRadius;

  /// Intensidad del efecto de desenfoque. Default: 30.
  final double blurSigma;

  /// Padding horizontal externo (separa la píldora de los bordes). Default: 24.
  final double horizontalPadding;

  /// Tamaño de los íconos dentro de cada tab. Default: 22.
  final double iconSize;

  /// Tamaño del texto del label. Default: 9.
  final double labelFontSize;

  const LiquidGlassNavBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabChanged,
    this.height = 62,
    this.borderRadius = 50,
    this.blurSigma = 30,
    this.horizontalPadding = 24,
    this.iconSize = 22,
    this.labelFontSize = 9,
  }) : assert(tabs.length >= 2 && tabs.length <= 6,
            'tabs must have between 2 and 6 elements');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // Paleta adaptativa light / dark.
    final selectedColor   = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final unselectedColor = isDark ? Colors.white38 : Colors.black38;
    final indicatorColor  = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.07);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.06);
    final backgroundColor = isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.65);

    return Padding(
      // Safe area inferior automática; fallback de 12px si no hay notch.
      padding: EdgeInsets.fromLTRB(
        horizontalPadding, 0, horizontalPadding,
        bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: backgroundColor,
              border: Border.all(color: borderColor, width: 0.5),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final isSelected = currentIndex == i;
                final tab = tabs[i];

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onTabChanged(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Círculo indicador animado detrás del ícono activo.
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? indicatorColor
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? tab.activeIcon : tab.icon,
                            color: isSelected
                                ? selectedColor
                                : unselectedColor,
                            size: iconSize,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          tab.label,
                          style: TextStyle(
                            color: isSelected
                                ? selectedColor
                                : unselectedColor,
                            fontSize: labelFontSize,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
