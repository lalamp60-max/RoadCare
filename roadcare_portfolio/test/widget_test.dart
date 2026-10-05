import 'package:flutter_test/flutter_test.dart';
import 'package:roadcare_portfolio/main.dart';

void main() {
  testWidgets('RoadCare Portfolio app starts successfully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RoadCarePortfolioApp());

    await tester.pumpAndSettle();

    expect(find.byType(RoadCarePortfolioApp), findsOneWidget);

    expect(find.text('RoadCare'), findsWidgets);

    expect(find.text('Explore Features'), findsOneWidget);
  });
}
