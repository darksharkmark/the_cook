import'package:flutter/material.dart';
import'package:get/get.dart';
import 'package:the_cook/screens/csv_image_screen.dart';

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
            NavigationDestination(icon: Icon(Icons.view_carousel), label: "Battle"),
            NavigationDestination(icon: Icon(Icons.settings), label: "Settings"),
            
          ]
        ),
      ),

      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );


  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;

  final screens = [const CSVImageScreen(), Container(color:Colors.blue), Container(color:Colors.blue), Container(color:Colors.yellow)]; 

}
