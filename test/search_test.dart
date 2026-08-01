import 'package:flutter_test/flutter_test.dart';

import 'package:camara_moviles2/data/mock_member_repository.dart';
import 'package:camara_moviles2/models/member.dart';

void main() {
  test('searchMembers encuentra por nombre, apellidos y nombre completo', () async {
    final repo = MockMemberRepository();
    await repo.insertMember(Member(nombre: 'Angel', apellidos: 'Mejia'));
    await repo.insertMember(Member(nombre: 'Angel 2', apellidos: 'Mejia 2'));
    await repo.insertMember(Member(nombre: 'Fer', apellidos: 'Mata'));

    expect((await repo.searchMembers('angel')).length, 2);
    expect((await repo.searchMembers('angel 2 mejia 2')).length, 1);
    expect((await repo.searchMembers('fer mata')).length, 1);
    expect((await repo.searchMembers('zzz')).isEmpty, isTrue);
  });
}
