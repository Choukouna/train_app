import 'package:flutter/material.dart';
import 'package:jeusetmatch/dto/constant.dart';

import '../../dto/location.dart';
import '../../dto/rennes_location.dart';

class DialogShower {

  static Future<void> showTemporaryDialog(BuildContext context, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent user from closing it manually
      builder: (context) {
        return AlertDialog(
          content: Row(
            children: [
              const Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );

    // Auto close after 5 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  /// On click on tile, ask to choose or input a location for the slot
  static Future<Location?> pickLocation(BuildContext context) {
    final TextEditingController _locationController = TextEditingController();

    return showModalBottomSheet<Location>(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔹 Rennes main locations
                    listTileLocation(RennesLocation.courtemanche, context),
                    listTileLocation(RennesLocation.brequigny, context),
                    listTileLocation(RennesLocation.beaulieu, context),
                    listTileLocation(RennesLocation.blosne, context),
                    listTileLocation(RennesLocation.gayeulles, context),

                    const Divider(),

                    // 🔹 Custom location input
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _locationController,
                              scrollPadding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).viewInsets.bottom + 80,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Nom du terrain dans cet ordre',
                                hintText: 'Stade, ville, code postal',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.check),
                            onPressed: () {
                              final inputLocation = _locationController.text.trim();
                              if (inputLocation.isEmpty) return;
                              final splitLocation = inputLocation.split(',');
                              Navigator.pop(
                                context,
                                Location(
                                    splitLocation.length > 0 ? splitLocation[0] : Constante.UNKNOWN_CITY,
                                    splitLocation.length > 1 ? splitLocation[1] : Constante.UNKNOWN_CITY,
                                    splitLocation.length > 2 ? int.parse(splitLocation[2]) : 0,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ]
              )
          ),
        );
      },
    );
  }

  static ListTile listTileLocation(Location terrain, BuildContext context) {
    return ListTile(
      title: Text(terrain.stade),
      subtitle: Text(terrain.city + ', ' + terrain.code.toString()),
      onTap: () {
        Navigator.pop(context, terrain);
      },
    );
  }


  /// Popup pour confirmer ou non notre volonté de jouer sur un creneau
  static Future<bool> respondToPlayerRequest(BuildContext context, String? username) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(
              username != null?
              username + ' souhaite jouer avec toi sur ce créneau au  lieu que tu as indiqué. Tu peux accepter ou refuser.':
              'Un joueur souhaite jouer avec toi sur ce créneau au  lieu que tu as indiqué. Tu peux accepter ou refuser.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Refuser'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Accepter'),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}
