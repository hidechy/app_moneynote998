import 'dart:ui';

import 'package:bubble/bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../collections/bank_name.dart';
import '../../../collections/bank_price.dart';
import '../../../collections/emoney_name.dart';
import '../../../collections/money.dart';
import '../../../collections/spend_time_place.dart';
import '../../../enums/deposit_type.dart';
import '../../../extensions/extensions.dart';
import '../../../utilities/functions.dart';
import '../../../utilities/utilities.dart';
import '../bank_price_input_alert.dart';
import '../money_input_alert.dart';
import '../parts/bank_emoney_blank_message.dart';
import '../parts/error_dialog.dart';
import '../parts/money_dialog.dart';
import '../spend_time_place_input_alert.dart';

class DailyMoneyDisplayPage extends ConsumerStatefulWidget {
  const DailyMoneyDisplayPage({super.key, required this.date, required this.isar});

  final DateTime date;
  final Isar isar;

  @override
  ConsumerState<DailyMoneyDisplayPage> createState() => _DailyMoneyDisplayAlertState();
}

class _DailyMoneyDisplayAlertState extends ConsumerState<DailyMoneyDisplayPage> {
  final Utility _utility = Utility();

  List<BankName>? bankNameList = [];
  List<EmoneyName>? emoneyNameList = [];
  List<BankPrice>? bankPriceList = [];
  List<Money>? moneyList = [];
  List<Money>? beforeMoneyList = [];
  List<SpendTimePlace>? spendTimePlaceList = [];

  Map<String, Map<String, int>> bankPricePadMap = {};
  Map<String, int> bankPriceTotalPadMap = {};

  int onedayMoneyTotal = 0;
  int beforeMoneyTotal = 0;

  int dispTotalBank = 0;
  int dispTotalEmoney = 0;

  @override
  void initState() {
    super.initState();

    _makeBankNameList();
    _makeEmoneyNameList();

    _makeBankPriceList();
    _makeMoneyList();
    _makeBeforeMoneyList();

    _makeSpendTimePlaceList();
  }

  ///
  @override
  void dispose() {
    super.dispose();
  }

  ///
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: double.infinity,
        child: DefaultTextStyle(
          style: GoogleFonts.kiwiMaru(fontSize: 12),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Container(width: context.screenSize.width),
                const SizedBox(height: 20),
                _displayTopInfoPlate(),
                const SizedBox(height: 20),
                _displaySingleMoney(),
                const SizedBox(height: 20),
                _displayBankNames(),
                const SizedBox(height: 20),
                _displayEmoneyNames(),
                const SizedBox(height: 20),
                _displaySpendTimePlaceList(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _displayTopInfoPlate() {
    final oneday = widget.date.yyyymmdd;

    final beforeDate =
        DateTime(oneday.split('-')[0].toInt(), oneday.split('-')[1].toInt(), oneday.split('-')[2].toInt() - 1);

    final onedayBankTotal = (bankPriceTotalPadMap[oneday] != null) ? bankPriceTotalPadMap[oneday] : 0;
    final beforeBankTotal =
        (bankPriceTotalPadMap[beforeDate.yyyymmdd] != null) ? bankPriceTotalPadMap[beforeDate.yyyymmdd] : 0;

    final beforeTotal = beforeMoneyTotal + beforeBankTotal!;
    final onedayTotal = onedayMoneyTotal + onedayBankTotal!;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(blurRadius: 24, spreadRadius: 16, color: Colors.black.withOpacity(0.2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: context.screenSize.width,
            margin: const EdgeInsets.all(5),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start'),
                      Text(beforeTotal.toString().toCurrency()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('End'),
                      Text(onedayTotal.toString().toCurrency()),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Spend'),
                      Row(
                        children: [
                          _getBubbleComment(beforeTotal: beforeTotal, onedayTotal: onedayTotal),
                          const SizedBox(width: 10),
                          Text(
                            ((beforeMoneyTotal + beforeBankTotal) - (onedayMoneyTotal + onedayBankTotal))
                                .toString()
                                .toCurrency(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ///
  Widget _getBubbleComment({required int beforeTotal, required int onedayTotal}) {
    var text = '';
    var color = Colors.transparent;

    if (beforeTotal > 0 && onedayTotal > beforeTotal) {
      text = '増えた！';
      color = Colors.indigoAccent.withOpacity(0.6);
    }

    if (beforeTotal == 0 && onedayTotal > 0) {
      text = '初日';
      color = Colors.orangeAccent.withOpacity(0.6);
    }

    if (text == '') {
      return Container();
    }

    return Row(
      children: [
        Bubble(
          color: color,
          nip: BubbleNip.rightTop,
          child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  ///
  Widget _displaySingleMoney() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: context.screenSize.width,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            gradient:
                LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('CURRENCY', overflow: TextOverflow.ellipsis),
              GestureDetector(
                onTap: () => MoneyDialog(
                  context: context,
                  widget: MoneyInputAlert(
                    date: widget.date,
                    isar: widget.isar,
                    onedayMoneyList: moneyList,
                    beforedayMoneyList: beforeMoneyList,
                  ),
                ),
                child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(),
              Text(
                onedayMoneyTotal.toString().toCurrency(),
                style: const TextStyle(color: Colors.yellowAccent),
              ),
            ],
          ),
        ),
        _displayMoneyParts(key: '10000', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_10000 : 0),
        _displayMoneyParts(key: '5000', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_5000 : 0),
        _displayMoneyParts(key: '2000', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_2000 : 0),
        _displayMoneyParts(key: '1000', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_1000 : 0),
        _displayMoneyParts(key: '500', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_500 : 0),
        _displayMoneyParts(key: '100', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_100 : 0),
        _displayMoneyParts(key: '50', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_50 : 0),
        _displayMoneyParts(key: '10', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_10 : 0),
        _displayMoneyParts(key: '5', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_5 : 0),
        _displayMoneyParts(key: '1', value: (moneyList!.isNotEmpty) ? moneyList![0].yen_1 : 0),
        const SizedBox(height: 20),
      ],
    );
  }

  ///
  Widget _displayMoneyParts({required String key, required int value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(key), Text(value.toString().toCurrency())],
      ),
    );
  }

  ///
  Future<void> _makeMoneyList() async {
    final moneyCollection = widget.isar.moneys;

    final getMoneys = await moneyCollection.filter().dateEqualTo(widget.date.yyyymmdd).findAll();

    setState(() {
      moneyList = getMoneys;

      if (moneyList!.isNotEmpty) {
        onedayMoneyTotal = _utility.makeCurrencySum(money: moneyList![0]);
      }
    });
  }

  ///
  Future<void> _makeBeforeMoneyList() async {
    final moneyCollection = widget.isar.moneys;

    final oneday = widget.date.yyyymmdd;

    final beforeDate =
        DateTime(oneday.split('-')[0].toInt(), oneday.split('-')[1].toInt(), oneday.split('-')[2].toInt() - 1);

    final getBeforeDateMoneys = await moneyCollection.filter().dateEqualTo(beforeDate.yyyymmdd).findAll();

    setState(() {
      beforeMoneyList = getBeforeDateMoneys;

      if (beforeMoneyList!.isNotEmpty) {
        beforeMoneyTotal = _utility.makeCurrencySum(money: beforeMoneyList![0]);
      }
    });
  }

  //=======================================================// BankNames // s

  ///
  Future<void> _makeBankNameList() async {
    final bankNamesCollection = widget.isar.bankNames;

    final getBankNames = await bankNamesCollection.where().findAll();

    if (mounted) {
      setState(() => bankNameList = getBankNames);
    }
  }

  ///
  Widget _displayBankNames() {
    final list = <Widget>[
      Container(
        width: context.screenSize.width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
        ),
        child: const Text('BANK', overflow: TextOverflow.ellipsis),
      )
    ];

    if (bankNameList!.isEmpty) {
      list.add(Column(
        children: [
          const SizedBox(height: 10),
          BankEmoneyBlankMessage(deposit: '金融機関', isar: widget.isar),
          const SizedBox(height: 30),
        ],
      ));
    } else {
      final list2 = <Widget>[];

      var sum = 0;
      for (var i = 0; i < bankNameList!.length; i++) {
        if (bankPricePadMap['${bankNameList![i].depositType}-${bankNameList![i].id}'] != null) {
          final bankPriceMap = bankPricePadMap['${bankNameList![i].depositType}-${bankNameList![i].id}'];
          if (bankPriceMap![widget.date.yyyymmdd] != null) {
            sum += bankPriceMap[widget.date.yyyymmdd]!;
          }
        }
      }

      list2.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text(
              sum.toString().toCurrency(),
              style: const TextStyle(color: Colors.yellowAccent),
            ),
          ],
        ),
      ));

      for (var i = 0; i < bankNameList!.length; i++) {
        list2.add(
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(bankNameList![i].bankName),
                Row(
                  children: [
                    Text(
                      _getListPrice(depositType: bankNameList![i].depositType, id: bankNameList![i].id)
                          .toString()
                          .toCurrency(),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => MoneyDialog(
                        context: context,
                        widget: BankPriceInputAlert(
                          date: widget.date,
                          isar: widget.isar,
                          depositType: DepositType.bank,
                          bankName: bankNameList![i],
                        ),
                      ),
                      child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      list.add(Column(children: list2));
    }

    return Column(children: list);
  }

//=======================================================// BankNames // e

//=======================================================// EmoneyNames // s

  ///
  Future<void> _makeEmoneyNameList() async {
    final emoneyNamesCollection = widget.isar.emoneyNames;

    final getEmoneyNames = await emoneyNamesCollection.where().findAll();

    if (mounted) {
      setState(() => emoneyNameList = getEmoneyNames);
    }
  }

  ///
  Widget _displayEmoneyNames() {
    final list = <Widget>[
      Container(
        width: context.screenSize.width,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
        ),
        child: const Text('E-MONEY', overflow: TextOverflow.ellipsis),
      )
    ];

    if (emoneyNameList!.isEmpty) {
      list.add(Column(
        children: [
          const SizedBox(height: 10),
          BankEmoneyBlankMessage(deposit: '電子マネー', index: 1, isar: widget.isar),
          const SizedBox(height: 30),
        ],
      ));
    } else {
      final list2 = <Widget>[];

      var sum = 0;
      for (var i = 0; i < emoneyNameList!.length; i++) {
        if (bankPricePadMap['${emoneyNameList![i].depositType}-${emoneyNameList![i].id}'] != null) {
          final bankPriceMap = bankPricePadMap['${emoneyNameList![i].depositType}-${emoneyNameList![i].id}'];

          if (bankPriceMap![widget.date.yyyymmdd] != null) {
            sum += bankPriceMap[widget.date.yyyymmdd]!;
          }
        }
      }

      list2.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text(
              sum.toString().toCurrency(),
              style: const TextStyle(color: Colors.yellowAccent),
            ),
          ],
        ),
      ));

      for (var i = 0; i < emoneyNameList!.length; i++) {
        list2.add(
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoneyNameList![i].emoneyName),
                Row(
                  children: [
                    Text(
                      _getListPrice(depositType: emoneyNameList![i].depositType, id: emoneyNameList![i].id)
                          .toString()
                          .toCurrency(),
                    ),
                    const SizedBox(width: 20),
                    GestureDetector(
                      onTap: () => MoneyDialog(
                        context: context,
                        widget: BankPriceInputAlert(
                          date: widget.date,
                          isar: widget.isar,
                          depositType: DepositType.emoney,
                          emoneyName: emoneyNameList![i],
                        ),
                      ),
                      child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }

      list.add(Column(children: list2));
    }

    return Column(children: list);
  }

//=======================================================// EmoneyNames // e

//=======================================================// BankPrices // s

  ///
  Future<void> _makeBankPriceList() async {
    final bankPricesCollection = widget.isar.bankPrices;

    final getBankPrices = await bankPricesCollection.where().findAll();

    setState(() {
      bankPriceList = getBankPrices;

      if (bankPriceList != null) {
        final bankPriceMap = makeBankPriceMap(bankPriceList: bankPriceList!);
        bankPricePadMap = bankPriceMap['bankPriceDatePadMap'];
        bankPriceTotalPadMap = bankPriceMap['bankPriceTotalPadMap'];
      }
    });
  }

  ///
  int _getListPrice({required String depositType, required int id}) {
    var listPrice = 0;
    if (bankPricePadMap['$depositType-$id'] != null) {
      final bankPriceMap = bankPricePadMap['$depositType-$id'];
      if (bankPriceMap![widget.date.yyyymmdd] != null) {
        listPrice = bankPriceMap[widget.date.yyyymmdd]!;
      }
    }

    return listPrice;
  }

  ///
  Future<void> _makeSpendTimePlaceList() async {
    final spendTimePlacesCollection = widget.isar.spendTimePlaces;

    final getSpendTimePlaces = await spendTimePlacesCollection.filter().dateEqualTo(widget.date.yyyymmdd).findAll();

    if (mounted) {
      setState(() => spendTimePlaceList = getSpendTimePlaces);
    }
  }

  ///
  Widget _displaySpendTimePlaceList() {
    final list = <Widget>[
      Column(
        children: [
          Container(
            width: context.screenSize.width,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              gradient:
                  LinearGradient(colors: [Colors.indigo.withOpacity(0.8), Colors.transparent], stops: const [0.7, 1]),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('SPEND', overflow: TextOverflow.ellipsis),
                GestureDetector(
                  onTap: () async {
                    if (onedayMoneyTotal == 0) {
                      Future.delayed(
                        Duration.zero,
                        () => error_dialog(context: context, title: '登録できません。', content: '先にCURRENCYを入力してください。'),
                      );

                      return;
                    }

                    final oneday = widget.date.yyyymmdd;

                    final beforeDate = DateTime(
                        oneday.split('-')[0].toInt(), oneday.split('-')[1].toInt(), oneday.split('-')[2].toInt() - 1);

                    final onedayBankTotal = (bankPriceTotalPadMap[oneday] != null) ? bankPriceTotalPadMap[oneday] : 0;
                    final beforeBankTotal = (bankPriceTotalPadMap[beforeDate.yyyymmdd] != null)
                        ? bankPriceTotalPadMap[beforeDate.yyyymmdd]
                        : 0;

                    final spendDiff = (beforeMoneyTotal + beforeBankTotal!) - (onedayMoneyTotal + onedayBankTotal!);

                    if (spendDiff == 0) {
                      Future.delayed(
                        Duration.zero,
                        () => error_dialog(
                          context: context,
                          title: '登録できません。',
                          content: '前日との差額がないため、消費金額の登録はできません。',
                        ),
                      );

                      return;
                    }

                    await MoneyDialog(
                      context: context,
                      widget: SpendTimePlaceInputAlert(
                        date: widget.date,
                        spend: (beforeMoneyTotal + beforeBankTotal) - (onedayMoneyTotal + onedayBankTotal),
                        isar: widget.isar,
                        spendTimePlaceList: spendTimePlaceList,
                      ),
                    );
                  },
                  child: Icon(Icons.input, color: Colors.greenAccent.withOpacity(0.6)),
                ),
              ],
            ),
          ),
        ],
      ),
    ];

    if (spendTimePlaceList!.isNotEmpty) {
      var sum = 0;
      makeMonthlySpendItemSumMap(spendTimePlaceList: spendTimePlaceList!).forEach((key, value) {
        sum += value;
      });

      list.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(),
            Text(
              sum.toString().toCurrency(),
              style: const TextStyle(color: Colors.yellowAccent),
            ),
          ],
        ),
      ));

      makeMonthlySpendItemSumMap(spendTimePlaceList: spendTimePlaceList!).forEach((key, value) {
        list.add(Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.3)))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(key), Text(value.toString().toCurrency())],
          ),
        ));
      });
    }

    return Column(mainAxisSize: MainAxisSize.min, children: list);
  }

//=======================================================// BankPrices // s
}