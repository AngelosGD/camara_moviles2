import 'package:flutter/foundation.dart';

import '../data/member_repository.dart';
import '../models/member.dart';

class MemberProvider extends ChangeNotifier {
  final MemberRepository _repository;

  List<Member> _members = <Member>[];
  bool _isLoading = false;
  String? _error;

  MemberProvider(this._repository);

  List<Member> get members => List.unmodifiable(_members);
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMembers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _members = await _repository.getAllMembers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> registerMember(Member member) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.insertMember(member);
      await loadMembers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Member>> searchMembers(String query) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      return await _repository.searchMembers(query);
    } catch (e) {
      _error = e.toString();
      return <Member>[];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMember(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _repository.deleteMember(id);
      await loadMembers();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
