## O que muda

<!-- Uma ou duas frases. O "por quê" importa mais que o "o quê". -->

## Issue relacionada

<!-- "Closes #12" fecha a issue automaticamente no merge. Se não houver, escreva "nenhuma". -->
Closes #

## Tipo

- [ ] Correção de bug
- [ ] Funcionalidade nova
- [ ] Pipeline / infra
- [ ] Documentação
- [ ] Manutenção / refatoração

## Como testar

<!-- Passo a passo para quem for revisar. Se o PR gerou URL de preview, cole aqui. -->

1.

## Checklist

- [ ] `flutter analyze` sem apontamentos
- [ ] `flutter test` passando
- [ ] Se mexi no schema do banco: rodei `dart run build_runner build --delete-conflicting-outputs` e commitei o `.g.dart`
- [ ] Se incrementei `schemaVersion`: adicionei a `MigrationStrategy` e avisei no grupo
- [ ] PR aponta para `develop` (e não `master`)
- [ ] Testado em pelo menos uma plataforma — qual? <!-- Windows / Android / web -->
