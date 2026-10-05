import 'package:flutter_test/flutter_test.dart';

import 'package:roadcare/main.dart';

void main() {
  testWidgets('RoadCare app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const RoadCareApp());

    expect(find.text('RoadCare'), findsOneWidget);
  });
}
