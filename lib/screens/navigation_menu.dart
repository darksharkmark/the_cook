
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:the_cook/screens/csv_image_screen.dart';
import 'package:the_cook/screens/deck_list_screen.dart';
import 'package:the_cook/screens/setting_screen.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {

    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value= index,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: "Card List"),
            NavigationDestination(icon: Icon(Icons.view_carousel), label: "Decks"),
            NavigationDestination(icon: Icon(Icons.view_column), label: "Battle"),
            NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
            
          ]
        ),
      ),

      body: Obx(() => IndexedStack(
        index: controller.selectedIndex.value,
        children: controller.screens,
      )),
    );


  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;


  final screens = [
    const CSVImageScreen(),
    const DeckListScreen(),
    Container(color:Colors.blue),
    const SettingScreen(),
  ];

}
