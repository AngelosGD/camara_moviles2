import '../models/member.dart';
import 'database_helper.dart';

abstract class MemberRepository {
  Future<int> insertMember(Member member);
  Future<List<Member>> searchMembers(String query);
  Future<List<Member>> getAllMembers();
  Future<int> updateMember(Member member);
  Future<int> deleteMember(int id);
}

class SQLiteMemberRepository implements MemberRepository {
  final DatabaseHelper _helper;

  SQLiteMemberRepository([DatabaseHelper? helper])
      : _helper = helper ?? DatabaseHelper.instance;

  @override
  Future<int> insertMember(Member member) => _helper.insertMember(member);

  @override
  Future<List<Member>> searchMembers(String query) => _helper.searchMembers(query);

  @override
  Future<List<Member>> getAllMembers() => _helper.getAllMembers();

  @override
  Future<int> updateMember(Member member) => _helper.updateMember(member);

  @override
  Future<int> deleteMember(int id) => _helper.deleteMember(id);
}
