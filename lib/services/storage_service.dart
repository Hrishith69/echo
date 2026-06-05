import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_config.dart';
import 'supabase_client.dart';

class StorageService {
  StorageService({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  String get _bucket => SupabaseConfig.storageBucket;

  Future<({String downloadUrl, String storagePath})> uploadVoiceFile({
    required String localPath,
    required String storagePath,
  }) async {
    await _client.storage.from(_bucket).upload(
          storagePath,
          File(localPath),
          fileOptions: const FileOptions(
            contentType: 'audio/aac',
            upsert: true,
          ),
        );
    final url = await getPlaybackUrl(storagePath);
    return (downloadUrl: url, storagePath: storagePath);
  }

  Future<String> getPlaybackUrl(String storagePath) async {
    return _client.storage.from(_bucket).createSignedUrl(
          storagePath,
          60 * 60,
        );
  }
}
