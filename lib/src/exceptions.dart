part of postgres.connection;

/// The severity level of a [PostgreSQLException].
///
/// [panic] and [fatal] errors will close the connection.
enum PostgreSQLSeverity {
  /// A [PostgreSQLException] with this severity indicates the throwing connection is now closed.
  panic,

  /// A [PostgreSQLException] with this severity indicates the throwing connection is now closed.
  fatal,

  /// A [PostgreSQLException] with this severity indicates the throwing connection encountered an error when executing a query and the query has failed.
  error,

  /// Currently unsupported.
  warning,

  /// Currently unsupported.
  notice,

  /// Currently unsupported.
  debug,

  /// Currently unsupported.
  info,

  /// Currently unsupported.
  log,

  /// A [PostgreSQLException] with this severity indicates a failed a precondition or other error that doesn't originate from the database.
  unknown
}

/// Exception thrown by [PostgreSQLConnection] instances.
class PostgreSQLException implements Exception {
  PostgreSQLException(String message,
      {PostgreSQLSeverity severity: PostgreSQLSeverity.error,
      this.stackTrace}) {
    this.severity = severity;
    this.message = message;
    code = "";
  }

  PostgreSQLException._(List<NoticeOrErrorField> errorFields, {this.stackTrace}) {
    var finder = (int identifer) => (errorFields.firstWhere(
        (NoticeOrErrorField e) => e.identificationToken == identifer,
        orElse: () => null));

    severity = NoticeOrErrorField
        .severityFromString(finder(NoticeOrErrorField.SeverityIdentifier).text);
    code = finder(NoticeOrErrorField.CodeIdentifier).text;
    message = finder(NoticeOrErrorField.MessageIdentifier).text;
    detail = finder(NoticeOrErrorField.DetailIdentifier)?.text;
    hint = finder(NoticeOrErrorField.HintIdentifier)?.text;

    internalQuery = finder(NoticeOrErrorField.InternalQueryIdentifier)?.text;
    trace = finder(NoticeOrErrorField.WhereIdentifier)?.text;
    schemaName = finder(NoticeOrErrorField.SchemaIdentifier)?.text;
    tableName = finder(NoticeOrErrorField.TableIdentifier)?.text;
    columnName = finder(NoticeOrErrorField.ColumnIdentifier)?.text;
    dataTypeName = finder(NoticeOrErrorField.DataTypeIdentifier)?.text;
    constraintName = finder(NoticeOrErrorField.ConstraintIdentifier)?.text;
    fileName = finder(NoticeOrErrorField.FileIdentifier)?.text;
    routineName = finder(NoticeOrErrorField.RoutineIdentifier)?.text;

    var i = finder(NoticeOrErrorField.PositionIdentifier)?.text;
    position = (i != null ? int.parse(i) : null);

    i = finder(NoticeOrErrorField.InternalPositionIdentifier)?.text;
    internalPosition = (i != null ? int.parse(i) : null);

    i = finder(NoticeOrErrorField.LineIdentifier)?.text;
    lineNumber = (i != null ? int.parse(i) : null);
  }

  /// The severity of the exception.
  PostgreSQLSeverity severity;

  /// The PostgreSQL error code.
  ///
  /// May be null if the exception was not generated by the database.
  String code;

  /// A message indicating the error.
  String message;

  /// Additional details if provided by the database.
  String detail;

  /// A hint on how to remedy an error, if provided by the database.
  String hint;

  /// An index into an executed query string where an error occurred, if by provided by the database.
  int position;

  /// An index into a query string generated by the database, if provided.
  int internalPosition;

  /// The text of a failed internally-generated command.
  /// This could be, for example, a SQL query issued by a PL/pgSQL function.
  String internalQuery;

  /// An indication of the context in which the error occurred.
  /// Presently this includes a call stack traceback of active procedural language functions and internally-generated queries.
  /// The trace is one entry per line, most recent first.
  String trace;

  /// If the error was associated with a specific database object, the name of the schema containing that object, if any.
  String schemaName;

  /// If the error was associated with a specific table, the name of the table.
  String tableName;

  /// If the error was associated with a specific table column, the name of the column.
  String columnName;

  /// If the error was associated with a specific data type, the name of the data type.
  String dataTypeName;

  /// If the error was associated with a specific constraint, the name of the constraint.
  String constraintName;

  /// The file name of the source-code location where the error was reported.
  String fileName;

  /// The line number of the source-code location where the error was reported.
  int lineNumber;

  /// The name of the source-code routine reporting the error.
  String routineName;

  /// A [StackTrace] if available.
  StackTrace stackTrace;

  String toString() {
    var buff = new StringBuffer("$severity $code: $message ");

    if (detail != null) {
      buff.write("Detail: $detail ");
    }

    if (hint != null) {
      buff.write("Hint: $hint ");
    }

    if (tableName != null) {
      buff.write("Table: $tableName ");
    }

    if (columnName != null) {
      buff.write("Column: $columnName ");
    }

    if (constraintName != null) {
      buff.write("Constraint $constraintName ");
    }

    return buff.toString();
  }
}
