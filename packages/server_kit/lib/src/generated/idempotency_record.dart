/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

/// A cached idempotency result, keyed by client-supplied idempotency key.
/// Backs IdempotencyStore so a retried mutation replays its cached response
/// (ADR-0006 §4, 30-day window). Maps to/from IdempotencyEntry via
/// ServerpodIdempotencyCacheRepo.
abstract class IdempotencyRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  IdempotencyRecord._({
    this.id,
    required this.key,
    this.value,
    required this.storedAt,
  });

  factory IdempotencyRecord({
    int? id,
    required String key,
    String? value,
    required DateTime storedAt,
  }) = _IdempotencyRecordImpl;

  factory IdempotencyRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return IdempotencyRecord(
      id: jsonSerialization['id'] as int?,
      key: jsonSerialization['key'] as String,
      value: jsonSerialization['value'] as String?,
      storedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['storedAt'],
      ),
    );
  }

  static final t = IdempotencyRecordTable();

  static const db = IdempotencyRecordRepository._();

  @override
  int? id;

  /// The idempotency key (or "<consumer>:<eventId>" for consumer dedup).
  String key;

  /// JSON-encoded cached response; null for side-effect-only (consumer) keys.
  String? value;

  /// When the entry was stored (drives the expiry window).
  DateTime storedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [IdempotencyRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  IdempotencyRecord copyWith({
    int? id,
    String? key,
    String? value,
    DateTime? storedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'sorvete_server_kit.IdempotencyRecord',
      if (id != null) 'id': id,
      'key': key,
      if (value != null) 'value': value,
      'storedAt': storedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'sorvete_server_kit.IdempotencyRecord',
      if (id != null) 'id': id,
      'key': key,
      if (value != null) 'value': value,
      'storedAt': storedAt.toJson(),
    };
  }

  static IdempotencyRecordInclude include() {
    return IdempotencyRecordInclude._();
  }

  static IdempotencyRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<IdempotencyRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdempotencyRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdempotencyRecordTable>? orderByList,
    IdempotencyRecordInclude? include,
  }) {
    return IdempotencyRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IdempotencyRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(IdempotencyRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IdempotencyRecordImpl extends IdempotencyRecord {
  _IdempotencyRecordImpl({
    int? id,
    required String key,
    String? value,
    required DateTime storedAt,
  }) : super._(id: id, key: key, value: value, storedAt: storedAt);

  /// Returns a shallow copy of this [IdempotencyRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  IdempotencyRecord copyWith({
    Object? id = _Undefined,
    String? key,
    Object? value = _Undefined,
    DateTime? storedAt,
  }) {
    return IdempotencyRecord(
      id: id is int? ? id : this.id,
      key: key ?? this.key,
      value: value is String? ? value : this.value,
      storedAt: storedAt ?? this.storedAt,
    );
  }
}

class IdempotencyRecordUpdateTable
    extends _i1.UpdateTable<IdempotencyRecordTable> {
  IdempotencyRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> key(String value) =>
      _i1.ColumnValue(table.key, value);

  _i1.ColumnValue<String, String> value(String? value) =>
      _i1.ColumnValue(table.value, value);

  _i1.ColumnValue<DateTime, DateTime> storedAt(DateTime value) =>
      _i1.ColumnValue(table.storedAt, value);
}

class IdempotencyRecordTable extends _i1.Table<int?> {
  IdempotencyRecordTable({super.tableRelation})
    : super(tableName: 'sorvete_idempotency_cache') {
    updateTable = IdempotencyRecordUpdateTable(this);
    key = _i1.ColumnString('key', this);
    value = _i1.ColumnString('value', this);
    storedAt = _i1.ColumnDateTime('storedAt', this);
  }

  late final IdempotencyRecordUpdateTable updateTable;

  /// The idempotency key (or "<consumer>:<eventId>" for consumer dedup).
  late final _i1.ColumnString key;

  /// JSON-encoded cached response; null for side-effect-only (consumer) keys.
  late final _i1.ColumnString value;

  /// When the entry was stored (drives the expiry window).
  late final _i1.ColumnDateTime storedAt;

  @override
  List<_i1.Column> get columns => [id, key, value, storedAt];
}

class IdempotencyRecordInclude extends _i1.IncludeObject {
  IdempotencyRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => IdempotencyRecord.t;
}

class IdempotencyRecordIncludeList extends _i1.IncludeList {
  IdempotencyRecordIncludeList._({
    _i1.WhereExpressionBuilder<IdempotencyRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(IdempotencyRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => IdempotencyRecord.t;
}

class IdempotencyRecordRepository {
  const IdempotencyRecordRepository._();

  /// Returns a list of [IdempotencyRecord]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<IdempotencyRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdempotencyRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdempotencyRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdempotencyRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<IdempotencyRecord>(
      where: where?.call(IdempotencyRecord.t),
      orderBy: orderBy?.call(IdempotencyRecord.t),
      orderByList: orderByList?.call(IdempotencyRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [IdempotencyRecord] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<IdempotencyRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdempotencyRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<IdempotencyRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<IdempotencyRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<IdempotencyRecord>(
      where: where?.call(IdempotencyRecord.t),
      orderBy: orderBy?.call(IdempotencyRecord.t),
      orderByList: orderByList?.call(IdempotencyRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [IdempotencyRecord] by its [id] or null if no such row exists.
  Future<IdempotencyRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<IdempotencyRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [IdempotencyRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [IdempotencyRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<IdempotencyRecord>> insert(
    _i1.DatabaseSession session,
    List<IdempotencyRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<IdempotencyRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [IdempotencyRecord] and returns the inserted row.
  ///
  /// The returned [IdempotencyRecord] will have its `id` field set.
  Future<IdempotencyRecord> insertRow(
    _i1.DatabaseSession session,
    IdempotencyRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<IdempotencyRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [IdempotencyRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<IdempotencyRecord>> update(
    _i1.DatabaseSession session,
    List<IdempotencyRecord> rows, {
    _i1.ColumnSelections<IdempotencyRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<IdempotencyRecord>(
      rows,
      columns: columns?.call(IdempotencyRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IdempotencyRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<IdempotencyRecord> updateRow(
    _i1.DatabaseSession session,
    IdempotencyRecord row, {
    _i1.ColumnSelections<IdempotencyRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<IdempotencyRecord>(
      row,
      columns: columns?.call(IdempotencyRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [IdempotencyRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<IdempotencyRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<IdempotencyRecordUpdateTable>
    columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<IdempotencyRecord>(
      id,
      columnValues: columnValues(IdempotencyRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [IdempotencyRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<IdempotencyRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<IdempotencyRecordUpdateTable>
    columnValues,
    required _i1.WhereExpressionBuilder<IdempotencyRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<IdempotencyRecordTable>? orderBy,
    _i1.OrderByListBuilder<IdempotencyRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<IdempotencyRecord>(
      columnValues: columnValues(IdempotencyRecord.t.updateTable),
      where: where(IdempotencyRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(IdempotencyRecord.t),
      orderByList: orderByList?.call(IdempotencyRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [IdempotencyRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<IdempotencyRecord>> delete(
    _i1.DatabaseSession session,
    List<IdempotencyRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<IdempotencyRecord>(rows, transaction: transaction);
  }

  /// Deletes a single [IdempotencyRecord].
  Future<IdempotencyRecord> deleteRow(
    _i1.DatabaseSession session,
    IdempotencyRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<IdempotencyRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<IdempotencyRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IdempotencyRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<IdempotencyRecord>(
      where: where(IdempotencyRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<IdempotencyRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<IdempotencyRecord>(
      where: where?.call(IdempotencyRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [IdempotencyRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<IdempotencyRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<IdempotencyRecord>(
      where: where(IdempotencyRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
