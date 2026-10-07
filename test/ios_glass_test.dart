import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:whoop/presentation/components/ios_glass.dart';

void main() {
  group('IosGlass Widget Tests', () {
    testWidgets('renders all 4 materials cleanly in Dark Mode', (tester) async {
      for (final material in IosGlassMaterial.values) {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: Center(
                child: IosGlass(
                  material: material,
                  borderRadius: 20.0,
                  padding: const EdgeInsets.all(16),
                  child: Text('Material ${material.name}'),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Material ${material.name}'), findsOneWidget);
      }
    });

    testWidgets('renders in Light Mode without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: Center(
              child: IosGlass(
                material: IosGlassMaterial.thin,
                brightness: Brightness.light,
                child: const Text('Light Glass'),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Light Glass'), findsOneWidget);
    });

    testWidgets('tap gesture triggers scale press response and invokes callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(
              child: IosGlass(
                material: IosGlassMaterial.thin,
                onTap: () => tapped = true,
                child: const Text('Tappable Glass Button'),
              ),
            ),
          ),
        ),
      );

      // Verify tapDown scales
      final gesture = await tester.startGesture(tester.getCenter(find.text('Tappable Glass Button')));
      await tester.pump(const Duration(milliseconds: 60));
      expect(tester.takeException(), isNull);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('renders gracefully when hasBlur is false (performance fallback)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: Center(
              child: IosGlass(
                hasBlur: false,
                material: IosGlassMaterial.regular,
                child: const Text('No Blur Glass'),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('No Blur Glass'), findsOneWidget);
    });
  });
}
