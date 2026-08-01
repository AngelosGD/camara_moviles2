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
  Future<Member?> getMemberByName(String nombre) async {
    final query = nombre.trim().toLowerCase();
    for (final member in _members) {
      if (member.nombre.toLowerCase().contains(query) ||
          member.apellidos.toLowerCase().contains(query)) {
        return member;
      }
    }
    return null;
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
