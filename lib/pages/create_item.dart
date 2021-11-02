import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grimm_scanner/models/grimm_item.dart';

class CreateItemScreen extends StatefulWidget {
  static const routeName = '/create_item';

  const CreateItemScreen({Key? key}) : super(key: key);

  @override
  _CreateItemState createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItemScreen> {
  final _key = GlobalKey<FormState>();
  TextEditingController descriptionController = TextEditingController(
      text: "ObjectLouise"); // controlleur de la description
  TextEditingController locationController =
      TextEditingController(text: "C6"); // controlleur du email
  TextEditingController categorieController = TextEditingController(
      text: "CkptVTldFGQLlF0QLRvv"); // controlleur de la catégorie
  TextEditingController remarkController = TextEditingController(
      text: "Pas de remarque"); // controlleur de la remarque

  @override
  Widget build(BuildContext context) {
    GrimmItem grimmItem = GrimmItem(
        //id: "id",
        description: "description",
        location: "location",
        idCategory: "idCategory",
        available: true,
        remark: "remark");

    print("ItemDetail - GrimmItem - " + grimmItem.toString());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Création"),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(50),
          children: <Widget>[
            const Text(
              "Créez un nouvel objet",
              style: TextStyle(
                fontFamily: "Raleway-Regular",
                fontSize: 30.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Le champ 'Nom de l'objet' ne peut pas être vide";
                } else
                  return null;
              },
              decoration: const InputDecoration(
                labelText: "Nom de l'objet",
                labelStyle: TextStyle(
                  fontFamily: "Raleway-Regular",
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              textInputAction: TextInputAction.next,
              cursorColor: Theme.of(context).backgroundColor,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: locationController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Le champ 'Emplacement' ne peut pas être vide";
                } else
                  return null;
              },
              decoration: const InputDecoration(
                labelText: 'Emplacement',
                labelStyle: TextStyle(
                  fontFamily: "Raleway-Regular",
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              textInputAction: TextInputAction.next,
              cursorColor: Theme.of(context).backgroundColor,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: categorieController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le champ "Catégorie" ne peut pas être vide';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                labelText: 'Catégorie',
                labelStyle: TextStyle(
                  fontFamily: "Raleway-Regular",
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              textInputAction: TextInputAction.next,
              cursorColor: Colors.black,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: remarkController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Le champ "Remarque" ne peut pas être vide';
                } else {
                  return null;
                }
              },
              decoration: const InputDecoration(
                labelText: 'Remarque',
                labelStyle: TextStyle(
                  fontFamily: "Raleway-Regular",
                  fontSize: 14.0,
                  color: Colors.black,
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
              textInputAction: TextInputAction.next,
              cursorColor: Colors.black,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).primaryColor,
                  textStyle: const TextStyle(
                      fontFamily: "Raleway-Regular", fontSize: 14.0),
                  side: const BorderSide(width: 1.0, color: Colors.black),
                  padding: const EdgeInsets.all(20.0),
                ),
                onPressed: () async {
                  {
                    if (_key.currentState!.validate()) {
                      GrimmItem item = GrimmItem(
                          description: descriptionController.text,
                          location: locationController.text,
                          remark: remarkController.text,
                          idCategory: categorieController.text,
                          available: true);
                      await item.saveToFirestore();
                      print("Item CREATE" + item.toString());
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Objet créé avec succès")));
                      Navigator.pushNamed(context, "/");
                    }
                  }
                },
                child: Text("VALIDER")),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
