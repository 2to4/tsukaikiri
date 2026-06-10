class ShoppingList {
  const ShoppingList({required this.id, required this.name});
  final String id;
  final String name;
}

class ShoppingListItem {
  const ShoppingListItem({required this.title, this.notes});
  final String title;
  final String? notes;
}
