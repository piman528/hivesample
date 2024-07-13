import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hivesample/presentation/widgets/map_info_sheet.dart';
import 'package:hivesample/presentation/widgets/map_body.dart';
import 'package:hivesample/presentation/widgets/search_bar.dart';
import 'package:hivesample/provider/mapshapes_provider.dart';
import 'package:hivesample/provider/textfield_word_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CampusMap extends HookConsumerWidget {
  const CampusMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMemoized(DraggableScrollableController.new);
    final textController = useTextEditingController();

    final initialMatrix = useMemoized(
      () => Matrix4.translationValues(-250, -800, 0).scaled(2.6),
    );
    final transformationController = useMemoized(
      () => TransformationController(initialMatrix),
    );

    final pixel = useState<double>(200);
    final previousScale = useRef<double>(initialMatrix.getMaxScaleOnAxis());
    final currentScale = useState<double>(previousScale.value);
    final controllerReset = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    Animation<Matrix4>? animationReset;

    void onAnimateReset() {
      transformationController.value = animationReset!.value;
      if (!controllerReset.isAnimating) {
        animationReset!.removeListener(onAnimateReset);
        animationReset = null;
        controllerReset.reset();
      }
    }

    void onTransformChanged() {
      final double currentScale =
          transformationController.value.getMaxScaleOnAxis();
      if (previousScale.value != currentScale) {
        print('現在の拡大率: $currentScale');
        previousScale.value = currentScale;
        if (currentScale < 5) {}
      }
    }

    void textOnChange() {
      ref.read(textfieldWordNotifierProvider.notifier).set(textController.text);
    }

    useEffect(
      () {
        controller.addListener(() {
          pixel.value = controller.pixels + 10;
        });
        textController.addListener(textOnChange);
        transformationController.addListener(onTransformChanged);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(mapShapesNotifierProvider.notifier).selectShape(null);
          pixel.value = controller.pixels + 10;
        });
        return null;
      },
      [],
    );

    void bottomSheetSizeInitialize(double size) {
      controller.animateTo(
        size,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeIn,
      );
    }

    void animateResetInitialize(Matrix4 destination) {
      if (!controllerReset.isAnimating) {
        controllerReset.reset();
        animationReset = Matrix4Tween(
          begin: transformationController.value,
          end: destination,
        ).chain(CurveTween(curve: Curves.decelerate)).animate(controllerReset);
        animationReset!.addListener(onAnimateReset);
        controllerReset.forward();
        bottomSheetSizeInitialize(0.45);
      }
    }

    ref.listen(mapShapesNotifierProvider, (previous, next) {
      if (next.getSelectShape() != null) {
        final bounds = next.getSelectShape()!.transformedPath!.getBounds();
        final centerX = bounds.left + bounds.width / 2;
        final centerY = bounds.top + bounds.height / 2;
        final scale = (100 / bounds.width + 100 / bounds.height) / 2;
        animateResetInitialize(
          Matrix4.translationValues(
            -centerX * scale + 200,
            -centerY * scale + 250,
            0,
          ).scaled(scale),
        );
      }
    });
    useEffect(
      () {
        final observer = _KeyboardVisibilityObserver(
          ({required bool visible}) {
            if (visible) {
              // bottomSheetSizeInitialize(1);
            }
          },
          context,
        );
        WidgetsBinding.instance.addObserver(observer);
        return () => WidgetsBinding.instance.removeObserver(observer);
      },
      [],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: transformationController,
            maxScale: 15,
            minScale: 2,
            child: SVGMap(
              scale: currentScale.value,
            ),
          ),
          Positioned(
            bottom: pixel.value,
            right: 16,
            child: FloatingActionButton(
              shape: const CircleBorder(), // 丸い形状を指定
              backgroundColor: Colors.white,
              onPressed: () {
                ref.read(mapShapesNotifierProvider.notifier).selectShape(null);
                animateResetInitialize(initialMatrix);
              },
              child: const Icon(Icons.home),
            ),
          ),
          Positioned(
            child: BuildingInfoSheet(controller: controller),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              children: [
                SizedBox(
                  width: 50, // サーチバーの高さと同じ
                  height: 50, // サーチバーの高さと同じ
                  child: FloatingActionButton(
                    shape: const CircleBorder(), // 丸い形状を指定
                    backgroundColor: Colors.white.withOpacity(0.8),
                    onPressed: () {
                      ref
                          .read(mapShapesNotifierProvider.notifier)
                          .selectShape(null);
                      animateResetInitialize(initialMatrix);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius:
                          BorderRadius.circular(25), // 高さの半分で完全な丸みを持たせる,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SearchBarWidget(
                      hintText: '建物を検索',
                      controller: textController,
                      onSubmitted: (_) {
                        ref
                            .read(mapShapesNotifierProvider.notifier)
                            .selectShape(null);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyboardVisibilityObserver with WidgetsBindingObserver {
  _KeyboardVisibilityObserver(this.onChange, this.context);
  final void Function({required bool visible}) onChange;
  final BuildContext context;

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    onChange(visible: bottomInset > 0);
  }
}
