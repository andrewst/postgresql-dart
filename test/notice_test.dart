import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

void main() {
  group("Successful notifications", () {
    var connection = new PostgreSQLConnection("localhost", 5432, "dart_test",
        username: "dart", password: "dart");

    setUp(() async {
      connection = new PostgreSQLConnection("localhost", 5432, "dart_test",
          username: "dart", password: "dart");
      await connection.open();
    });

    tearDown(() async {
      await connection.close();
    });

    test("Notice Response", () async {
      var msgNotice = 'hello, world!';
      var futureMsg = connection.notices.first;
      await connection
          .execute("DO language plpgsql \$\$ "
                   "BEGIN "
                   "RAISE NOTICE '$msgNotice';"
                   "END"
                   "\$\$;");

      var msg = await futureMsg
          .timeout(new Duration(milliseconds: 200));
      expect(msg.message, msgNotice);
    });
  });
}
