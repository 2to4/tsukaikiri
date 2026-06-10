import 'package:flutter/services.dart';

import '../domain/shopping_list.dart';
import 'shopping_list_service.dart';

/// macOS / iOS: EventKit（リマインダー）を使った実装。
/// Swift 側の RemindersPlugin と platform channel で通信する。
class RemindersShoppingListService implements ShoppingListService {
  static const _channel =
      MethodChannel('com.futo4.tsukaikiri/reminders');

  /// リマインダーへのフルアクセス権限をリクエストする。
  /// 初回起動時のオンボーディングで呼ぶ。
  Future<bool> requestAccess() async {
    return await _channel.invokeMethod<bool>('requestAccess') ?? false;
  }

  @override
  Future<List<ShoppingList>> getLists() async {
    final raw =
        await _channel.invokeListMethod<Object?>('getLists') ?? [];
    return raw
        .whereType<Map>()
        .map((m) => ShoppingList(
              id: m['id'] as String,
              name: m['name'] as String,
            ))
        .toList();
  }

  @override
  Future<ShoppingList> createList(String name) async {
    final raw = await _channel
        .invokeMapMethod<String, Object?>('createList', {'name': name});
    if (raw == null) throw PlatformException(code: 'NULL_RESULT');
    return ShoppingList(id: raw['id'] as String, name: raw['name'] as String);
  }

  @override
  Future<int> addItems(String listId, List<ShoppingListItem> items) async {
    final count = await _channel.invokeMethod<int>('addItems', {
      'listId': listId,
      'items': items
          .map((i) => {
                'title': i.title,
                if (i.notes != null) 'notes': i.notes,
              })
          .toList(),
    });
    return count ?? 0;
  }
}
