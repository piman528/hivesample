import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CampusMap extends HookConsumerWidget {
  const CampusMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useMemoized(DraggableScrollableController.new);

    final initialMatrix = useMemoized(
      () => Matrix4.translationValues(-250, -750, 0).scaled(2.6),
    );
    final transformationController = useMemoized(
      () => TransformationController(initialMatrix),
    );
    final pixel = useState<double>(200);
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

    useEffect(
      () {
        controller.addListener(() {
          pixel.value = controller.pixels + 10;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.watch(shapeProvider.notifier).state = null;
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
        bottomSheetSizeInitialize(0.5);
      }
    }

    ref.listen(shapeProvider, (previous, next) {
      if (next != null) {
        final bounds = next.mapShape!.transformedPath!.getBounds();
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
              bottomSheetSizeInitialize(1);
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
      appBar: AppBar(
        title: const Text(
          'マップ',
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            transformationController: transformationController,
            maxScale: 15,
            minScale: 2,
            child: const SVGMap(),
          ),
          Positioned(
            bottom: pixel.value,
            right: 16,
            child: FloatingActionButton(
              onPressed: () {
                ref.read(shapeProvider.notifier).state = null;
                animateResetInitialize(initialMatrix);
              },
              child: const Icon(Icons.home),
            ),
          ),
          BuildingInfoSheet(controller: controller),
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
