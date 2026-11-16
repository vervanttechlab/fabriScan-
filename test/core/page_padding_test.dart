import 'package:fabriscan/core/widgets/page_padding.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('bottom padding clears the phone navigation bar', (tester) async {
    late EdgeInsets padding;
    await tester.pumpWidget(
      MediaQuery(
        // A 3-button navigation bar: 40 dp at the bottom (edge-to-edge).
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 40)),
        child: Builder(
          builder: (context) {
            padding = pagePadding(context, top: 12);
            return const SizedBox();
          },
        ),
      ),
    );
    expect(padding, const EdgeInsets.fromLTRB(16, 12, 16, 64));
  });
}
