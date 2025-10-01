// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_session_model.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetReadingSessionCollection on Isar {
  IsarCollection<ReadingSession> get readingSessions => this.collection();
}

const ReadingSessionSchema = CollectionSchema(
  name: r'ReadingSession',
  id: -2237521196892654814,
  properties: {
    r'pagesRead': PropertySchema(
      id: 0,
      name: r'pagesRead',
      type: IsarType.long,
    ),
    r'sessionDate': PropertySchema(
      id: 1,
      name: r'sessionDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _readingSessionEstimateSize,
  serialize: _readingSessionSerialize,
  deserialize: _readingSessionDeserialize,
  deserializeProp: _readingSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionDate': IndexSchema(
      id: 2006552208572811236,
      name: r'sessionDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {
    r'book': LinkSchema(
      id: 3585435298874642358,
      name: r'book',
      target: r'Book',
      single: true,
    )
  },
  embeddedSchemas: {},
  getId: _readingSessionGetId,
  getLinks: _readingSessionGetLinks,
  attach: _readingSessionAttach,
  version: '3.1.0+1',
);

int _readingSessionEstimateSize(
  ReadingSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _readingSessionSerialize(
  ReadingSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.pagesRead);
  writer.writeDateTime(offsets[1], object.sessionDate);
}

ReadingSession _readingSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ReadingSession();
  object.id = id;
  object.pagesRead = reader.readLong(offsets[0]);
  object.sessionDate = reader.readDateTime(offsets[1]);
  return object;
}

P _readingSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _readingSessionGetId(ReadingSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _readingSessionGetLinks(ReadingSession object) {
  return [object.book];
}

void _readingSessionAttach(
    IsarCollection<dynamic> col, Id id, ReadingSession object) {
  object.id = id;
  object.book.attach(col, col.isar.collection<Book>(), r'book', id);
}

extension ReadingSessionQueryWhereSort
    on QueryBuilder<ReadingSession, ReadingSession, QWhere> {
  QueryBuilder<ReadingSession, ReadingSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhere> anySessionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionDate'),
      );
    });
  }
}

extension ReadingSessionQueryWhere
    on QueryBuilder<ReadingSession, ReadingSession, QWhereClause> {
  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause>
      sessionDateEqualTo(DateTime sessionDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionDate',
        value: [sessionDate],
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause>
      sessionDateNotEqualTo(DateTime sessionDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDate',
              lower: [],
              upper: [sessionDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDate',
              lower: [sessionDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDate',
              lower: [sessionDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionDate',
              lower: [],
              upper: [sessionDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause>
      sessionDateGreaterThan(
    DateTime sessionDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionDate',
        lower: [sessionDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause>
      sessionDateLessThan(
    DateTime sessionDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionDate',
        lower: [],
        upper: [sessionDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterWhereClause>
      sessionDateBetween(
    DateTime lowerSessionDate,
    DateTime upperSessionDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionDate',
        lower: [lowerSessionDate],
        includeLower: includeLower,
        upper: [upperSessionDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReadingSessionQueryFilter
    on QueryBuilder<ReadingSession, ReadingSession, QFilterCondition> {
  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      pagesReadEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pagesRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      pagesReadGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pagesRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      pagesReadLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pagesRead',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      pagesReadBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pagesRead',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      sessionDateEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      sessionDateGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      sessionDateLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionDate',
        value: value,
      ));
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      sessionDateBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ReadingSessionQueryObject
    on QueryBuilder<ReadingSession, ReadingSession, QFilterCondition> {}

extension ReadingSessionQueryLinks
    on QueryBuilder<ReadingSession, ReadingSession, QFilterCondition> {
  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition> book(
      FilterQuery<Book> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'book');
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterFilterCondition>
      bookIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'book', 0, true, 0, true);
    });
  }
}

extension ReadingSessionQuerySortBy
    on QueryBuilder<ReadingSession, ReadingSession, QSortBy> {
  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy> sortByPagesRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy>
      sortByPagesReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy>
      sortBySessionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy>
      sortBySessionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDate', Sort.desc);
    });
  }
}

extension ReadingSessionQuerySortThenBy
    on QueryBuilder<ReadingSession, ReadingSession, QSortThenBy> {
  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy> thenByPagesRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesRead', Sort.asc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy>
      thenByPagesReadDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pagesRead', Sort.desc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy>
      thenBySessionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDate', Sort.asc);
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QAfterSortBy>
      thenBySessionDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionDate', Sort.desc);
    });
  }
}

extension ReadingSessionQueryWhereDistinct
    on QueryBuilder<ReadingSession, ReadingSession, QDistinct> {
  QueryBuilder<ReadingSession, ReadingSession, QDistinct>
      distinctByPagesRead() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pagesRead');
    });
  }

  QueryBuilder<ReadingSession, ReadingSession, QDistinct>
      distinctBySessionDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionDate');
    });
  }
}

extension ReadingSessionQueryProperty
    on QueryBuilder<ReadingSession, ReadingSession, QQueryProperty> {
  QueryBuilder<ReadingSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ReadingSession, int, QQueryOperations> pagesReadProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pagesRead');
    });
  }

  QueryBuilder<ReadingSession, DateTime, QQueryOperations>
      sessionDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionDate');
    });
  }
}
