import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:folder_authenticator/models/totp_entry.dart';
import 'package:folder_authenticator/services/database_service.dart';

part 'totp_entry_repository.g.dart';

// Provider for the TotpEntryRepository
@riverpod
TotpEntryRepository totpEntryRepository(Ref ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  return TotpEntryRepository(databaseService);
}

// Provider for TOTP entries by folder
@riverpod
Future<List<TotpEntry>> totpEntriesByFolder(
  Ref ref, {
  required int folderId,
}) async {
  final repository = ref.watch(totpEntryRepositoryProvider);
  return repository.getTotpEntriesByFolderId(folderId);
}

class TotpEntryRepository {
  final DatabaseService _databaseService;

  TotpEntryRepository(this._databaseService);

  Future<List<TotpEntry>> getTotpEntriesByFolderId(int folderId) async {
    return await _databaseService.getTotpEntries(folderId: folderId);
  }

  Future<TotpEntry?> getTotpEntry(int id) async {
    return await _databaseService.getTotpEntry(id);
  }

  /// Creates a new TOTP entry in the database.
  /// @retun The ID of the newly created entry.
  Future<int> createTotpEntry(
    String name,
    String secret,
    String issuer,
    int? digits,
    int? period,
    String? algorithm,
    int folderId,
  ) async {
    final id = await _databaseService.insertTotpEntry(
      name,
      secret,
      issuer,
      digits ?? 6,
      period ?? 30,
      algorithm ?? 'SHA1',
      folderId,
    );
    return id;
  }

  Future<bool> updateTotpEntry(
    int id,
    String? name,
    String? issuer,
    int? folderId,
  ) async {
    final rowsAffected = await _databaseService.updateTotpEntry(
      id,
      name,
      issuer,
      folderId,
      DateTime.now(),
    );
    return rowsAffected > 0;
  }

  Future<bool> deleteTotpEntry(int id) async {
    final rowsAffected = await _databaseService.deleteTotpEntry(id);
    return rowsAffected > 0;
  }
}
