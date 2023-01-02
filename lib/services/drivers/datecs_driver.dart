import 'dart:typed_data';
import 'package:cash_register/models/docs/tax_receipt.dart';
import 'package:cash_register/models/docs/tax_receipt_product.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

void debugPrint(Object? object) {
  print(object);
}

class DatecsDriver {
    static const int NAK = 0x15;
    static const int SYN = 0x16;
    static const int PRE = 0x01;
    static const int PST = 0x05;
    static const int EOT = 0x03;
    
    int sec = 0x20;
    int baudRate = 115200;
    late List<int> responseBites;
    SerialPort port;
    DatecsDriver(this.port, {this.baudRate = 115200});

    Future<Map<String, dynamic>> executeScript(String script) async {
        Map<String, dynamic> response = {
            'errorCode': 0,
            'errorText': ''
        };
        SerialPortConfig config = SerialPortConfig();
        config.baudRate = baudRate;
        port.config = config;
        if (port.openReadWrite()) {
            List<String> cmds = script.split('\n');
            for (String line in cmds) {
                List<String> components = line.replaceAll('\r', '').split(',');
                if (components[0] == '') {
                    continue;
                }
                int cmd = int.parse(components.removeAt(0));
                await send(cmd, text: components.join(','));
                String result = getResponseText();

                response['errorCode'] = int.parse(result.split('\t')[0]);
                if (response['errorCode'] != 0) {
                    // Command 100 (64h) Reading an error
                    await send(100, text: result);
                    List<String> resultParts = getResponseText().split('\t');
                    response['errorText'] = resultParts[2];
                    break;
                }
            }
        }

        port.close();
        return response;
    }
    Future<List<int>> send(int command, { String text = '' }) async {
        text = text.replaceAll('[', '').replaceAll(']', '').replaceAll('\\t', '\t');

        List<int> data = [];

        // <PRE>
        data.add(PRE);

        // <LEN>
        data = pushCmd(data, text.length + 0x20 + 10);

        // <SEQ>
        data.add(sec);

        // <CMD>
        data = pushCmd(data, command);

        // <DATA>
        for (int i = 0; i < text.length; i++) {
            data.add(text.codeUnitAt(i));
        }

        // <PST>
        data.add(PST);

        // <BCC>
        data = pushCmd(data, getBBC(data));

        // <EOT> 
        data.add(EOT);

        sec++;

        return sendCommand(Uint8List.fromList(data));
    }
    Future<List<int>> sendCommand(Uint8List data) async {
        bool sendData = false;
        try {
            while (!sendData) {
                port.write(data);
                sendData = true;
            }
        } catch (err) {
            debugPrint('Read error: $err');
        }

        return getResponse(data);
    }
    Future<List<int>> getResponse(data) async {
        try {
            Uint8List value;
            do {
                value = port.read(16);
                if (value.isEmpty) {
                    break;
                }
                parseResponse(value);
            } while (
                (value[0] == SYN && value.length == 1) ||
                (value[0] != NAK && value[value.length - 1] != EOT)
            );

            // error, send again
            if (value[0] == NAK) {
                return sendCommand(data);
            }
        } catch (err) {
            debugPrint('Read error: $err');
        }
        return responseBites;
    }
    String getResponseText() {
        String responseText = '';
        for (int i = 10; i < responseBites.length; i++) {
            int char = responseBites[i];
            if (char == 0x04) {
                break;
            }
            responseText += String.fromCharCode(char);
        }
        return responseText;
    }
    void parseResponse(Uint8List data) {
        for (int i = 0; i < data.length; i++) {
            if (data[i] == SYN) {
                responseBites = [];
                continue;
            }
            responseBites.add(data[i]);
        }
    }
    List<int> pushCmd(List<int> data, int cmd) {
        var size = cmd.toRadixString(16).split('');
        for (int i = 0; i < 4 - size.length; i++) {
            data.add(0x30);
        }
        for (int i = 0; i < size.length; i++) {
            data.add(int.parse(size[i], radix: 16) + 0x30);
        }
        return data;
    }
    int getBBC(List<int> data) {
        int sum = 0;
        for (int i = 1; i < data.length; i++) {
            sum += data[i];
        }
        return sum;
    }

    int vatMap(int percentage, {bool isVatPayer = true}) {
      if (!isVatPayer) {
        return 5;
      }
      Map<int, int> map = {
        19: 1,
        9: 2,
        5: 3,
        0: 4,
      };
      return map[percentage] ?? 1;
    }

    Future<bool> print(TaxReceipt receipt) async {
      String cif = '';
      String invoice = cif.isEmpty ? '' : 'I';
      String commands = '48,1[\\t]0001[\\t]1[\\t]$invoice[\\t]$cif[\\t]\n';
      List<TaxReceiptProduct> products = await receipt.products();
      for (TaxReceiptProduct product in products) {
        String discountType = ''; // percent = 2, value = 4
        commands += '49,${product.name}[\\t]';
        commands += '${vatMap(product.vatPercentage)}[\\t]';
        commands += '${product.priceWithVat}[\\t]';
        commands += '${product.quantity}[\\t]';
        commands += '$discountType[\\t]';
        commands += '0.00[\\t]'; // discount
        commands += '1[\\t]'; // department
        commands += '${product.measuringUnit}[\\t]\n';
      }

      // payment
      int paymentMethod = 0; // 0 - cash, 1 - cart etc.
      commands += '53,$paymentMethod[\\t]${receipt.total}[\\t]\n';

      debugPrint(commands);
      return true;
    }
}