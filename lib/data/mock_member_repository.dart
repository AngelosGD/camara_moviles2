import '../models/member.dart';
import 'member_repository.dart';

class MockMemberRepository implements MemberRepository {
  final List<Member> _members = <Member>[];

  @override
  Future<int> insertMember(Member member) async {
    _members.add(member);
    return _members.length;
  }

  @override
  Future<List<Member>> searchMembers(String query) async {
    final q = query.trim().toLowerCase();
    return _members.where((member) {
      final fullName = '${member.nombre} ${member.apellidos}'.toLowerCase();
      return member.nombre.toLowerCase().contains(q) ||
          member.apellidos.toLowerCase().contains(q) ||
          fullName.contains(q);
    }).toList();
  }

  @override
  Future<List<Member>> getAllMembers() async => List.unmodifiable(_members);

  @override
  Future<int> updateMember(Member member) async {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index == -1) return 0;
    _members[index] = member;
    return 1;
  }

  @override
  Future<int> deleteMember(int id) async {
    final before = _members.length;
    _members.removeWhere((m) => m.id == id);
    return before - _members.length;
  }
}
