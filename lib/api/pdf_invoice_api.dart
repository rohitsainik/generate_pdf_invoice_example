import 'dart:io';
import 'package:flutter/services.dart';
import 'package:generate_pdf_invoice_example/api/pdf_api.dart';
import 'package:generate_pdf_invoice_example/base/apiString.dart';
import 'package:generate_pdf_invoice_example/model/customer.dart';
import 'package:generate_pdf_invoice_example/model/invoice.dart';
import 'package:generate_pdf_invoice_example/model/supplier.dart';
import 'package:generate_pdf_invoice_example/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:pdf/widgets.dart';

class PdfInvoiceApi {
  static Future<File> generate(Invoice invoice) async {
    final pdf = Document();
    final font = await rootBundle.load("assets/OpenSans-Regular.ttf");
    final ttf = pdfLib.Font.ttf(font);
    final fontBold = await rootBundle.load("assets/OpenSans-Bold.ttf");
    final ttfBold = pdfLib.Font.ttf(fontBold);

    pdf.addPage(MultiPage(
      theme: pdfLib.ThemeData(
          defaultTextStyle: pdfLib.TextStyle(font: ttf, fontBold: ttfBold)),
      build: (context) => [
        buildTitle(invoice),
        buildHeader(invoice),
        SizedBox(height: 2 * PdfPageFormat.cm),
        buildInvoice(invoice),
        Divider(),
        buildTotal(invoice),
        Divider(),
      ],
      footer: (context) => buildFooter(invoice),
    ));

    return PdfApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }

  //HEADER
  static Widget buildHeader(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildInvoiceInfoLeft(invoice.info),
              buildInvoiceInfoRight(invoice.info),
              // Container(
              //   height: 50,
              //   width: 50,
              //   child: BarcodeWidget(
              //     barcode: Barcode.qrCode(),
              //     data: invoice.info.number,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 1 * PdfPageFormat.cm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildCustomerAddress(invoice.customer),
            ],
          ),
        ],
      );

  static Widget buildCustomerAddress(Customer customer) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(customer.name, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '+91  ${customer.mobileno}',
            style: TextStyle(fontWeight: pdfLib.FontWeight.bold),
          ),
          pdfLib.SizedBox(height: 10),
          Text(customer.address),
        ],
      );

  static Widget buildInvoiceInfoLeft(InvoiceInfo info) {
    final paymentTerms = '${info.dueDate.difference(info.date).inDays} days';
    final titleleft = <String>[
      'TIN Number:',
      'Invoice Number:',
      'Payment Terms:',
    ];

    final dataleft = <String>[
      info.number,
      info.number,
      paymentTerms,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titleleft.length, (index) {
        final title = titleleft[index];
        final value = dataleft[index];

        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildInvoiceInfoRight(InvoiceInfo info) {
    final titleRight = <String>['Invoice Date:', 'Due Date:'];

    final dataright = <String>[
      Utils.formatDate(info.date),
      Utils.formatDate(info.dueDate),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(titleRight.length, (index) {
        final title = titleRight[index];
        final value = dataright[index];
        return buildText(title: title, value: value, width: 200);
      }),
    );
  }

  static Widget buildSupplierAddress(Supplier supplier) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(supplier.name, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 1 * PdfPageFormat.mm),
          Text(supplier.address),
        ],
      );

  //TITLE
  static Widget buildTitle(Invoice invoice) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ApiString.company_Name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 0.2 * PdfPageFormat.cm),
          Text(invoice.info.description),
          SizedBox(height: 0.8 * PdfPageFormat.cm),
        ],
      );

  //INVOICE TABLE
  static Widget buildInvoice(Invoice invoice) {
    final headers = ['S.no', 'Particular', 'Qty', 'Rate', 'Amount'];
    final data = invoice.items.map((item) {
      final total = int.parse(item.unitPrice) * int.parse(item.quantity);

      return [
        item.sno,
        item.description,
        //Utils.formatDate(item.date),
        '${item.quantity}',
        'Rs ${item.unitPrice}',
        //'${item.vat} %',
        'Rs ${total.toStringAsFixed(2)}',
      ];
    }).toList();

    return Table.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: TextStyle(fontWeight: FontWeight.bold),
      headerDecoration: BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: Alignment.centerLeft,
        1: Alignment.centerRight,
        2: Alignment.centerRight,
        3: Alignment.centerRight,
        4: Alignment.centerRight,
      },
    );
  }

  //TOTAL
  static Widget buildTotal(Invoice invoice) {
    final netTotal = invoice.items
        .map((item) =>
            double.parse(item.unitPrice) * double.parse(item.quantity))
        .reduce((item1, item2) => item1 + item2);
    final vatPercent = 19.00;
    final vat = netTotal * vatPercent;
    final total = netTotal + vat;

    return Container(
      alignment: Alignment.centerRight,
      child: Row(
        children: [
          Spacer(flex: 6),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildText(
                  title: 'Net total',
                  value: Utils.formatPrice(netTotal),
                  unite: true,
                ),
                buildText(
                  title: 'Vat ${vatPercent * 100} %',
                  value: Utils.formatPrice(vat),
                  unite: true,
                ),
                Divider(),
                buildText(
                  title: 'Total amount due',
                  titleStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  value: Utils.formatPrice(total),
                  unite: true,
                ),
                SizedBox(height: 2 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
                SizedBox(height: 0.5 * PdfPageFormat.mm),
                Container(height: 1, color: PdfColors.grey400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //FOOTER
  static Widget buildFooter(Invoice invoice) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Expanded(flex: 3, child: buildFooterDescription()),
          Expanded(
            flex: 1,
            child: buildSimpleText(
                title: invoice.supplier.name,
                value: invoice.supplier.address,
                contact: invoice.supplier.contact),
          ),

          // SizedBox(height: 2 * PdfPageFormat.mm),

          // SizedBox(height: 1 * PdfPageFormat.mm),
          // buildSimpleText(title: 'Paypal', value: invoice.supplier.paymentInfo),
        ],
      );

  static buildSimpleText({
    required String title,
    required String value,
    required String contact,
  }) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return pdfLib.Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        Text(
          '+91  ${contact}',
          style: TextStyle(fontWeight: pdfLib.FontWeight.bold),
        ),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value, textAlign: pdfLib.TextAlign.right),
      ],
    );
  }

  static buildFooterDescription() {
    final style = TextStyle(fontSize: 10);

    return Column(
      crossAxisAlignment: pdfLib.CrossAxisAlignment.end,
      children: [
        Bullet(text: ApiString.footer_des_first, style: style),
        Bullet(text: ApiString.footer_des_sec, style: style),
        Bullet(text: ApiString.footer_des_three, style: style),
        Bullet(text: ApiString.footer_des_four, style: style),
      ],
    );
  }

  static buildText({
    required String title,
    required String value,
    double width = double.infinity,
    TextStyle? titleStyle,
    bool unite = false,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: unite ? style : null),
        ],
      ),
    );
  }
}
