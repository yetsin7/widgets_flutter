// ignore_for_file: unnecessary_import
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AUDIO PLAYER CONTROLS
// Reproductor de audio compacto con 5 botones: reiniciar, retroceder,
// play/pause, adelantar y progreso de lectura.
// Botón principal circular destacado con sombra y efecto glassmorphism
// en el botón de reinicio.
//
// Se adapta automáticamente a modo claro y oscuro.
// Sin dependencias externas — solo Flutter SDK.
//
// ─── CÓMO USAR ───────────────────────────────────────────────────────────────
//
//   1. Copia este archivo completo a tu proyecto (ej: lib/widgets/).
//   2. Impórtalo donde lo necesites:
//        import 'package:tu_app/widgets/audio_player_controls.dart';
//   3. Úsalo en cualquier parte de tu layout:
//
//      AudioPlayerControls(
//        isPlaying: _isPlaying,
//        progress: 0.45,           // 0.0 a 1.0
//        totalItems: 30,
//        currentItemIndex: 13,
//        onPlayPause: () => setState(() => _isPlaying = !_isPlaying),
//        onSkipPrevious: () => print('Anterior'),
//        onSkipNext: () => print('Siguiente'),
//        onRestart: () => print('Reiniciar'),
//      )
//
//   4. Parámetros opcionales:
//      - isPaused: muestra la barra de progreso aunque no esté reproduciendo.
//      - trailingWidget: widget extra al final de la fila (ej: menú).
//      - distributeAcrossWidth: distribuye botones a lo ancho del contenedor.
//      - primaryColor: color del botón principal y barra de progreso.
//
// ─────────────────────────────────────────────────────────────────────────────


// ─── WIDGET PRINCIPAL ────────────────────────────────────────────────────────

/// Reproductor de audio compacto con controles de reproducción.
///
/// Muestra una barra de progreso lineal (cuando hay reproducción activa)
/// y una fila de 5 controles: reiniciar, retroceder, play/pause,
/// adelantar y un widget opcional al final.
/// El botón principal tiene un estilo circular destacado con sombra.
/// El botón de reinicio usa efecto glassmorphism (BackdropFilter blur).
class AudioPlayerControls extends StatelessWidget {
  /// Indica si el audio está reproduciéndose actualmente.
  final bool isPlaying;

  /// Progreso actual de lectura (0.0 a 1.0).
  final double progress;

  /// Total de elementos (pistas, versículos, etc.) a reproducir.
  final int totalItems;

  /// Índice del elemento actualmente en reproducción.
  final int currentItemIndex;

  /// Callback para alternar reproducción/pausa.
  final VoidCallback onPlayPause;

  /// Callback para saltar al elemento anterior.
  final VoidCallback onSkipPrevious;

  /// Callback para saltar al siguiente elemento.
  final VoidCallback onSkipNext;

  /// Callback para reiniciar la lectura desde el inicio.
  final VoidCallback? onRestart;

  /// Indica si hay una sesión pausada (para mostrar barra de progreso).
  final bool isPaused;

  /// Widget adicional para mostrar al final (ej: menú de opciones).
  final Widget? trailingWidget;

  /// Si es true, distribuye los controles a lo ancho del contenedor.
  final bool distributeAcrossWidth;

  /// Color principal para el botón play/pause y la barra de progreso.
  /// Si es null, usa el colorScheme.primary del tema.
  final Color? primaryColor;

  const AudioPlayerControls({
    super.key,
    required this.isPlaying,
    required this.progress,
    required this.totalItems,
    required this.currentItemIndex,
    required this.onPlayPause,
    required this.onSkipPrevious,
    required this.onSkipNext,
    this.onRestart,
    this.isPaused = false,
    this.trailingWidget,
    this.distributeAcrossWidth = false,
    this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = primaryColor ?? theme.colorScheme.primary;

    // Colores adaptativos.
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: distributeAcrossWidth ? 8 : 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra de progreso (visible durante reproducción y pausa).
          if ((isPlaying || isPaused) && totalItems > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: borderColor,
                valueColor: AlwaysStoppedAnimation<Color>(primary),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

          // Fila de controles de reproducción.
          Row(
            mainAxisAlignment: distributeAcrossWidth
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            children: [
              // Botón de reiniciar con efecto glassmorphism.
              _buildGlassButton(
                context,
                icon: Icons.refresh_rounded,
                onTap: onRestart ?? () {},
              ),
              if (!distributeAcrossWidth) const SizedBox(width: 8),

              // Botón retroceder.
              IconButton(
                icon: Icon(Icons.skip_previous_rounded, color: textColor),
                onPressed: onSkipPrevious,
              ),

              // Botón principal de play/pause con estilo destacado.
              Container(
                decoration: BoxDecoration(
                  color: primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: onPlayPause,
                ),
              ),

              // Botón adelantar.
              IconButton(
                icon: Icon(Icons.skip_next_rounded, color: textColor),
                onPressed: onSkipNext,
              ),

              // Widget adicional si se proporciona.
              if (trailingWidget != null) trailingWidget!,
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un botón circular con efecto glassmorphism (BackdropFilter blur).
  Widget _buildGlassButton(
    BuildContext context, {
    String? label,
    IconData? icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final surfaceColor = theme.colorScheme.surface;

    const double size = 44.0;

    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(size / 2),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                // Fondo con efecto glassmorphism.
                color: isDark
                    ? surfaceColor.withValues(alpha: 0.85)
                    : surfaceColor.withValues(alpha: 0.95),
                shape: BoxShape.circle,
                // Borde sutil.
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  width: 1.5,
                ),
                // Sombra para profundidad.
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: icon != null
                  ? Icon(icon, color: textColor, size: 20)
                  : Text(
                      label!,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.2,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
