import 'package:flutter/material.dart';
import 'package:generate_pdf_invoice_example/api/pdf_api.dart';
import 'package:generate_pdf_invoice_example/api/pdf_invoice_api.dart';
import 'package:generate_pdf_invoice_example/base/apiString.dart';
import 'package:generate_pdf_invoice_example/main.dart';
import 'package:generate_pdf_invoice_example/model/customer.dart';
import 'package:generate_pdf_invoice_example/model/invoice.dart';
import 'package:generate_pdf_invoice_example/model/supplier.dart';
import 'package:generate_pdf_invoice_example/widget/button_widget.dart';
import 'package:generate_pdf_invoice_example/utils.dart';


import 'package:generate_pdf_invoice_example/widget/title_widget.dart';

class PdfPage extends StatefulWidget {
  @override
  _PdfPageState createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _qtyController = TextEditingController();
  TextEditingController _unitpriceController = TextEditingController();
  TextEditingController _customernameController = TextEditingController();
  TextEditingController _customermobileController = TextEditingController();
  TextEditingController _customeraddressController = TextEditingController();
  List<InvoiceItem> newParticulars = [];

  String particulars = '';
  var qty = '';
  var unitprice = '';
  String valueText = '';

  var c_name = '';
  var c_mobile = '';
  var c_address = '';

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(MyApp.title),
          centerTitle: true,
        ),
        body: Container(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Card(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              c_name = value;
                            });
                          },
                          controller: _customernameController,
                          decoration:
                          InputDecoration(hintText: 'Customer Name',labelText: 'Customer Name'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            setState(() {
                              c_mobile = value.toString();
                            });
                          },
                          controller: _customermobileController,
                          decoration:
                          InputDecoration(hintText: 'Customer Contact',labelText: 'Customer Contact'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              c_address = value;
                            });
                          },
                          controller: _customeraddressController,
                          decoration:
                          InputDecoration(hintText: 'Customer Address',labelText: 'Customer Address'),
                        ),
                      ),
                    ],
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Add'),
                    trailing: IconButton(
                      onPressed: () {
                        _displayTextInputDialog(context);
                      },
                      icon: Icon(
                        Icons.add,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: newParticulars.length,
                        itemBuilder: (context, index) {
                          return Card(
                              child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        '${newParticulars[index].date.toString()}'),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ButtonBar(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              newParticulars.removeAt(index);
                                            });
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            _displayTextInputDialog(context);
                                          },
                                          icon: Icon(
                                            Icons.edit,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      newParticulars[index]
                                          .description
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500),
                                    )),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Unit Price : ${newParticulars[index].unitPrice.toString()}'),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Quantity : ${newParticulars[index].quantity.toString()}'),
                                    ),
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Total Price : ${int.parse(newParticulars[index].unitPrice) * int.parse(newParticulars[index].quantity)}'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ));
                        })),
                ButtonWidget(
                  text: 'Invoice PDF',
                  onClicked: () async {
                    final date = DateTime.now();
                    final dueDate = date.add(Duration(days: 7));

                    final invoice = Invoice(
                      supplier: Supplier(
                          name: ApiString.company_Name,
                          address: 'fjklkf hklfdsfh kl fsdafj klfsd',
                          paymentInfo: 'https://paypal.me/sarahfieldzz',
                          contact: '9663524745'),
                      customer: Customer(
                          name: c_name,
                          address: c_address,
                          mobileno: c_mobile),
                      info: InvoiceInfo(
                        date: date,
                        dueDate: dueDate,
                        description: 'Auth distributor For Rajasthan ',
                        number: '${DateTime.now().year}-xyz',
                      ),
                      items: newParticulars
                      // [
                      //   InvoiceItem(
                      //     sno: 1,
                      //     description: 'Coffee',
                      //     date: DateTime.now(),
                      //     quantity: 3,
                      //     vat: 0.19,
                      //     unitPrice: 5.99,
                      //   ),
                      //   InvoiceItem(
                      //     sno: 2,
                      //     description: 'Water',
                      //     date: DateTime.now(),
                      //     quantity: 8,
                      //     vat: 0.19,
                      //     unitPrice: 0.99,
                      //   ),
                      //   InvoiceItem(
                      //     sno: 3,
                      //     description: '',
                      //     date: DateTime.now(),
                      //     quantity: 3,
                      //     vat: 0.19,
                      //     unitPrice: 2.99,
                      //   ),
                      //   InvoiceItem(
                      //     sno: 4,
                      //     description: 'Apple',
                      //     date: DateTime.now(),
                      //     quantity: 8,
                      //     vat: 0.19,
                      //     unitPrice: 3.99,
                      //   ),
                      //   InvoiceItem(
                      //     sno: 5,
                      //     description: 'Mango',
                      //     date: DateTime.now(),
                      //     quantity: 1,
                      //     vat: 0.19,
                      //     unitPrice: 1.59,
                      //   ),
                      //   InvoiceItem(
                      //     sno: 6,
                      //     description: 'Blue Berries',
                      //     date: DateTime.now(),
                      //     quantity: 5,
                      //     vat: 0.19,
                      //     unitPrice: 0.99,
                      //   ),
                      //   InvoiceItem(
                      //     sno: 7,
                      //     description: 'Lemon',
                      //     date: DateTime.now(),
                      //     quantity: 4,
                      //     vat: 0.19,
                      //     unitPrice: 1.29,
                      //   ),
                      // ],
                    );

                    final pdfFile = await PdfInvoiceApi.generate(invoice);

                    PdfApi.openFile(pdfFile);
                  },
                )
              ],
            ),
          ),
        ),

      );

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Particulars'),
            content: Container(
              height: 200,
              child: Column(
                children: [
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        valueText = value;
                      });
                    },
                    controller: _textFieldController,
                    decoration:
                        InputDecoration(hintText: "Add Description"),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        qty = value;
                      });
                    },
                    controller: _qtyController,
                    decoration: InputDecoration(hintText: "Add quantity"),
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        unitprice = value;
                      });
                    },
                    controller: _unitpriceController,
                    decoration: InputDecoration(hintText: "Add UnitPrice"),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              FlatButton(
                color: Colors.green,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () {
                  setState(() {
                    particulars = valueText;
                    newParticulars.add(InvoiceItem(
                        sno: newParticulars.length +1,
                        description: particulars.toString(),
                        quantity: qty,
                        unitPrice: unitprice,
                        vat: 1.9,
                        date: Utils.formatDate(DateTime.now())));
                    _unitpriceController.clear();
                    _textFieldController.clear();
                    _qtyController.clear();
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
