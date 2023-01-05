import 'package:cash_register/services/database.dart';
import 'package:cash_register/models/product.dart';
import 'package:cash_register/models/vat.dart';
import 'package:flutter/material.dart';

Future<void> productModal(BuildContext context, Product product, Function fn) {
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  final measuringUnitController = TextEditingController();
  final productTypeController = TextEditingController();

  nameController.text = product.name;
  codeController.text = product.code;
  descriptionController.text = product.description;
  priceController.text = product.price.toString();
  measuringUnitController.text = product.measuringUnit;
  productTypeController.text = product.productType;

  final formKey = GlobalKey<FormState>();
  Vat vat = Vat.findByProduct(product);

  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            scrollable: true,
            title: Text('${product.id == null ? 'Add' : 'Edit'} product'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a Name';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: codeController,
                        decoration: const InputDecoration(
                          labelText: 'Code',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value == '0.0') {
                            return 'Please enter a Price';
                          }
                          try {
                            double.parse(value);
                          } catch (e) {
                            return 'Price should be a number';
                          }
                          return null;
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: measuringUnitController,
                        decoration: const InputDecoration(
                          labelText: 'Measuring Unit',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: productTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Product Type',
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: DropdownButton<Vat>(
                        value: vat,
                        icon: const Icon(Icons.arrow_drop_down),
                        isExpanded: true,
                        onChanged: (Vat? value) {
                          setState(() {
                            vat = value!;
                          });
                          product.vatName = vat.name;
                          product.vatPercentage = vat.perventage;
                        },
                        items: Vat.list().map<DropdownMenuItem<Vat>>((Vat vat) {
                          return DropdownMenuItem<Vat>(
                            value: vat,
                            child: Text('${vat.name} ${vat.perventage}'),
                          );
                        }).toList(),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      child: CheckboxListTile(
                        title: const Text('Vat Included'),
                        value: product.vatIncluded,
                        onChanged: (bool? value) {
                          setState(() {
                            product.vatIncluded = value!;
                          });
                        },
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                child: const Text('Save', style: TextStyle(color: Colors.white),),
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  // close modal
                  Navigator.pop(context);

                  // save product
                  product.name = nameController.text;
                  product.code = codeController.text;
                  product.description = descriptionController.text;
                  product.price = double.parse(priceController.text);
                  product.measuringUnit = measuringUnitController.text;
                  product.productType = productTypeController.text;
                  await product.save();

                  // callback
                  fn();
                }
              )
            ],
          );
        }
      );
    }
  );
}