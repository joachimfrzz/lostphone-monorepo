import 'package:flutter_test/flutter_test.dart';
import 'package:lost_phone_proto/main.dart';

void main() {
  testWidgets('le prototype démarre sur le verrouillage', (tester) async {
    await tester.pumpWidget(const LostPhoneProto());
    expect(find.text('19:47'), findsWidgets);
  });
}
