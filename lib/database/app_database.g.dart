// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $JogadoresTableTable extends JogadoresTable
    with TableInfo<$JogadoresTableTable, JogadorRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JogadoresTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _generoMeta = const VerificationMeta('genero');
  @override
  late final GeneratedColumn<String> genero = GeneratedColumn<String>(
    'genero',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isLevantadorMeta = const VerificationMeta(
    'isLevantador',
  );
  @override
  late final GeneratedColumn<bool> isLevantador = GeneratedColumn<bool>(
    'is_levantador',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_levantador" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _ataqueMeta = const VerificationMeta('ataque');
  @override
  late final GeneratedColumn<int> ataque = GeneratedColumn<int>(
    'ataque',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _defesaMeta = const VerificationMeta('defesa');
  @override
  late final GeneratedColumn<int> defesa = GeneratedColumn<int>(
    'defesa',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _bloqueioMeta = const VerificationMeta(
    'bloqueio',
  );
  @override
  late final GeneratedColumn<int> bloqueio = GeneratedColumn<int>(
    'bloqueio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _saqueMeta = const VerificationMeta('saque');
  @override
  late final GeneratedColumn<int> saque = GeneratedColumn<int>(
    'saque',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _passeMeta = const VerificationMeta('passe');
  @override
  late final GeneratedColumn<int> passe = GeneratedColumn<int>(
    'passe',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _partidasJogadasMeta = const VerificationMeta(
    'partidasJogadas',
  );
  @override
  late final GeneratedColumn<int> partidasJogadas = GeneratedColumn<int>(
    'partidas_jogadas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nome,
    genero,
    isLevantador,
    ataque,
    defesa,
    bloqueio,
    saque,
    passe,
    partidasJogadas,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jogadores';
  @override
  VerificationContext validateIntegrity(
    Insertable<JogadorRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('genero')) {
      context.handle(
        _generoMeta,
        genero.isAcceptableOrUnknown(data['genero']!, _generoMeta),
      );
    } else if (isInserting) {
      context.missing(_generoMeta);
    }
    if (data.containsKey('is_levantador')) {
      context.handle(
        _isLevantadorMeta,
        isLevantador.isAcceptableOrUnknown(
          data['is_levantador']!,
          _isLevantadorMeta,
        ),
      );
    }
    if (data.containsKey('ataque')) {
      context.handle(
        _ataqueMeta,
        ataque.isAcceptableOrUnknown(data['ataque']!, _ataqueMeta),
      );
    }
    if (data.containsKey('defesa')) {
      context.handle(
        _defesaMeta,
        defesa.isAcceptableOrUnknown(data['defesa']!, _defesaMeta),
      );
    }
    if (data.containsKey('bloqueio')) {
      context.handle(
        _bloqueioMeta,
        bloqueio.isAcceptableOrUnknown(data['bloqueio']!, _bloqueioMeta),
      );
    }
    if (data.containsKey('saque')) {
      context.handle(
        _saqueMeta,
        saque.isAcceptableOrUnknown(data['saque']!, _saqueMeta),
      );
    }
    if (data.containsKey('passe')) {
      context.handle(
        _passeMeta,
        passe.isAcceptableOrUnknown(data['passe']!, _passeMeta),
      );
    }
    if (data.containsKey('partidas_jogadas')) {
      context.handle(
        _partidasJogadasMeta,
        partidasJogadas.isAcceptableOrUnknown(
          data['partidas_jogadas']!,
          _partidasJogadasMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  JogadorRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return JogadorRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      genero: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genero'],
      )!,
      isLevantador: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_levantador'],
      )!,
      ataque: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ataque'],
      )!,
      defesa: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}defesa'],
      )!,
      bloqueio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bloqueio'],
      )!,
      saque: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}saque'],
      )!,
      passe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}passe'],
      )!,
      partidasJogadas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}partidas_jogadas'],
      )!,
    );
  }

  @override
  $JogadoresTableTable createAlias(String alias) {
    return $JogadoresTableTable(attachedDatabase, alias);
  }
}

class JogadorRow extends DataClass implements Insertable<JogadorRow> {
  final int id;
  final String nome;
  final String genero;
  final bool isLevantador;
  final int ataque;
  final int defesa;
  final int bloqueio;
  final int saque;
  final int passe;
  final int partidasJogadas;
  const JogadorRow({
    required this.id,
    required this.nome,
    required this.genero,
    required this.isLevantador,
    required this.ataque,
    required this.defesa,
    required this.bloqueio,
    required this.saque,
    required this.passe,
    required this.partidasJogadas,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nome'] = Variable<String>(nome);
    map['genero'] = Variable<String>(genero);
    map['is_levantador'] = Variable<bool>(isLevantador);
    map['ataque'] = Variable<int>(ataque);
    map['defesa'] = Variable<int>(defesa);
    map['bloqueio'] = Variable<int>(bloqueio);
    map['saque'] = Variable<int>(saque);
    map['passe'] = Variable<int>(passe);
    map['partidas_jogadas'] = Variable<int>(partidasJogadas);
    return map;
  }

  JogadoresTableCompanion toCompanion(bool nullToAbsent) {
    return JogadoresTableCompanion(
      id: Value(id),
      nome: Value(nome),
      genero: Value(genero),
      isLevantador: Value(isLevantador),
      ataque: Value(ataque),
      defesa: Value(defesa),
      bloqueio: Value(bloqueio),
      saque: Value(saque),
      passe: Value(passe),
      partidasJogadas: Value(partidasJogadas),
    );
  }

  factory JogadorRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return JogadorRow(
      id: serializer.fromJson<int>(json['id']),
      nome: serializer.fromJson<String>(json['nome']),
      genero: serializer.fromJson<String>(json['genero']),
      isLevantador: serializer.fromJson<bool>(json['isLevantador']),
      ataque: serializer.fromJson<int>(json['ataque']),
      defesa: serializer.fromJson<int>(json['defesa']),
      bloqueio: serializer.fromJson<int>(json['bloqueio']),
      saque: serializer.fromJson<int>(json['saque']),
      passe: serializer.fromJson<int>(json['passe']),
      partidasJogadas: serializer.fromJson<int>(json['partidasJogadas']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nome': serializer.toJson<String>(nome),
      'genero': serializer.toJson<String>(genero),
      'isLevantador': serializer.toJson<bool>(isLevantador),
      'ataque': serializer.toJson<int>(ataque),
      'defesa': serializer.toJson<int>(defesa),
      'bloqueio': serializer.toJson<int>(bloqueio),
      'saque': serializer.toJson<int>(saque),
      'passe': serializer.toJson<int>(passe),
      'partidasJogadas': serializer.toJson<int>(partidasJogadas),
    };
  }

  JogadorRow copyWith({
    int? id,
    String? nome,
    String? genero,
    bool? isLevantador,
    int? ataque,
    int? defesa,
    int? bloqueio,
    int? saque,
    int? passe,
    int? partidasJogadas,
  }) => JogadorRow(
    id: id ?? this.id,
    nome: nome ?? this.nome,
    genero: genero ?? this.genero,
    isLevantador: isLevantador ?? this.isLevantador,
    ataque: ataque ?? this.ataque,
    defesa: defesa ?? this.defesa,
    bloqueio: bloqueio ?? this.bloqueio,
    saque: saque ?? this.saque,
    passe: passe ?? this.passe,
    partidasJogadas: partidasJogadas ?? this.partidasJogadas,
  );
  JogadorRow copyWithCompanion(JogadoresTableCompanion data) {
    return JogadorRow(
      id: data.id.present ? data.id.value : this.id,
      nome: data.nome.present ? data.nome.value : this.nome,
      genero: data.genero.present ? data.genero.value : this.genero,
      isLevantador: data.isLevantador.present
          ? data.isLevantador.value
          : this.isLevantador,
      ataque: data.ataque.present ? data.ataque.value : this.ataque,
      defesa: data.defesa.present ? data.defesa.value : this.defesa,
      bloqueio: data.bloqueio.present ? data.bloqueio.value : this.bloqueio,
      saque: data.saque.present ? data.saque.value : this.saque,
      passe: data.passe.present ? data.passe.value : this.passe,
      partidasJogadas: data.partidasJogadas.present
          ? data.partidasJogadas.value
          : this.partidasJogadas,
    );
  }

  @override
  String toString() {
    return (StringBuffer('JogadorRow(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('genero: $genero, ')
          ..write('isLevantador: $isLevantador, ')
          ..write('ataque: $ataque, ')
          ..write('defesa: $defesa, ')
          ..write('bloqueio: $bloqueio, ')
          ..write('saque: $saque, ')
          ..write('passe: $passe, ')
          ..write('partidasJogadas: $partidasJogadas')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nome,
    genero,
    isLevantador,
    ataque,
    defesa,
    bloqueio,
    saque,
    passe,
    partidasJogadas,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is JogadorRow &&
          other.id == this.id &&
          other.nome == this.nome &&
          other.genero == this.genero &&
          other.isLevantador == this.isLevantador &&
          other.ataque == this.ataque &&
          other.defesa == this.defesa &&
          other.bloqueio == this.bloqueio &&
          other.saque == this.saque &&
          other.passe == this.passe &&
          other.partidasJogadas == this.partidasJogadas);
}

class JogadoresTableCompanion extends UpdateCompanion<JogadorRow> {
  final Value<int> id;
  final Value<String> nome;
  final Value<String> genero;
  final Value<bool> isLevantador;
  final Value<int> ataque;
  final Value<int> defesa;
  final Value<int> bloqueio;
  final Value<int> saque;
  final Value<int> passe;
  final Value<int> partidasJogadas;
  const JogadoresTableCompanion({
    this.id = const Value.absent(),
    this.nome = const Value.absent(),
    this.genero = const Value.absent(),
    this.isLevantador = const Value.absent(),
    this.ataque = const Value.absent(),
    this.defesa = const Value.absent(),
    this.bloqueio = const Value.absent(),
    this.saque = const Value.absent(),
    this.passe = const Value.absent(),
    this.partidasJogadas = const Value.absent(),
  });
  JogadoresTableCompanion.insert({
    this.id = const Value.absent(),
    required String nome,
    required String genero,
    this.isLevantador = const Value.absent(),
    this.ataque = const Value.absent(),
    this.defesa = const Value.absent(),
    this.bloqueio = const Value.absent(),
    this.saque = const Value.absent(),
    this.passe = const Value.absent(),
    this.partidasJogadas = const Value.absent(),
  }) : nome = Value(nome),
       genero = Value(genero);
  static Insertable<JogadorRow> custom({
    Expression<int>? id,
    Expression<String>? nome,
    Expression<String>? genero,
    Expression<bool>? isLevantador,
    Expression<int>? ataque,
    Expression<int>? defesa,
    Expression<int>? bloqueio,
    Expression<int>? saque,
    Expression<int>? passe,
    Expression<int>? partidasJogadas,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nome != null) 'nome': nome,
      if (genero != null) 'genero': genero,
      if (isLevantador != null) 'is_levantador': isLevantador,
      if (ataque != null) 'ataque': ataque,
      if (defesa != null) 'defesa': defesa,
      if (bloqueio != null) 'bloqueio': bloqueio,
      if (saque != null) 'saque': saque,
      if (passe != null) 'passe': passe,
      if (partidasJogadas != null) 'partidas_jogadas': partidasJogadas,
    });
  }

  JogadoresTableCompanion copyWith({
    Value<int>? id,
    Value<String>? nome,
    Value<String>? genero,
    Value<bool>? isLevantador,
    Value<int>? ataque,
    Value<int>? defesa,
    Value<int>? bloqueio,
    Value<int>? saque,
    Value<int>? passe,
    Value<int>? partidasJogadas,
  }) {
    return JogadoresTableCompanion(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      genero: genero ?? this.genero,
      isLevantador: isLevantador ?? this.isLevantador,
      ataque: ataque ?? this.ataque,
      defesa: defesa ?? this.defesa,
      bloqueio: bloqueio ?? this.bloqueio,
      saque: saque ?? this.saque,
      passe: passe ?? this.passe,
      partidasJogadas: partidasJogadas ?? this.partidasJogadas,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (genero.present) {
      map['genero'] = Variable<String>(genero.value);
    }
    if (isLevantador.present) {
      map['is_levantador'] = Variable<bool>(isLevantador.value);
    }
    if (ataque.present) {
      map['ataque'] = Variable<int>(ataque.value);
    }
    if (defesa.present) {
      map['defesa'] = Variable<int>(defesa.value);
    }
    if (bloqueio.present) {
      map['bloqueio'] = Variable<int>(bloqueio.value);
    }
    if (saque.present) {
      map['saque'] = Variable<int>(saque.value);
    }
    if (passe.present) {
      map['passe'] = Variable<int>(passe.value);
    }
    if (partidasJogadas.present) {
      map['partidas_jogadas'] = Variable<int>(partidasJogadas.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JogadoresTableCompanion(')
          ..write('id: $id, ')
          ..write('nome: $nome, ')
          ..write('genero: $genero, ')
          ..write('isLevantador: $isLevantador, ')
          ..write('ataque: $ataque, ')
          ..write('defesa: $defesa, ')
          ..write('bloqueio: $bloqueio, ')
          ..write('saque: $saque, ')
          ..write('passe: $passe, ')
          ..write('partidasJogadas: $partidasJogadas')
          ..write(')'))
        .toString();
  }
}

class $SessoesTableTable extends SessoesTable
    with TableInfo<$SessoesTableTable, SessaoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessoesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _criadaEmMeta = const VerificationMeta(
    'criadaEm',
  );
  @override
  late final GeneratedColumn<int> criadaEm = GeneratedColumn<int>(
    'criada_em',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ativa'),
  );
  static const VerificationMeta _rascunhoAIdsMeta = const VerificationMeta(
    'rascunhoAIds',
  );
  @override
  late final GeneratedColumn<String> rascunhoAIds = GeneratedColumn<String>(
    'rascunho_a_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _rascunhoBIdsMeta = const VerificationMeta(
    'rascunhoBIds',
  );
  @override
  late final GeneratedColumn<String> rascunhoBIds = GeneratedColumn<String>(
    'rascunho_b_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadaEm,
    status,
    rascunhoAIds,
    rascunhoBIds,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessaoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('criada_em')) {
      context.handle(
        _criadaEmMeta,
        criadaEm.isAcceptableOrUnknown(data['criada_em']!, _criadaEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadaEmMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('rascunho_a_ids')) {
      context.handle(
        _rascunhoAIdsMeta,
        rascunhoAIds.isAcceptableOrUnknown(
          data['rascunho_a_ids']!,
          _rascunhoAIdsMeta,
        ),
      );
    }
    if (data.containsKey('rascunho_b_ids')) {
      context.handle(
        _rascunhoBIdsMeta,
        rascunhoBIds.isAcceptableOrUnknown(
          data['rascunho_b_ids']!,
          _rascunhoBIdsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessaoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessaoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      criadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}criada_em'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rascunhoAIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rascunho_a_ids'],
      )!,
      rascunhoBIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rascunho_b_ids'],
      )!,
    );
  }

  @override
  $SessoesTableTable createAlias(String alias) {
    return $SessoesTableTable(attachedDatabase, alias);
  }
}

class SessaoRow extends DataClass implements Insertable<SessaoRow> {
  final int id;
  final int criadaEm;
  final String status;
  final String rascunhoAIds;
  final String rascunhoBIds;
  const SessaoRow({
    required this.id,
    required this.criadaEm,
    required this.status,
    required this.rascunhoAIds,
    required this.rascunhoBIds,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['criada_em'] = Variable<int>(criadaEm);
    map['status'] = Variable<String>(status);
    map['rascunho_a_ids'] = Variable<String>(rascunhoAIds);
    map['rascunho_b_ids'] = Variable<String>(rascunhoBIds);
    return map;
  }

  SessoesTableCompanion toCompanion(bool nullToAbsent) {
    return SessoesTableCompanion(
      id: Value(id),
      criadaEm: Value(criadaEm),
      status: Value(status),
      rascunhoAIds: Value(rascunhoAIds),
      rascunhoBIds: Value(rascunhoBIds),
    );
  }

  factory SessaoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessaoRow(
      id: serializer.fromJson<int>(json['id']),
      criadaEm: serializer.fromJson<int>(json['criadaEm']),
      status: serializer.fromJson<String>(json['status']),
      rascunhoAIds: serializer.fromJson<String>(json['rascunhoAIds']),
      rascunhoBIds: serializer.fromJson<String>(json['rascunhoBIds']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'criadaEm': serializer.toJson<int>(criadaEm),
      'status': serializer.toJson<String>(status),
      'rascunhoAIds': serializer.toJson<String>(rascunhoAIds),
      'rascunhoBIds': serializer.toJson<String>(rascunhoBIds),
    };
  }

  SessaoRow copyWith({
    int? id,
    int? criadaEm,
    String? status,
    String? rascunhoAIds,
    String? rascunhoBIds,
  }) => SessaoRow(
    id: id ?? this.id,
    criadaEm: criadaEm ?? this.criadaEm,
    status: status ?? this.status,
    rascunhoAIds: rascunhoAIds ?? this.rascunhoAIds,
    rascunhoBIds: rascunhoBIds ?? this.rascunhoBIds,
  );
  SessaoRow copyWithCompanion(SessoesTableCompanion data) {
    return SessaoRow(
      id: data.id.present ? data.id.value : this.id,
      criadaEm: data.criadaEm.present ? data.criadaEm.value : this.criadaEm,
      status: data.status.present ? data.status.value : this.status,
      rascunhoAIds: data.rascunhoAIds.present
          ? data.rascunhoAIds.value
          : this.rascunhoAIds,
      rascunhoBIds: data.rascunhoBIds.present
          ? data.rascunhoBIds.value
          : this.rascunhoBIds,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessaoRow(')
          ..write('id: $id, ')
          ..write('criadaEm: $criadaEm, ')
          ..write('status: $status, ')
          ..write('rascunhoAIds: $rascunhoAIds, ')
          ..write('rascunhoBIds: $rascunhoBIds')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, criadaEm, status, rascunhoAIds, rascunhoBIds);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessaoRow &&
          other.id == this.id &&
          other.criadaEm == this.criadaEm &&
          other.status == this.status &&
          other.rascunhoAIds == this.rascunhoAIds &&
          other.rascunhoBIds == this.rascunhoBIds);
}

class SessoesTableCompanion extends UpdateCompanion<SessaoRow> {
  final Value<int> id;
  final Value<int> criadaEm;
  final Value<String> status;
  final Value<String> rascunhoAIds;
  final Value<String> rascunhoBIds;
  const SessoesTableCompanion({
    this.id = const Value.absent(),
    this.criadaEm = const Value.absent(),
    this.status = const Value.absent(),
    this.rascunhoAIds = const Value.absent(),
    this.rascunhoBIds = const Value.absent(),
  });
  SessoesTableCompanion.insert({
    this.id = const Value.absent(),
    required int criadaEm,
    this.status = const Value.absent(),
    this.rascunhoAIds = const Value.absent(),
    this.rascunhoBIds = const Value.absent(),
  }) : criadaEm = Value(criadaEm);
  static Insertable<SessaoRow> custom({
    Expression<int>? id,
    Expression<int>? criadaEm,
    Expression<String>? status,
    Expression<String>? rascunhoAIds,
    Expression<String>? rascunhoBIds,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadaEm != null) 'criada_em': criadaEm,
      if (status != null) 'status': status,
      if (rascunhoAIds != null) 'rascunho_a_ids': rascunhoAIds,
      if (rascunhoBIds != null) 'rascunho_b_ids': rascunhoBIds,
    });
  }

  SessoesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? criadaEm,
    Value<String>? status,
    Value<String>? rascunhoAIds,
    Value<String>? rascunhoBIds,
  }) {
    return SessoesTableCompanion(
      id: id ?? this.id,
      criadaEm: criadaEm ?? this.criadaEm,
      status: status ?? this.status,
      rascunhoAIds: rascunhoAIds ?? this.rascunhoAIds,
      rascunhoBIds: rascunhoBIds ?? this.rascunhoBIds,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (criadaEm.present) {
      map['criada_em'] = Variable<int>(criadaEm.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rascunhoAIds.present) {
      map['rascunho_a_ids'] = Variable<String>(rascunhoAIds.value);
    }
    if (rascunhoBIds.present) {
      map['rascunho_b_ids'] = Variable<String>(rascunhoBIds.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessoesTableCompanion(')
          ..write('id: $id, ')
          ..write('criadaEm: $criadaEm, ')
          ..write('status: $status, ')
          ..write('rascunhoAIds: $rascunhoAIds, ')
          ..write('rascunhoBIds: $rascunhoBIds')
          ..write(')'))
        .toString();
  }
}

class $CheckInsTableTable extends CheckInsTable
    with TableInfo<$CheckInsTableTable, CheckInRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckInsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessaoIdMeta = const VerificationMeta(
    'sessaoId',
  );
  @override
  late final GeneratedColumn<int> sessaoId = GeneratedColumn<int>(
    'sessao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jogadorIdMeta = const VerificationMeta(
    'jogadorId',
  );
  @override
  late final GeneratedColumn<int> jogadorId = GeneratedColumn<int>(
    'jogador_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessaoId, jogadorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckInRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sessao_id')) {
      context.handle(
        _sessaoIdMeta,
        sessaoId.isAcceptableOrUnknown(data['sessao_id']!, _sessaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessaoIdMeta);
    }
    if (data.containsKey('jogador_id')) {
      context.handle(
        _jogadorIdMeta,
        jogadorId.isAcceptableOrUnknown(data['jogador_id']!, _jogadorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_jogadorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sessaoId, jogadorId},
  ];
  @override
  CheckInRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckInRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessao_id'],
      )!,
      jogadorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}jogador_id'],
      )!,
    );
  }

  @override
  $CheckInsTableTable createAlias(String alias) {
    return $CheckInsTableTable(attachedDatabase, alias);
  }
}

class CheckInRow extends DataClass implements Insertable<CheckInRow> {
  final int id;
  final int sessaoId;
  final int jogadorId;
  const CheckInRow({
    required this.id,
    required this.sessaoId,
    required this.jogadorId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sessao_id'] = Variable<int>(sessaoId);
    map['jogador_id'] = Variable<int>(jogadorId);
    return map;
  }

  CheckInsTableCompanion toCompanion(bool nullToAbsent) {
    return CheckInsTableCompanion(
      id: Value(id),
      sessaoId: Value(sessaoId),
      jogadorId: Value(jogadorId),
    );
  }

  factory CheckInRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckInRow(
      id: serializer.fromJson<int>(json['id']),
      sessaoId: serializer.fromJson<int>(json['sessaoId']),
      jogadorId: serializer.fromJson<int>(json['jogadorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessaoId': serializer.toJson<int>(sessaoId),
      'jogadorId': serializer.toJson<int>(jogadorId),
    };
  }

  CheckInRow copyWith({int? id, int? sessaoId, int? jogadorId}) => CheckInRow(
    id: id ?? this.id,
    sessaoId: sessaoId ?? this.sessaoId,
    jogadorId: jogadorId ?? this.jogadorId,
  );
  CheckInRow copyWithCompanion(CheckInsTableCompanion data) {
    return CheckInRow(
      id: data.id.present ? data.id.value : this.id,
      sessaoId: data.sessaoId.present ? data.sessaoId.value : this.sessaoId,
      jogadorId: data.jogadorId.present ? data.jogadorId.value : this.jogadorId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckInRow(')
          ..write('id: $id, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('jogadorId: $jogadorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessaoId, jogadorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckInRow &&
          other.id == this.id &&
          other.sessaoId == this.sessaoId &&
          other.jogadorId == this.jogadorId);
}

class CheckInsTableCompanion extends UpdateCompanion<CheckInRow> {
  final Value<int> id;
  final Value<int> sessaoId;
  final Value<int> jogadorId;
  const CheckInsTableCompanion({
    this.id = const Value.absent(),
    this.sessaoId = const Value.absent(),
    this.jogadorId = const Value.absent(),
  });
  CheckInsTableCompanion.insert({
    this.id = const Value.absent(),
    required int sessaoId,
    required int jogadorId,
  }) : sessaoId = Value(sessaoId),
       jogadorId = Value(jogadorId);
  static Insertable<CheckInRow> custom({
    Expression<int>? id,
    Expression<int>? sessaoId,
    Expression<int>? jogadorId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessaoId != null) 'sessao_id': sessaoId,
      if (jogadorId != null) 'jogador_id': jogadorId,
    });
  }

  CheckInsTableCompanion copyWith({
    Value<int>? id,
    Value<int>? sessaoId,
    Value<int>? jogadorId,
  }) {
    return CheckInsTableCompanion(
      id: id ?? this.id,
      sessaoId: sessaoId ?? this.sessaoId,
      jogadorId: jogadorId ?? this.jogadorId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessaoId.present) {
      map['sessao_id'] = Variable<int>(sessaoId.value);
    }
    if (jogadorId.present) {
      map['jogador_id'] = Variable<int>(jogadorId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckInsTableCompanion(')
          ..write('id: $id, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('jogadorId: $jogadorId')
          ..write(')'))
        .toString();
  }
}

class $PartidasTableTable extends PartidasTable
    with TableInfo<$PartidasTableTable, PartidaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PartidasTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessaoIdMeta = const VerificationMeta(
    'sessaoId',
  );
  @override
  late final GeneratedColumn<int> sessaoId = GeneratedColumn<int>(
    'sessao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeAIdsMeta = const VerificationMeta(
    'timeAIds',
  );
  @override
  late final GeneratedColumn<String> timeAIds = GeneratedColumn<String>(
    'time_a_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeBIdsMeta = const VerificationMeta(
    'timeBIds',
  );
  @override
  late final GeneratedColumn<String> timeBIds = GeneratedColumn<String>(
    'time_b_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placarAMeta = const VerificationMeta(
    'placarA',
  );
  @override
  late final GeneratedColumn<int> placarA = GeneratedColumn<int>(
    'placar_a',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _placarBMeta = const VerificationMeta(
    'placarB',
  );
  @override
  late final GeneratedColumn<int> placarB = GeneratedColumn<int>(
    'placar_b',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('em_andamento'),
  );
  static const VerificationMeta _iniciadaEmMeta = const VerificationMeta(
    'iniciadaEm',
  );
  @override
  late final GeneratedColumn<int> iniciadaEm = GeneratedColumn<int>(
    'iniciada_em',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeANomeMeta = const VerificationMeta(
    'timeANome',
  );
  @override
  late final GeneratedColumn<String> timeANome = GeneratedColumn<String>(
    'time_a_nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Time A'),
  );
  static const VerificationMeta _timeBNomeMeta = const VerificationMeta(
    'timeBNome',
  );
  @override
  late final GeneratedColumn<String> timeBNome = GeneratedColumn<String>(
    'time_b_nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Time B'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessaoId,
    timeAIds,
    timeBIds,
    placarA,
    placarB,
    status,
    iniciadaEm,
    timeANome,
    timeBNome,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'partidas';
  @override
  VerificationContext validateIntegrity(
    Insertable<PartidaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sessao_id')) {
      context.handle(
        _sessaoIdMeta,
        sessaoId.isAcceptableOrUnknown(data['sessao_id']!, _sessaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessaoIdMeta);
    }
    if (data.containsKey('time_a_ids')) {
      context.handle(
        _timeAIdsMeta,
        timeAIds.isAcceptableOrUnknown(data['time_a_ids']!, _timeAIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_timeAIdsMeta);
    }
    if (data.containsKey('time_b_ids')) {
      context.handle(
        _timeBIdsMeta,
        timeBIds.isAcceptableOrUnknown(data['time_b_ids']!, _timeBIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_timeBIdsMeta);
    }
    if (data.containsKey('placar_a')) {
      context.handle(
        _placarAMeta,
        placarA.isAcceptableOrUnknown(data['placar_a']!, _placarAMeta),
      );
    }
    if (data.containsKey('placar_b')) {
      context.handle(
        _placarBMeta,
        placarB.isAcceptableOrUnknown(data['placar_b']!, _placarBMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('iniciada_em')) {
      context.handle(
        _iniciadaEmMeta,
        iniciadaEm.isAcceptableOrUnknown(data['iniciada_em']!, _iniciadaEmMeta),
      );
    } else if (isInserting) {
      context.missing(_iniciadaEmMeta);
    }
    if (data.containsKey('time_a_nome')) {
      context.handle(
        _timeANomeMeta,
        timeANome.isAcceptableOrUnknown(data['time_a_nome']!, _timeANomeMeta),
      );
    }
    if (data.containsKey('time_b_nome')) {
      context.handle(
        _timeBNomeMeta,
        timeBNome.isAcceptableOrUnknown(data['time_b_nome']!, _timeBNomeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PartidaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PartidaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessao_id'],
      )!,
      timeAIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_a_ids'],
      )!,
      timeBIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_b_ids'],
      )!,
      placarA: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}placar_a'],
      )!,
      placarB: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}placar_b'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      iniciadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iniciada_em'],
      )!,
      timeANome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_a_nome'],
      )!,
      timeBNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}time_b_nome'],
      )!,
    );
  }

  @override
  $PartidasTableTable createAlias(String alias) {
    return $PartidasTableTable(attachedDatabase, alias);
  }
}

class PartidaRow extends DataClass implements Insertable<PartidaRow> {
  final int id;
  final int sessaoId;
  final String timeAIds;
  final String timeBIds;
  final int placarA;
  final int placarB;
  final String status;
  final int iniciadaEm;
  final String timeANome;
  final String timeBNome;
  const PartidaRow({
    required this.id,
    required this.sessaoId,
    required this.timeAIds,
    required this.timeBIds,
    required this.placarA,
    required this.placarB,
    required this.status,
    required this.iniciadaEm,
    required this.timeANome,
    required this.timeBNome,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sessao_id'] = Variable<int>(sessaoId);
    map['time_a_ids'] = Variable<String>(timeAIds);
    map['time_b_ids'] = Variable<String>(timeBIds);
    map['placar_a'] = Variable<int>(placarA);
    map['placar_b'] = Variable<int>(placarB);
    map['status'] = Variable<String>(status);
    map['iniciada_em'] = Variable<int>(iniciadaEm);
    map['time_a_nome'] = Variable<String>(timeANome);
    map['time_b_nome'] = Variable<String>(timeBNome);
    return map;
  }

  PartidasTableCompanion toCompanion(bool nullToAbsent) {
    return PartidasTableCompanion(
      id: Value(id),
      sessaoId: Value(sessaoId),
      timeAIds: Value(timeAIds),
      timeBIds: Value(timeBIds),
      placarA: Value(placarA),
      placarB: Value(placarB),
      status: Value(status),
      iniciadaEm: Value(iniciadaEm),
      timeANome: Value(timeANome),
      timeBNome: Value(timeBNome),
    );
  }

  factory PartidaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PartidaRow(
      id: serializer.fromJson<int>(json['id']),
      sessaoId: serializer.fromJson<int>(json['sessaoId']),
      timeAIds: serializer.fromJson<String>(json['timeAIds']),
      timeBIds: serializer.fromJson<String>(json['timeBIds']),
      placarA: serializer.fromJson<int>(json['placarA']),
      placarB: serializer.fromJson<int>(json['placarB']),
      status: serializer.fromJson<String>(json['status']),
      iniciadaEm: serializer.fromJson<int>(json['iniciadaEm']),
      timeANome: serializer.fromJson<String>(json['timeANome']),
      timeBNome: serializer.fromJson<String>(json['timeBNome']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessaoId': serializer.toJson<int>(sessaoId),
      'timeAIds': serializer.toJson<String>(timeAIds),
      'timeBIds': serializer.toJson<String>(timeBIds),
      'placarA': serializer.toJson<int>(placarA),
      'placarB': serializer.toJson<int>(placarB),
      'status': serializer.toJson<String>(status),
      'iniciadaEm': serializer.toJson<int>(iniciadaEm),
      'timeANome': serializer.toJson<String>(timeANome),
      'timeBNome': serializer.toJson<String>(timeBNome),
    };
  }

  PartidaRow copyWith({
    int? id,
    int? sessaoId,
    String? timeAIds,
    String? timeBIds,
    int? placarA,
    int? placarB,
    String? status,
    int? iniciadaEm,
    String? timeANome,
    String? timeBNome,
  }) => PartidaRow(
    id: id ?? this.id,
    sessaoId: sessaoId ?? this.sessaoId,
    timeAIds: timeAIds ?? this.timeAIds,
    timeBIds: timeBIds ?? this.timeBIds,
    placarA: placarA ?? this.placarA,
    placarB: placarB ?? this.placarB,
    status: status ?? this.status,
    iniciadaEm: iniciadaEm ?? this.iniciadaEm,
    timeANome: timeANome ?? this.timeANome,
    timeBNome: timeBNome ?? this.timeBNome,
  );
  PartidaRow copyWithCompanion(PartidasTableCompanion data) {
    return PartidaRow(
      id: data.id.present ? data.id.value : this.id,
      sessaoId: data.sessaoId.present ? data.sessaoId.value : this.sessaoId,
      timeAIds: data.timeAIds.present ? data.timeAIds.value : this.timeAIds,
      timeBIds: data.timeBIds.present ? data.timeBIds.value : this.timeBIds,
      placarA: data.placarA.present ? data.placarA.value : this.placarA,
      placarB: data.placarB.present ? data.placarB.value : this.placarB,
      status: data.status.present ? data.status.value : this.status,
      iniciadaEm: data.iniciadaEm.present
          ? data.iniciadaEm.value
          : this.iniciadaEm,
      timeANome: data.timeANome.present ? data.timeANome.value : this.timeANome,
      timeBNome: data.timeBNome.present ? data.timeBNome.value : this.timeBNome,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PartidaRow(')
          ..write('id: $id, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('timeAIds: $timeAIds, ')
          ..write('timeBIds: $timeBIds, ')
          ..write('placarA: $placarA, ')
          ..write('placarB: $placarB, ')
          ..write('status: $status, ')
          ..write('iniciadaEm: $iniciadaEm, ')
          ..write('timeANome: $timeANome, ')
          ..write('timeBNome: $timeBNome')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessaoId,
    timeAIds,
    timeBIds,
    placarA,
    placarB,
    status,
    iniciadaEm,
    timeANome,
    timeBNome,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PartidaRow &&
          other.id == this.id &&
          other.sessaoId == this.sessaoId &&
          other.timeAIds == this.timeAIds &&
          other.timeBIds == this.timeBIds &&
          other.placarA == this.placarA &&
          other.placarB == this.placarB &&
          other.status == this.status &&
          other.iniciadaEm == this.iniciadaEm &&
          other.timeANome == this.timeANome &&
          other.timeBNome == this.timeBNome);
}

class PartidasTableCompanion extends UpdateCompanion<PartidaRow> {
  final Value<int> id;
  final Value<int> sessaoId;
  final Value<String> timeAIds;
  final Value<String> timeBIds;
  final Value<int> placarA;
  final Value<int> placarB;
  final Value<String> status;
  final Value<int> iniciadaEm;
  final Value<String> timeANome;
  final Value<String> timeBNome;
  const PartidasTableCompanion({
    this.id = const Value.absent(),
    this.sessaoId = const Value.absent(),
    this.timeAIds = const Value.absent(),
    this.timeBIds = const Value.absent(),
    this.placarA = const Value.absent(),
    this.placarB = const Value.absent(),
    this.status = const Value.absent(),
    this.iniciadaEm = const Value.absent(),
    this.timeANome = const Value.absent(),
    this.timeBNome = const Value.absent(),
  });
  PartidasTableCompanion.insert({
    this.id = const Value.absent(),
    required int sessaoId,
    required String timeAIds,
    required String timeBIds,
    this.placarA = const Value.absent(),
    this.placarB = const Value.absent(),
    this.status = const Value.absent(),
    required int iniciadaEm,
    this.timeANome = const Value.absent(),
    this.timeBNome = const Value.absent(),
  }) : sessaoId = Value(sessaoId),
       timeAIds = Value(timeAIds),
       timeBIds = Value(timeBIds),
       iniciadaEm = Value(iniciadaEm);
  static Insertable<PartidaRow> custom({
    Expression<int>? id,
    Expression<int>? sessaoId,
    Expression<String>? timeAIds,
    Expression<String>? timeBIds,
    Expression<int>? placarA,
    Expression<int>? placarB,
    Expression<String>? status,
    Expression<int>? iniciadaEm,
    Expression<String>? timeANome,
    Expression<String>? timeBNome,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessaoId != null) 'sessao_id': sessaoId,
      if (timeAIds != null) 'time_a_ids': timeAIds,
      if (timeBIds != null) 'time_b_ids': timeBIds,
      if (placarA != null) 'placar_a': placarA,
      if (placarB != null) 'placar_b': placarB,
      if (status != null) 'status': status,
      if (iniciadaEm != null) 'iniciada_em': iniciadaEm,
      if (timeANome != null) 'time_a_nome': timeANome,
      if (timeBNome != null) 'time_b_nome': timeBNome,
    });
  }

  PartidasTableCompanion copyWith({
    Value<int>? id,
    Value<int>? sessaoId,
    Value<String>? timeAIds,
    Value<String>? timeBIds,
    Value<int>? placarA,
    Value<int>? placarB,
    Value<String>? status,
    Value<int>? iniciadaEm,
    Value<String>? timeANome,
    Value<String>? timeBNome,
  }) {
    return PartidasTableCompanion(
      id: id ?? this.id,
      sessaoId: sessaoId ?? this.sessaoId,
      timeAIds: timeAIds ?? this.timeAIds,
      timeBIds: timeBIds ?? this.timeBIds,
      placarA: placarA ?? this.placarA,
      placarB: placarB ?? this.placarB,
      status: status ?? this.status,
      iniciadaEm: iniciadaEm ?? this.iniciadaEm,
      timeANome: timeANome ?? this.timeANome,
      timeBNome: timeBNome ?? this.timeBNome,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessaoId.present) {
      map['sessao_id'] = Variable<int>(sessaoId.value);
    }
    if (timeAIds.present) {
      map['time_a_ids'] = Variable<String>(timeAIds.value);
    }
    if (timeBIds.present) {
      map['time_b_ids'] = Variable<String>(timeBIds.value);
    }
    if (placarA.present) {
      map['placar_a'] = Variable<int>(placarA.value);
    }
    if (placarB.present) {
      map['placar_b'] = Variable<int>(placarB.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (iniciadaEm.present) {
      map['iniciada_em'] = Variable<int>(iniciadaEm.value);
    }
    if (timeANome.present) {
      map['time_a_nome'] = Variable<String>(timeANome.value);
    }
    if (timeBNome.present) {
      map['time_b_nome'] = Variable<String>(timeBNome.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PartidasTableCompanion(')
          ..write('id: $id, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('timeAIds: $timeAIds, ')
          ..write('timeBIds: $timeBIds, ')
          ..write('placarA: $placarA, ')
          ..write('placarB: $placarB, ')
          ..write('status: $status, ')
          ..write('iniciadaEm: $iniciadaEm, ')
          ..write('timeANome: $timeANome, ')
          ..write('timeBNome: $timeBNome')
          ..write(')'))
        .toString();
  }
}

class $TimesTableTable extends TimesTable
    with TableInfo<$TimesTableTable, TimeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessaoIdMeta = const VerificationMeta(
    'sessaoId',
  );
  @override
  late final GeneratedColumn<int> sessaoId = GeneratedColumn<int>(
    'sessao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jogadorIdsMeta = const VerificationMeta(
    'jogadorIds',
  );
  @override
  late final GeneratedColumn<String> jogadorIds = GeneratedColumn<String>(
    'jogador_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordemMeta = const VerificationMeta('ordem');
  @override
  late final GeneratedColumn<int> ordem = GeneratedColumn<int>(
    'ordem',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, sessaoId, nome, jogadorIds, ordem];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'times';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sessao_id')) {
      context.handle(
        _sessaoIdMeta,
        sessaoId.isAcceptableOrUnknown(data['sessao_id']!, _sessaoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessaoIdMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('jogador_ids')) {
      context.handle(
        _jogadorIdsMeta,
        jogadorIds.isAcceptableOrUnknown(data['jogador_ids']!, _jogadorIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_jogadorIdsMeta);
    }
    if (data.containsKey('ordem')) {
      context.handle(
        _ordemMeta,
        ordem.isAcceptableOrUnknown(data['ordem']!, _ordemMeta),
      );
    } else if (isInserting) {
      context.missing(_ordemMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sessao_id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      jogadorIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jogador_ids'],
      )!,
      ordem: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordem'],
      )!,
    );
  }

  @override
  $TimesTableTable createAlias(String alias) {
    return $TimesTableTable(attachedDatabase, alias);
  }
}

class TimeRow extends DataClass implements Insertable<TimeRow> {
  final int id;
  final int sessaoId;
  final String nome;
  final String jogadorIds;
  final int ordem;
  const TimeRow({
    required this.id,
    required this.sessaoId,
    required this.nome,
    required this.jogadorIds,
    required this.ordem,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sessao_id'] = Variable<int>(sessaoId);
    map['nome'] = Variable<String>(nome);
    map['jogador_ids'] = Variable<String>(jogadorIds);
    map['ordem'] = Variable<int>(ordem);
    return map;
  }

  TimesTableCompanion toCompanion(bool nullToAbsent) {
    return TimesTableCompanion(
      id: Value(id),
      sessaoId: Value(sessaoId),
      nome: Value(nome),
      jogadorIds: Value(jogadorIds),
      ordem: Value(ordem),
    );
  }

  factory TimeRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeRow(
      id: serializer.fromJson<int>(json['id']),
      sessaoId: serializer.fromJson<int>(json['sessaoId']),
      nome: serializer.fromJson<String>(json['nome']),
      jogadorIds: serializer.fromJson<String>(json['jogadorIds']),
      ordem: serializer.fromJson<int>(json['ordem']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessaoId': serializer.toJson<int>(sessaoId),
      'nome': serializer.toJson<String>(nome),
      'jogadorIds': serializer.toJson<String>(jogadorIds),
      'ordem': serializer.toJson<int>(ordem),
    };
  }

  TimeRow copyWith({
    int? id,
    int? sessaoId,
    String? nome,
    String? jogadorIds,
    int? ordem,
  }) => TimeRow(
    id: id ?? this.id,
    sessaoId: sessaoId ?? this.sessaoId,
    nome: nome ?? this.nome,
    jogadorIds: jogadorIds ?? this.jogadorIds,
    ordem: ordem ?? this.ordem,
  );
  TimeRow copyWithCompanion(TimesTableCompanion data) {
    return TimeRow(
      id: data.id.present ? data.id.value : this.id,
      sessaoId: data.sessaoId.present ? data.sessaoId.value : this.sessaoId,
      nome: data.nome.present ? data.nome.value : this.nome,
      jogadorIds: data.jogadorIds.present
          ? data.jogadorIds.value
          : this.jogadorIds,
      ordem: data.ordem.present ? data.ordem.value : this.ordem,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeRow(')
          ..write('id: $id, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('nome: $nome, ')
          ..write('jogadorIds: $jogadorIds, ')
          ..write('ordem: $ordem')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, sessaoId, nome, jogadorIds, ordem);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeRow &&
          other.id == this.id &&
          other.sessaoId == this.sessaoId &&
          other.nome == this.nome &&
          other.jogadorIds == this.jogadorIds &&
          other.ordem == this.ordem);
}

class TimesTableCompanion extends UpdateCompanion<TimeRow> {
  final Value<int> id;
  final Value<int> sessaoId;
  final Value<String> nome;
  final Value<String> jogadorIds;
  final Value<int> ordem;
  const TimesTableCompanion({
    this.id = const Value.absent(),
    this.sessaoId = const Value.absent(),
    this.nome = const Value.absent(),
    this.jogadorIds = const Value.absent(),
    this.ordem = const Value.absent(),
  });
  TimesTableCompanion.insert({
    this.id = const Value.absent(),
    required int sessaoId,
    required String nome,
    required String jogadorIds,
    required int ordem,
  }) : sessaoId = Value(sessaoId),
       nome = Value(nome),
       jogadorIds = Value(jogadorIds),
       ordem = Value(ordem);
  static Insertable<TimeRow> custom({
    Expression<int>? id,
    Expression<int>? sessaoId,
    Expression<String>? nome,
    Expression<String>? jogadorIds,
    Expression<int>? ordem,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessaoId != null) 'sessao_id': sessaoId,
      if (nome != null) 'nome': nome,
      if (jogadorIds != null) 'jogador_ids': jogadorIds,
      if (ordem != null) 'ordem': ordem,
    });
  }

  TimesTableCompanion copyWith({
    Value<int>? id,
    Value<int>? sessaoId,
    Value<String>? nome,
    Value<String>? jogadorIds,
    Value<int>? ordem,
  }) {
    return TimesTableCompanion(
      id: id ?? this.id,
      sessaoId: sessaoId ?? this.sessaoId,
      nome: nome ?? this.nome,
      jogadorIds: jogadorIds ?? this.jogadorIds,
      ordem: ordem ?? this.ordem,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessaoId.present) {
      map['sessao_id'] = Variable<int>(sessaoId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (jogadorIds.present) {
      map['jogador_ids'] = Variable<String>(jogadorIds.value);
    }
    if (ordem.present) {
      map['ordem'] = Variable<int>(ordem.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimesTableCompanion(')
          ..write('id: $id, ')
          ..write('sessaoId: $sessaoId, ')
          ..write('nome: $nome, ')
          ..write('jogadorIds: $jogadorIds, ')
          ..write('ordem: $ordem')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $JogadoresTableTable jogadoresTable = $JogadoresTableTable(this);
  late final $SessoesTableTable sessoesTable = $SessoesTableTable(this);
  late final $CheckInsTableTable checkInsTable = $CheckInsTableTable(this);
  late final $PartidasTableTable partidasTable = $PartidasTableTable(this);
  late final $TimesTableTable timesTable = $TimesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    jogadoresTable,
    sessoesTable,
    checkInsTable,
    partidasTable,
    timesTable,
  ];
}

typedef $$JogadoresTableTableCreateCompanionBuilder =
    JogadoresTableCompanion Function({
      Value<int> id,
      required String nome,
      required String genero,
      Value<bool> isLevantador,
      Value<int> ataque,
      Value<int> defesa,
      Value<int> bloqueio,
      Value<int> saque,
      Value<int> passe,
      Value<int> partidasJogadas,
    });
typedef $$JogadoresTableTableUpdateCompanionBuilder =
    JogadoresTableCompanion Function({
      Value<int> id,
      Value<String> nome,
      Value<String> genero,
      Value<bool> isLevantador,
      Value<int> ataque,
      Value<int> defesa,
      Value<int> bloqueio,
      Value<int> saque,
      Value<int> passe,
      Value<int> partidasJogadas,
    });

class $$JogadoresTableTableFilterComposer
    extends Composer<_$AppDatabase, $JogadoresTableTable> {
  $$JogadoresTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genero => $composableBuilder(
    column: $table.genero,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isLevantador => $composableBuilder(
    column: $table.isLevantador,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ataque => $composableBuilder(
    column: $table.ataque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defesa => $composableBuilder(
    column: $table.defesa,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bloqueio => $composableBuilder(
    column: $table.bloqueio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get saque => $composableBuilder(
    column: $table.saque,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passe => $composableBuilder(
    column: $table.passe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get partidasJogadas => $composableBuilder(
    column: $table.partidasJogadas,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JogadoresTableTableOrderingComposer
    extends Composer<_$AppDatabase, $JogadoresTableTable> {
  $$JogadoresTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genero => $composableBuilder(
    column: $table.genero,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isLevantador => $composableBuilder(
    column: $table.isLevantador,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ataque => $composableBuilder(
    column: $table.ataque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defesa => $composableBuilder(
    column: $table.defesa,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bloqueio => $composableBuilder(
    column: $table.bloqueio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get saque => $composableBuilder(
    column: $table.saque,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passe => $composableBuilder(
    column: $table.passe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get partidasJogadas => $composableBuilder(
    column: $table.partidasJogadas,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JogadoresTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $JogadoresTableTable> {
  $$JogadoresTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get genero =>
      $composableBuilder(column: $table.genero, builder: (column) => column);

  GeneratedColumn<bool> get isLevantador => $composableBuilder(
    column: $table.isLevantador,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ataque =>
      $composableBuilder(column: $table.ataque, builder: (column) => column);

  GeneratedColumn<int> get defesa =>
      $composableBuilder(column: $table.defesa, builder: (column) => column);

  GeneratedColumn<int> get bloqueio =>
      $composableBuilder(column: $table.bloqueio, builder: (column) => column);

  GeneratedColumn<int> get saque =>
      $composableBuilder(column: $table.saque, builder: (column) => column);

  GeneratedColumn<int> get passe =>
      $composableBuilder(column: $table.passe, builder: (column) => column);

  GeneratedColumn<int> get partidasJogadas => $composableBuilder(
    column: $table.partidasJogadas,
    builder: (column) => column,
  );
}

class $$JogadoresTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $JogadoresTableTable,
          JogadorRow,
          $$JogadoresTableTableFilterComposer,
          $$JogadoresTableTableOrderingComposer,
          $$JogadoresTableTableAnnotationComposer,
          $$JogadoresTableTableCreateCompanionBuilder,
          $$JogadoresTableTableUpdateCompanionBuilder,
          (
            JogadorRow,
            BaseReferences<_$AppDatabase, $JogadoresTableTable, JogadorRow>,
          ),
          JogadorRow,
          PrefetchHooks Function()
        > {
  $$JogadoresTableTableTableManager(
    _$AppDatabase db,
    $JogadoresTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JogadoresTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JogadoresTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JogadoresTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> genero = const Value.absent(),
                Value<bool> isLevantador = const Value.absent(),
                Value<int> ataque = const Value.absent(),
                Value<int> defesa = const Value.absent(),
                Value<int> bloqueio = const Value.absent(),
                Value<int> saque = const Value.absent(),
                Value<int> passe = const Value.absent(),
                Value<int> partidasJogadas = const Value.absent(),
              }) => JogadoresTableCompanion(
                id: id,
                nome: nome,
                genero: genero,
                isLevantador: isLevantador,
                ataque: ataque,
                defesa: defesa,
                bloqueio: bloqueio,
                saque: saque,
                passe: passe,
                partidasJogadas: partidasJogadas,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nome,
                required String genero,
                Value<bool> isLevantador = const Value.absent(),
                Value<int> ataque = const Value.absent(),
                Value<int> defesa = const Value.absent(),
                Value<int> bloqueio = const Value.absent(),
                Value<int> saque = const Value.absent(),
                Value<int> passe = const Value.absent(),
                Value<int> partidasJogadas = const Value.absent(),
              }) => JogadoresTableCompanion.insert(
                id: id,
                nome: nome,
                genero: genero,
                isLevantador: isLevantador,
                ataque: ataque,
                defesa: defesa,
                bloqueio: bloqueio,
                saque: saque,
                passe: passe,
                partidasJogadas: partidasJogadas,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JogadoresTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $JogadoresTableTable,
      JogadorRow,
      $$JogadoresTableTableFilterComposer,
      $$JogadoresTableTableOrderingComposer,
      $$JogadoresTableTableAnnotationComposer,
      $$JogadoresTableTableCreateCompanionBuilder,
      $$JogadoresTableTableUpdateCompanionBuilder,
      (
        JogadorRow,
        BaseReferences<_$AppDatabase, $JogadoresTableTable, JogadorRow>,
      ),
      JogadorRow,
      PrefetchHooks Function()
    >;
typedef $$SessoesTableTableCreateCompanionBuilder =
    SessoesTableCompanion Function({
      Value<int> id,
      required int criadaEm,
      Value<String> status,
      Value<String> rascunhoAIds,
      Value<String> rascunhoBIds,
    });
typedef $$SessoesTableTableUpdateCompanionBuilder =
    SessoesTableCompanion Function({
      Value<int> id,
      Value<int> criadaEm,
      Value<String> status,
      Value<String> rascunhoAIds,
      Value<String> rascunhoBIds,
    });

class $$SessoesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SessoesTableTable> {
  $$SessoesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rascunhoAIds => $composableBuilder(
    column: $table.rascunhoAIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rascunhoBIds => $composableBuilder(
    column: $table.rascunhoBIds,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessoesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SessoesTableTable> {
  $$SessoesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get criadaEm => $composableBuilder(
    column: $table.criadaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rascunhoAIds => $composableBuilder(
    column: $table.rascunhoAIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rascunhoBIds => $composableBuilder(
    column: $table.rascunhoBIds,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessoesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessoesTableTable> {
  $$SessoesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get criadaEm =>
      $composableBuilder(column: $table.criadaEm, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get rascunhoAIds => $composableBuilder(
    column: $table.rascunhoAIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rascunhoBIds => $composableBuilder(
    column: $table.rascunhoBIds,
    builder: (column) => column,
  );
}

class $$SessoesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessoesTableTable,
          SessaoRow,
          $$SessoesTableTableFilterComposer,
          $$SessoesTableTableOrderingComposer,
          $$SessoesTableTableAnnotationComposer,
          $$SessoesTableTableCreateCompanionBuilder,
          $$SessoesTableTableUpdateCompanionBuilder,
          (
            SessaoRow,
            BaseReferences<_$AppDatabase, $SessoesTableTable, SessaoRow>,
          ),
          SessaoRow,
          PrefetchHooks Function()
        > {
  $$SessoesTableTableTableManager(_$AppDatabase db, $SessoesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessoesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessoesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessoesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> criadaEm = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> rascunhoAIds = const Value.absent(),
                Value<String> rascunhoBIds = const Value.absent(),
              }) => SessoesTableCompanion(
                id: id,
                criadaEm: criadaEm,
                status: status,
                rascunhoAIds: rascunhoAIds,
                rascunhoBIds: rascunhoBIds,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int criadaEm,
                Value<String> status = const Value.absent(),
                Value<String> rascunhoAIds = const Value.absent(),
                Value<String> rascunhoBIds = const Value.absent(),
              }) => SessoesTableCompanion.insert(
                id: id,
                criadaEm: criadaEm,
                status: status,
                rascunhoAIds: rascunhoAIds,
                rascunhoBIds: rascunhoBIds,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessoesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessoesTableTable,
      SessaoRow,
      $$SessoesTableTableFilterComposer,
      $$SessoesTableTableOrderingComposer,
      $$SessoesTableTableAnnotationComposer,
      $$SessoesTableTableCreateCompanionBuilder,
      $$SessoesTableTableUpdateCompanionBuilder,
      (SessaoRow, BaseReferences<_$AppDatabase, $SessoesTableTable, SessaoRow>),
      SessaoRow,
      PrefetchHooks Function()
    >;
typedef $$CheckInsTableTableCreateCompanionBuilder =
    CheckInsTableCompanion Function({
      Value<int> id,
      required int sessaoId,
      required int jogadorId,
    });
typedef $$CheckInsTableTableUpdateCompanionBuilder =
    CheckInsTableCompanion Function({
      Value<int> id,
      Value<int> sessaoId,
      Value<int> jogadorId,
    });

class $$CheckInsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CheckInsTableTable> {
  $$CheckInsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessaoId => $composableBuilder(
    column: $table.sessaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get jogadorId => $composableBuilder(
    column: $table.jogadorId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CheckInsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckInsTableTable> {
  $$CheckInsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessaoId => $composableBuilder(
    column: $table.sessaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get jogadorId => $composableBuilder(
    column: $table.jogadorId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CheckInsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckInsTableTable> {
  $$CheckInsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessaoId =>
      $composableBuilder(column: $table.sessaoId, builder: (column) => column);

  GeneratedColumn<int> get jogadorId =>
      $composableBuilder(column: $table.jogadorId, builder: (column) => column);
}

class $$CheckInsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckInsTableTable,
          CheckInRow,
          $$CheckInsTableTableFilterComposer,
          $$CheckInsTableTableOrderingComposer,
          $$CheckInsTableTableAnnotationComposer,
          $$CheckInsTableTableCreateCompanionBuilder,
          $$CheckInsTableTableUpdateCompanionBuilder,
          (
            CheckInRow,
            BaseReferences<_$AppDatabase, $CheckInsTableTable, CheckInRow>,
          ),
          CheckInRow,
          PrefetchHooks Function()
        > {
  $$CheckInsTableTableTableManager(_$AppDatabase db, $CheckInsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckInsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckInsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckInsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessaoId = const Value.absent(),
                Value<int> jogadorId = const Value.absent(),
              }) => CheckInsTableCompanion(
                id: id,
                sessaoId: sessaoId,
                jogadorId: jogadorId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessaoId,
                required int jogadorId,
              }) => CheckInsTableCompanion.insert(
                id: id,
                sessaoId: sessaoId,
                jogadorId: jogadorId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CheckInsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckInsTableTable,
      CheckInRow,
      $$CheckInsTableTableFilterComposer,
      $$CheckInsTableTableOrderingComposer,
      $$CheckInsTableTableAnnotationComposer,
      $$CheckInsTableTableCreateCompanionBuilder,
      $$CheckInsTableTableUpdateCompanionBuilder,
      (
        CheckInRow,
        BaseReferences<_$AppDatabase, $CheckInsTableTable, CheckInRow>,
      ),
      CheckInRow,
      PrefetchHooks Function()
    >;
typedef $$PartidasTableTableCreateCompanionBuilder =
    PartidasTableCompanion Function({
      Value<int> id,
      required int sessaoId,
      required String timeAIds,
      required String timeBIds,
      Value<int> placarA,
      Value<int> placarB,
      Value<String> status,
      required int iniciadaEm,
      Value<String> timeANome,
      Value<String> timeBNome,
    });
typedef $$PartidasTableTableUpdateCompanionBuilder =
    PartidasTableCompanion Function({
      Value<int> id,
      Value<int> sessaoId,
      Value<String> timeAIds,
      Value<String> timeBIds,
      Value<int> placarA,
      Value<int> placarB,
      Value<String> status,
      Value<int> iniciadaEm,
      Value<String> timeANome,
      Value<String> timeBNome,
    });

class $$PartidasTableTableFilterComposer
    extends Composer<_$AppDatabase, $PartidasTableTable> {
  $$PartidasTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessaoId => $composableBuilder(
    column: $table.sessaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeAIds => $composableBuilder(
    column: $table.timeAIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeBIds => $composableBuilder(
    column: $table.timeBIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placarA => $composableBuilder(
    column: $table.placarA,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placarB => $composableBuilder(
    column: $table.placarB,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iniciadaEm => $composableBuilder(
    column: $table.iniciadaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeANome => $composableBuilder(
    column: $table.timeANome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timeBNome => $composableBuilder(
    column: $table.timeBNome,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PartidasTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PartidasTableTable> {
  $$PartidasTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessaoId => $composableBuilder(
    column: $table.sessaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeAIds => $composableBuilder(
    column: $table.timeAIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeBIds => $composableBuilder(
    column: $table.timeBIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placarA => $composableBuilder(
    column: $table.placarA,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placarB => $composableBuilder(
    column: $table.placarB,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iniciadaEm => $composableBuilder(
    column: $table.iniciadaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeANome => $composableBuilder(
    column: $table.timeANome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timeBNome => $composableBuilder(
    column: $table.timeBNome,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PartidasTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PartidasTableTable> {
  $$PartidasTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessaoId =>
      $composableBuilder(column: $table.sessaoId, builder: (column) => column);

  GeneratedColumn<String> get timeAIds =>
      $composableBuilder(column: $table.timeAIds, builder: (column) => column);

  GeneratedColumn<String> get timeBIds =>
      $composableBuilder(column: $table.timeBIds, builder: (column) => column);

  GeneratedColumn<int> get placarA =>
      $composableBuilder(column: $table.placarA, builder: (column) => column);

  GeneratedColumn<int> get placarB =>
      $composableBuilder(column: $table.placarB, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get iniciadaEm => $composableBuilder(
    column: $table.iniciadaEm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get timeANome =>
      $composableBuilder(column: $table.timeANome, builder: (column) => column);

  GeneratedColumn<String> get timeBNome =>
      $composableBuilder(column: $table.timeBNome, builder: (column) => column);
}

class $$PartidasTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PartidasTableTable,
          PartidaRow,
          $$PartidasTableTableFilterComposer,
          $$PartidasTableTableOrderingComposer,
          $$PartidasTableTableAnnotationComposer,
          $$PartidasTableTableCreateCompanionBuilder,
          $$PartidasTableTableUpdateCompanionBuilder,
          (
            PartidaRow,
            BaseReferences<_$AppDatabase, $PartidasTableTable, PartidaRow>,
          ),
          PartidaRow,
          PrefetchHooks Function()
        > {
  $$PartidasTableTableTableManager(_$AppDatabase db, $PartidasTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PartidasTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PartidasTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PartidasTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessaoId = const Value.absent(),
                Value<String> timeAIds = const Value.absent(),
                Value<String> timeBIds = const Value.absent(),
                Value<int> placarA = const Value.absent(),
                Value<int> placarB = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> iniciadaEm = const Value.absent(),
                Value<String> timeANome = const Value.absent(),
                Value<String> timeBNome = const Value.absent(),
              }) => PartidasTableCompanion(
                id: id,
                sessaoId: sessaoId,
                timeAIds: timeAIds,
                timeBIds: timeBIds,
                placarA: placarA,
                placarB: placarB,
                status: status,
                iniciadaEm: iniciadaEm,
                timeANome: timeANome,
                timeBNome: timeBNome,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessaoId,
                required String timeAIds,
                required String timeBIds,
                Value<int> placarA = const Value.absent(),
                Value<int> placarB = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int iniciadaEm,
                Value<String> timeANome = const Value.absent(),
                Value<String> timeBNome = const Value.absent(),
              }) => PartidasTableCompanion.insert(
                id: id,
                sessaoId: sessaoId,
                timeAIds: timeAIds,
                timeBIds: timeBIds,
                placarA: placarA,
                placarB: placarB,
                status: status,
                iniciadaEm: iniciadaEm,
                timeANome: timeANome,
                timeBNome: timeBNome,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PartidasTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PartidasTableTable,
      PartidaRow,
      $$PartidasTableTableFilterComposer,
      $$PartidasTableTableOrderingComposer,
      $$PartidasTableTableAnnotationComposer,
      $$PartidasTableTableCreateCompanionBuilder,
      $$PartidasTableTableUpdateCompanionBuilder,
      (
        PartidaRow,
        BaseReferences<_$AppDatabase, $PartidasTableTable, PartidaRow>,
      ),
      PartidaRow,
      PrefetchHooks Function()
    >;
typedef $$TimesTableTableCreateCompanionBuilder =
    TimesTableCompanion Function({
      Value<int> id,
      required int sessaoId,
      required String nome,
      required String jogadorIds,
      required int ordem,
    });
typedef $$TimesTableTableUpdateCompanionBuilder =
    TimesTableCompanion Function({
      Value<int> id,
      Value<int> sessaoId,
      Value<String> nome,
      Value<String> jogadorIds,
      Value<int> ordem,
    });

class $$TimesTableTableFilterComposer
    extends Composer<_$AppDatabase, $TimesTableTable> {
  $$TimesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sessaoId => $composableBuilder(
    column: $table.sessaoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jogadorIds => $composableBuilder(
    column: $table.jogadorIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TimesTableTable> {
  $$TimesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sessaoId => $composableBuilder(
    column: $table.sessaoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jogadorIds => $composableBuilder(
    column: $table.jogadorIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordem => $composableBuilder(
    column: $table.ordem,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimesTableTable> {
  $$TimesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sessaoId =>
      $composableBuilder(column: $table.sessaoId, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get jogadorIds => $composableBuilder(
    column: $table.jogadorIds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordem =>
      $composableBuilder(column: $table.ordem, builder: (column) => column);
}

class $$TimesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimesTableTable,
          TimeRow,
          $$TimesTableTableFilterComposer,
          $$TimesTableTableOrderingComposer,
          $$TimesTableTableAnnotationComposer,
          $$TimesTableTableCreateCompanionBuilder,
          $$TimesTableTableUpdateCompanionBuilder,
          (TimeRow, BaseReferences<_$AppDatabase, $TimesTableTable, TimeRow>),
          TimeRow,
          PrefetchHooks Function()
        > {
  $$TimesTableTableTableManager(_$AppDatabase db, $TimesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessaoId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> jogadorIds = const Value.absent(),
                Value<int> ordem = const Value.absent(),
              }) => TimesTableCompanion(
                id: id,
                sessaoId: sessaoId,
                nome: nome,
                jogadorIds: jogadorIds,
                ordem: ordem,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessaoId,
                required String nome,
                required String jogadorIds,
                required int ordem,
              }) => TimesTableCompanion.insert(
                id: id,
                sessaoId: sessaoId,
                nome: nome,
                jogadorIds: jogadorIds,
                ordem: ordem,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimesTableTable,
      TimeRow,
      $$TimesTableTableFilterComposer,
      $$TimesTableTableOrderingComposer,
      $$TimesTableTableAnnotationComposer,
      $$TimesTableTableCreateCompanionBuilder,
      $$TimesTableTableUpdateCompanionBuilder,
      (TimeRow, BaseReferences<_$AppDatabase, $TimesTableTable, TimeRow>),
      TimeRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$JogadoresTableTableTableManager get jogadoresTable =>
      $$JogadoresTableTableTableManager(_db, _db.jogadoresTable);
  $$SessoesTableTableTableManager get sessoesTable =>
      $$SessoesTableTableTableManager(_db, _db.sessoesTable);
  $$CheckInsTableTableTableManager get checkInsTable =>
      $$CheckInsTableTableTableManager(_db, _db.checkInsTable);
  $$PartidasTableTableTableManager get partidasTable =>
      $$PartidasTableTableTableManager(_db, _db.partidasTable);
  $$TimesTableTableTableManager get timesTable =>
      $$TimesTableTableTableManager(_db, _db.timesTable);
}
