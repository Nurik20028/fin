import 'package:flutter/material.dart';

class Model_Category {
  String name;
  Icon icon;
  bool isSelected;
  Color color;

  Model_Category({
  required this.name,
  required this.icon,
  required this.isSelected,
  required this.color,
});
  static List<Model_Category> getRedCategories() {
    List<Model_Category> redCategories = [];
    redCategories.add(
        Model_Category(
            name: 'Food',
            icon: (const Icon(Icons.fastfood_outlined)),
            color: Colors.red,
            isSelected: false,
        ),
    );
    redCategories.add(
        Model_Category(
            name: 'Transport',
            icon: (const Icon(Icons.emoji_transportation_outlined)),
            isSelected: false,
            color: Colors.red,
        ),
    );
    redCategories.add(
        Model_Category(
            name: 'Hobby/Fun',
            icon: (const Icon(Icons.sports_football_sharp)),
            isSelected: false,
            color: Colors.red,
        ),
    );

    return redCategories;
  }

  static List<Model_Category> getGreenCategories() {
    List<Model_Category> greenCategories = [];
    greenCategories.add(
        Model_Category(
            name: 'Salary',
            icon: (const Icon(Icons.currency_bitcoin_sharp)),
            color: Colors.green,
            isSelected: false,
        ),
    );
    greenCategories.add(
        Model_Category(
            name: 'Gift',
            icon: (const Icon(Icons.card_giftcard_sharp)),
            isSelected: false,
            color: Colors.green,
        ),
    );
    greenCategories.add(
        Model_Category(
            name: 'Bonus',
            icon: (const Icon(Icons.star)),
            isSelected: false,
            color: Colors.green,
        ),
    );
    return greenCategories;
  }
}
