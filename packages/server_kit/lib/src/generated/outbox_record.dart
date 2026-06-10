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

/// A row in a service's outbox table — one domain event awaiting relay to NATS.
/// Written in the same transaction as the domain change (ADR §7). The relay
/// ships unpublished rows and stamps [publishedAt]. Maps to/from the in-memory
/// OutboxEvent in packages/core via ServerpodOutboxRepo.
abstract class OutboxRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  OutboxRecord._({
    this.id,
    required this.eventId,
    required this.type,
    required this.aggregateId,
    required this.occurredAt,
    required this.payload,
    this.publishedAt,
  });

  factory OutboxRecord({
    int? id,
    required String eventId,
    required String type,
    required String aggregateId,
    required DateTime occurredAt,
    required String payload,
    DateTime? publishedAt,
  }) = _OutboxRecordImpl;

  factory OutboxRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return OutboxRecord(
      id: jsonSerialization['id'] as int?,
      eventId: jsonSerialization['eventId'] as String,
      type: jsonSerialization['type'] as String,
      aggregateId: jsonSerialization['aggregateId'] as String,
      occurredAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['occurredAt'],
      ),
      payload: jsonSerialization['payload'] as String,
      publishedAt: jsonSerialization['publishedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(
              jsonSerialization['publishedAt'],
            ),
    );
  }

  static final t = OutboxRecordTable();

  static const db = OutboxRecordRepository._();

  @override
  int? id;

  /// Application-level event id (UUID v7); dedup key for consumers.
  String eventId;

  /// Event type, e.g. "OrderPlaced".
  String type;

  /// Aggregate root id the event is about.
  String aggregateId;

  /// Event time (event-time, may be past-dated for offline replay).
  DateTime occurredAt;

  /// JSON-encoded event payload.
  String payload;

  /// Null until the relay publishes the row to NATS.
  DateTime? publishedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [OutboxRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OutboxRecord copyWith({
    int? id,
    String? eventId,
    String? type,
    String? aggregateId,
    DateTime? occurredAt,
    String? payload,
    DateTime? publishedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'sorvete_server_kit.OutboxRecord',
      if (id != null) 'id': id,
      'eventId': eventId,
      'type': type,
      'aggregateId': aggregateId,
      'occurredAt': occurredAt.toJson(),
      'payload': payload,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'sorvete_server_kit.OutboxRecord',
      if (id != null) 'id': id,
      'eventId': eventId,
      'type': type,
      'aggregateId': aggregateId,
      'occurredAt': occurredAt.toJson(),
      'payload': payload,
      if (publishedAt != null) 'publishedAt': publishedAt?.toJson(),
    };
  }

  static OutboxRecordInclude include() {
    return OutboxRecordInclude._();
  }

  static OutboxRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<OutboxRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OutboxRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OutboxRecordTable>? orderByList,
    OutboxRecordInclude? include,
  }) {
    return OutboxRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutboxRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(OutboxRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OutboxRecordImpl extends OutboxRecord {
  _OutboxRecordImpl({
    int? id,
    required String eventId,
    required String type,
    required String aggregateId,
    required DateTime occurredAt,
    required String payload,
    DateTime? publishedAt,
  }) : super._(
         id: id,
         eventId: eventId,
         type: type,
         aggregateId: aggregateId,
         occurredAt: occurredAt,
         payload: payload,
         publishedAt: publishedAt,
       );

  /// Returns a shallow copy of this [OutboxRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OutboxRecord copyWith({
    Object? id = _Undefined,
    String? eventId,
    String? type,
    String? aggregateId,
    DateTime? occurredAt,
    String? payload,
    Object? publishedAt = _Undefined,
  }) {
    return OutboxRecord(
      id: id is int? ? id : this.id,
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      aggregateId: aggregateId ?? this.aggregateId,
      occurredAt: occurredAt ?? this.occurredAt,
      payload: payload ?? this.payload,
      publishedAt: publishedAt is DateTime? ? publishedAt : this.publishedAt,
    );
  }
}

class OutboxRecordUpdateTable extends _i1.UpdateTable<OutboxRecordTable> {
  OutboxRecordUpdateTable(super.table);

  _i1.ColumnValue<String, String> eventId(String value) =>
      _i1.ColumnValue(table.eventId, value);

  _i1.ColumnValue<String, String> type(String value) =>
      _i1.ColumnValue(table.type, value);

  _i1.ColumnValue<String, String> aggregateId(String value) =>
      _i1.ColumnValue(table.aggregateId, value);

  _i1.ColumnValue<DateTime, DateTime> occurredAt(DateTime value) =>
      _i1.ColumnValue(table.occurredAt, value);

  _i1.ColumnValue<String, String> payload(String value) =>
      _i1.ColumnValue(table.payload, value);

  _i1.ColumnValue<DateTime, DateTime> publishedAt(DateTime? value) =>
      _i1.ColumnValue(table.publishedAt, value);
}

class OutboxRecordTable extends _i1.Table<int?> {
  OutboxRecordTable({super.tableRelation})
    : super(tableName: 'sorvete_outbox') {
    updateTable = OutboxRecordUpdateTable(this);
    eventId = _i1.ColumnString('eventId', this);
    type = _i1.ColumnString('type', this);
    aggregateId = _i1.ColumnString('aggregateId', this);
    occurredAt = _i1.ColumnDateTime('occurredAt', this);
    payload = _i1.ColumnString('payload', this);
    publishedAt = _i1.ColumnDateTime('publishedAt', this);
  }

  late final OutboxRecordUpdateTable updateTable;

  /// Application-level event id (UUID v7); dedup key for consumers.
  late final _i1.ColumnString eventId;

  /// Event type, e.g. "OrderPlaced".
  late final _i1.ColumnString type;

  /// Aggregate root id the event is about.
  late final _i1.ColumnString aggregateId;

  /// Event time (event-time, may be past-dated for offline replay).
  late final _i1.ColumnDateTime occurredAt;

  /// JSON-encoded event payload.
  late final _i1.ColumnString payload;

  /// Null until the relay publishes the row to NATS.
  late final _i1.ColumnDateTime publishedAt;

  @override
  List<_i1.Column> get columns => [
    id,
    eventId,
    type,
    aggregateId,
    occurredAt,
    payload,
    publishedAt,
  ];
}

class OutboxRecordInclude extends _i1.IncludeObject {
  OutboxRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => OutboxRecord.t;
}

class OutboxRecordIncludeList extends _i1.IncludeList {
  OutboxRecordIncludeList._({
    _i1.WhereExpressionBuilder<OutboxRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OutboxRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => OutboxRecord.t;
}

class OutboxRecordRepository {
  const OutboxRecordRepository._();

  /// Returns a list of [OutboxRecord]s matching the given query parameters.
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
  Future<List<OutboxRecord>> find(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OutboxRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OutboxRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OutboxRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<OutboxRecord>(
      where: where?.call(OutboxRecord.t),
      orderBy: orderBy?.call(OutboxRecord.t),
      orderByList: orderByList?.call(OutboxRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [OutboxRecord] matching the given query parameters.
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
  Future<OutboxRecord?> findFirstRow(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OutboxRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<OutboxRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OutboxRecordTable>? orderByList,
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<OutboxRecord>(
      where: where?.call(OutboxRecord.t),
      orderBy: orderBy?.call(OutboxRecord.t),
      orderByList: orderByList?.call(OutboxRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [OutboxRecord] by its [id] or null if no such row exists.
  Future<OutboxRecord?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<OutboxRecord>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [OutboxRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [OutboxRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  Future<List<OutboxRecord>> insert(
    _i1.DatabaseSession session,
    List<OutboxRecord> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<OutboxRecord>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [OutboxRecord] and returns the inserted row.
  ///
  /// The returned [OutboxRecord] will have its `id` field set.
  Future<OutboxRecord> insertRow(
    _i1.DatabaseSession session,
    OutboxRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<OutboxRecord>(row, transaction: transaction);
  }

  /// Updates all [OutboxRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<OutboxRecord>> update(
    _i1.DatabaseSession session,
    List<OutboxRecord> rows, {
    _i1.ColumnSelections<OutboxRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<OutboxRecord>(
      rows,
      columns: columns?.call(OutboxRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OutboxRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OutboxRecord> updateRow(
    _i1.DatabaseSession session,
    OutboxRecord row, {
    _i1.ColumnSelections<OutboxRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<OutboxRecord>(
      row,
      columns: columns?.call(OutboxRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OutboxRecord] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<OutboxRecord?> updateById(
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<OutboxRecordUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<OutboxRecord>(
      id,
      columnValues: columnValues(OutboxRecord.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [OutboxRecord]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<OutboxRecord>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<OutboxRecordUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<OutboxRecordTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OutboxRecordTable>? orderBy,
    _i1.OrderByListBuilder<OutboxRecordTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<OutboxRecord>(
      columnValues: columnValues(OutboxRecord.t.updateTable),
      where: where(OutboxRecord.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OutboxRecord.t),
      orderByList: orderByList?.call(OutboxRecord.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [OutboxRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<OutboxRecord>> delete(
    _i1.DatabaseSession session,
    List<OutboxRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<OutboxRecord>(rows, transaction: transaction);
  }

  /// Deletes a single [OutboxRecord].
  Future<OutboxRecord> deleteRow(
    _i1.DatabaseSession session,
    OutboxRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OutboxRecord>(row, transaction: transaction);
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<OutboxRecord>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OutboxRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<OutboxRecord>(
      where: where(OutboxRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<OutboxRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<OutboxRecord>(
      where: where?.call(OutboxRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [OutboxRecord] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<OutboxRecordTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
  }) async {
    return session.db.lockRows<OutboxRecord>(
      where: where(OutboxRecord.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
