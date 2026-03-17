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
//            LiquidGlassTab(icon: CupertinoIcons.house,   activeIcon: CupertinoIcons.house_fill,   label: 'Home'),
//            LiquidGlassTab(icon: CupertinoIcons.cart,    activeIcon: CupertinoIcons.cart_fill,    label: 'Shop'),
//            LiquidGlassTab(icon: CupertinoIcons.person,  activeIcon: CupertinoIcons.person_fill,  label: 'Profile'),
//          ],
//        ),
//      )
//
//   4. Para mover todos los botones a la vez:
//        buttonsSpreadX: 10,   // expande hacia los lados (+) o junta al centro (-)
//        buttonsOffsetY: -4,   // sube (-) o baja (+) todos los botones
//
//   5. Para ajuste fino individual por botón:
//        tabOffsets: [8, 0, 0, -8],  // positivo = derecha, negativo = izquierda
//
// ─────────────────────────────────────────────────────────────────────────────


// ─── MODELO DE DATOS ─────────────────────────────────────────────────────────

/// Define una pestaña del nav bar: ícono inactivo, ícono activo y label.
class LiquidGlassTab {
  final IconData icon;       // Ícono cuando la pestaña NO está seleccionada (outline)
  final IconData activeIcon; // Ícono cuando la pestaña SÍ está seleccionada (filled)
  final String label;        // Texto corto debajo del ícono

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
  final List<LiquidGlassTab> tabs;       // Lista de pestañas a mostrar (mínimo 2, máximo 6)
  final int currentIndex;                // Índice de la pestaña actualmente seleccionada
  final ValueChanged<int> onTabChanged;  // Se invoca al tocar una pestaña con su índice

  final double borderRadius;        // redondez de esquinas — default 50
  final double blurSigma;           // intensidad del blur glassmorphism — default 30
  final double horizontalPadding;   // separación lateral píldora ↔ pantalla — default 20
  final double? height;             // alto FIJO de la píldora en px; si es null usa pillVerticalPadding
  final double pillVerticalPadding; // padding vertical interno → alto automático si height es null — default 6
  final double iconSize;            // tamaño del ícono — default 25
  final double buttonPadding;       // padding del círculo; tamaño total = iconSize + buttonPadding*2 — default 10

  // ── Control de posición global ────────────────────────────────────────────
  // spaceEvenly sin Expanded: Flutter divide el espacio libre en N+1 partes
  // iguales → borde↔btn0 = btn0↔btn1 = ... = btnN↔borde (separación idéntica).
  //
  // buttonsSpreadX: expande (+) o contrae (-) TODOS los botones desde el centro.
  //   Cada botón i recibe: dx = (i − centro) × buttonsSpreadX
  //   Ej. 4 botones, buttonsSpreadX=10 → [-15, -5, +5, +15] px
  //
  // buttonsOffsetY: sube (-) o baja (+) TODOS los botones a la vez.
  //
  // tabOffsets: ajuste fino individual por botón (se suma a buttonsSpreadX).
  //   Ej. tabOffsets: [5, 0, 0, -5]
  // ─────────────────────────────────────────────────────────────────────────
  final double buttonsSpreadX;     // expande(+) o contrae(-) todos los botones desde el centro — default 0
  final double buttonsOffsetY;     // sube(-) o baja(+) todos los botones juntos — default 0
  final List<double>? tabOffsets;  // ajuste fino individual [dx0, dx1, ...] en px — default null

  const LiquidGlassNavBar({
    super.key,                          // Clave opcional para el widget
    required this.tabs,                 // Lista de pestañas a mostrar (mínimo 2, máximo 6)
    required this.currentIndex,         // Índice de la pestaña actualmente seleccionada
    required this.onTabChanged,         // Callback al tocar una pestaña, recibe el índice
    this.borderRadius = 50,             // Redondez de las esquinas de la píldora
    this.blurSigma = 30,                // Intensidad del blur; mayor = más borroso
    this.horizontalPadding = 20,        // Espacio horizontal entre los bordes de la pantalla y la píldora
    this.height = 70,                   // Alto fijo; null = calculado con pillVerticalPadding
    this.pillVerticalPadding = 6,       // Padding vertical cuando height es null
    this.iconSize = 25,                 // Tamaño del ícono dentro del botón
    this.buttonPadding = 10,            // Padding del círculo; total = iconSize + buttonPadding*2
    this.buttonsSpreadX = 0,            // Expansión horizontal de todos los botones desde el centro
    this.buttonsOffsetY = 0,            // Desplazamiento vertical de todos los botones
    this.tabOffsets,                    // Ajuste fino individual [dx0, dx1, ...] en px
  }) : assert(tabs.length >= 2 && tabs.length <= 6,
            'tabs must have between 2 and 6 elements');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; // Detecta si está en modo oscuro
    final bottomPadding = MediaQuery.of(context).padding.bottom;    // Safe area inferior (notch, etc)
    final center = (tabs.length - 1) / 2.0;                        // Centro de la lista de botones

    final selectedColor   = isDark ? Colors.white : const Color(0xFF1C1C1E); // Color ícono activo — editar para cambiar
    final unselectedColor = isDark ? Colors.white38 : Colors.black38;        // Color ícono inactivo
    final indicatorColor  = isDark                                            // Fondo del círculo activo
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.07);
    final borderColor = isDark                                                // Borde de la píldora
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.06);
    final backgroundColor = isDark                                            // Fondo de la píldora
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.6)
        : Colors.white.withValues(alpha: 0.65);

    return Padding(
      padding: EdgeInsets.fromLTRB(                    // Safe area inferior; fallback 12 px
        horizontalPadding, 0, horizontalPadding,
        bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            height: height,                            // Alto de la barra; null = auto
            padding: height == null
                ? EdgeInsets.symmetric(vertical: pillVerticalPadding)
                : null,
            decoration: BoxDecoration(
              color: backgroundColor,                  // Fondo glassmorphism
              border: Border.all(color: borderColor, width: 0.5), // Borde fino sutil
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            // spaceEvenly sin Expanded: separaciones idénticas entre todos los botones
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(tabs.length, (i) {
                final isSelected = currentIndex == i;
                final tab = tabs[i];

                // Desplazamiento total = spread global + ajuste individual
                final spreadDx = (i - center) * buttonsSpreadX; // expande/contrae desde el centro
                final extraDx  = (tabOffsets != null && i < tabOffsets!.length)
                    ? tabOffsets![i]                             // ajuste fino individual
                    : 0.0;

                return Transform.translate(
                  offset: Offset(spreadDx + extraDx, buttonsOffsetY), // aplica X e Y globales
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,  // Permite tocar el área completa
                    onTap: () => onTabChanged(i),      // Notifica al padre cuál tab se tocó
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200), // Velocidad de animación
                      curve: Curves.easeInOut,
                      padding: EdgeInsets.all(buttonPadding),      // Tamaño del área circular
                      decoration: BoxDecoration(
                        color: isSelected ? indicatorColor : Colors.transparent, // Fondo círculo activo
                        shape: BoxShape.circle,
                      ),
                      // ─────────────────────────────────────────────────────
                      // NOTA: Para mostrar texto debajo de los botones,
                      // descomenta las líneas abajo y comenta el Icon de abajo.
                      // ─────────────────────────────────────────────────────
                      //child: Column(mainAxisSize: MainAxisSize.min, children: [
                      //  Icon(isSelected ? tab.activeIcon : tab.icon,
                      //    color: isSelected ? selectedColor : unselectedColor,
                      //    size: iconSize),
                      //  const SizedBox(height: 2),
                      //  Text(tab.label, style: TextStyle(fontSize: 9,
                      //    color: isSelected ? selectedColor : unselectedColor,
                      //    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                      //]),
                      child: Icon(
                        isSelected ? tab.activeIcon : tab.icon, // Cambia ícono según selección
                        color: isSelected ? selectedColor : unselectedColor,
                        size: iconSize,                          // Tamaño configurable del ícono
                      ),
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
