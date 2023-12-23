import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:isar/isar.dart';

import '../../collections/bank_name.dart';
import '../../enums/account_type.dart';
import '../../enums/deposit_type.dart';
import '../../extensions/extensions.dart';
import '../../state/bank_names/bank_names_notifier.dart';
import 'parts/error_dialog.dart';

class BankNameInputAlert extends ConsumerStatefulWidget {
  const BankNameInputAlert({super.key, required this.depositType, required this.isar, this.bankName});

  final DepositType depositType;
  final Isar isar;
  final BankName? bankName;

  @override
  ConsumerState<BankNameInputAlert> createState() => _BankNameInputAlertState();
}

class _BankNameInputAlertState extends ConsumerState<BankNameInputAlert> {
  final TextEditingController _bankNumberEditingController = TextEditingController();
  final TextEditingController _bankNameEditingController = TextEditingController();
  final TextEditingController _branchNumberEditingController = TextEditingController();
  final TextEditingController _branchNameEditingController = TextEditingController();
  final TextEditingController _accountNumberEditingController = TextEditingController();

  AccountType _selectedAccountType = AccountType.blank;

  late BuildContext _context;

  ///
  @override
  void initState() {
    super.initState();

    if (widget.bankName != null) {
      _bankNumberEditingController.text = widget.bankName!.bankNumber;
      _bankNameEditingController.text = widget.bankName!.bankName;
      _branchNumberEditingController.text = widget.bankName!.branchNumber;
      _branchNameEditingController.text = widget.bankName!.branchName;
      _accountNumberEditingController.text = widget.bankName!.accountNumber;

      switch (widget.bankName!.accountType) {
        case '普通口座':
          _selectedAccountType = AccountType.normal;
          break;
        case '定期口座':
          _selectedAccountType = AccountType.fixed;
          break;
      }
    }
  }

  ///
  @override
  Widget build(BuildContext context) {
    _context = context;

    final bankNamesSettingState = ref.watch(bankNamesProvider);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              const Text('金融機関追加'),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _bankNumberEditingController,
                            decoration: const InputDecoration(labelText: '金融機関番号'),
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _bankNameEditingController,
                            decoration: const InputDecoration(labelText: '金融機関名'),
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _branchNumberEditingController,
                            decoration: const InputDecoration(labelText: '支店番号'),
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _branchNameEditingController,
                            decoration: const InputDecoration(labelText: '支店名'),
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButton(
                            isExpanded: true,
                            dropdownColor: Colors.pinkAccent.withOpacity(0.1),
                            iconEnabledColor: Colors.white,
                            items: AccountType.values.map((e) {
                              return DropdownMenuItem(
                                value: e,
                                child: Text(e.japanName, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                            value: (_selectedAccountType != AccountType.blank)
                                ? _selectedAccountType
                                : bankNamesSettingState.accountType,
                            onChanged: (value) {
                              ref.read(bankNamesProvider.notifier).setAccountType(accountType: value!);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _accountNumberEditingController,
                            decoration: const InputDecoration(labelText: '口座番号'),
                            style: const TextStyle(fontSize: 13, color: Colors.white),
                            onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  (widget.bankName != null)
                      ? Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                switch (widget.bankName!.accountType) {
                                  case '普通口座':
                                    ref
                                        .read(bankNamesProvider.notifier)
                                        .setAccountType(accountType: AccountType.normal);
                                    break;
                                  case '定期口座':
                                    ref.read(bankNamesProvider.notifier).setAccountType(accountType: AccountType.fixed);
                                    break;
                                }

                                _updateBankName();
                              },
                              child: Text(
                                '金融機関を更新する',
                                style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: _deleteBankName,
                              child: Text('金融機関を削除する',
                                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.primary)),
                            ),
                          ],
                        )
                      : TextButton(
                          onPressed: _inputBankName,
                          child: const Text('金融機関を追加する', style: TextStyle(fontSize: 12)),
                        ),
                ],
              ),

              ///////////////////////////////////////////

              ElevatedButton(
                onPressed: () {
                  _bankNumberEditingController.text = '0001';
                  _bankNameEditingController.text = 'みずほ銀行';
                  _branchNumberEditingController.text = '046';
                  _branchNameEditingController.text = '虎ノ門支店';
                  _accountNumberEditingController.text = '2961375';
                  ref.read(bankNamesProvider.notifier).setAccountType(accountType: AccountType.normal);
                },
                child: const Text('みずほ銀行'),
              ),

              ElevatedButton(
                onPressed: () {
                  _bankNumberEditingController.text = '0009';
                  _bankNameEditingController.text = '三井住友銀行';
                  _branchNumberEditingController.text = '547';
                  _branchNameEditingController.text = '横浜駅前支店';
                  _accountNumberEditingController.text = '8981660';
                  ref.read(bankNamesProvider.notifier).setAccountType(accountType: AccountType.normal);
                },
                child: const Text('三井住友銀行547'),
              ),

              ElevatedButton(
                onPressed: () {
                  _bankNumberEditingController.text = '0009';
                  _bankNameEditingController.text = '三井住友銀行';
                  _branchNumberEditingController.text = '259';
                  _branchNameEditingController.text = '新宿西口支店';
                  _accountNumberEditingController.text = '2967733';
                  ref.read(bankNamesProvider.notifier).setAccountType(accountType: AccountType.normal);
                },
                child: const Text('三井住友銀行259'),
              ),

              ElevatedButton(
                onPressed: () {
                  _bankNumberEditingController.text = '0005';
                  _bankNameEditingController.text = '三菱UFJ銀行';
                  _branchNumberEditingController.text = '271';
                  _branchNameEditingController.text = '船橋支店';
                  _accountNumberEditingController.text = '0782619';
                  ref.read(bankNamesProvider.notifier).setAccountType(accountType: AccountType.normal);
                },
                child: const Text('三菱UFJ銀行'),
              ),

              ElevatedButton(
                onPressed: () {
                  _bankNumberEditingController.text = '0036';
                  _bankNameEditingController.text = '楽天銀行';
                  _branchNumberEditingController.text = '226';
                  _branchNameEditingController.text = 'ギター支店';
                  _accountNumberEditingController.text = '2994905';
                  ref.read(bankNamesProvider.notifier).setAccountType(accountType: AccountType.normal);
                },
                child: const Text('楽天銀行'),
              ),

              ///////////////////////////////////////////
            ],
          ),
        ),
      ),
    );
  }

  ///
  Future<void> _inputBankName() async {
    final accountType = ref.watch(bankNamesProvider.select((value) => value.accountType));

    if (_bankNumberEditingController.text == '' ||
        _bankNameEditingController.text == '' ||
        _branchNumberEditingController.text == '' ||
        _branchNameEditingController.text == '' ||
        _accountNumberEditingController.text == '' ||
        (accountType == AccountType.blank)) {
      Future.delayed(
        Duration.zero,
        () => error_dialog(context: _context, title: '登録できません。', content: '値を正しく入力してください。'),
      );

      return;
    }

    final bankName = BankName()
      ..bankNumber = _bankNumberEditingController.text
      ..bankName = _bankNameEditingController.text
      ..branchNumber = _branchNumberEditingController.text
      ..branchName = _branchNameEditingController.text
      ..accountType = accountType.japanName
      ..accountNumber = _accountNumberEditingController.text
      ..depositType = widget.depositType.japanName;

    await widget.isar.writeTxn(() async => await widget.isar.bankNames.put(bankName));

    _bankNumberEditingController.clear();
    _bankNameEditingController.clear();
    _branchNumberEditingController.clear();
    _branchNameEditingController.clear();
    _accountNumberEditingController.clear();

    if (mounted) {
      Navigator.pop(_context);
    }
  }

  ///
  Future<void> _updateBankName() async {
    final accountType = ref.watch(bankNamesProvider.select((value) => value.accountType));

    if (_bankNumberEditingController.text == '' ||
        _bankNameEditingController.text == '' ||
        _branchNumberEditingController.text == '' ||
        _branchNameEditingController.text == '' ||
        _accountNumberEditingController.text == '' ||
        (accountType == AccountType.blank)) {
      Future.delayed(
        Duration.zero,
        () => error_dialog(context: _context, title: '登録できません。', content: '値を正しく入力してください。'),
      );

      return;
    }

    final bankNameCollection = widget.isar.bankNames;

    await widget.isar.writeTxn(() async {
      final bankName = await bankNameCollection.get(widget.bankName!.id);

      bankName!
        ..bankNumber = _bankNumberEditingController.text
        ..bankName = _bankNameEditingController.text
        ..branchNumber = _branchNumberEditingController.text
        ..branchName = _branchNameEditingController.text
        ..accountType = accountType.japanName
        ..accountNumber = _accountNumberEditingController.text
        ..depositType = widget.depositType.japanName;

      await bankNameCollection.put(bankName);
    });

    _bankNumberEditingController.clear();
    _bankNameEditingController.clear();
    _branchNumberEditingController.clear();
    _branchNameEditingController.clear();
    _accountNumberEditingController.clear();

    if (mounted) {
      Navigator.pop(_context);
    }
  }

  ///
  Future<void> _deleteBankName() async {
    final bankNameCollection = widget.isar.bankNames;

    await widget.isar.writeTxn(() async => await bankNameCollection.delete(widget.bankName!.id));

    if (mounted) {
      Navigator.pop(_context);
    }
  }
}