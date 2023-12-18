import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PaginationComponent extends StatelessWidget {
  const PaginationComponent({
    super.key,
    this.currentPage = 1,
    this.pageSize = 10,
    this.totalElements = 0,
    this.onChangePage,
    this.onPageSizeChange,
  });

  final int currentPage;
  final int pageSize;
  final int totalElements;
  final Function(int)? onChangePage;
  final Function(int)? onPageSizeChange;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - 28;
        if (width < 500) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _paginationButtons(context),
              const SizedBox(height: 7),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _paginationText,
                  const SizedBox(width: 7),
                  _paginationDropdown(context),
                ],
              ),
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _paginationText,
              const SizedBox(width: 7),
              _paginationButtons(context),
              const SizedBox(width: 7),
              _paginationDropdown(context),
            ],
          );
        }
      },
    );
  }

  Widget get _paginationText {
    return Text(
      "$_startIndex - $_endIndex of $totalElements",
      textAlign: TextAlign.center,
    );
  }

  Widget _paginationButtons(BuildContext context) {
    const spacing = SizedBox(width: 7);
    const textBtnPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 12);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            onChangePage?.call(1);
          },
          child: const Padding(
            padding: textBtnPadding,
            child: Icon(FontAwesomeIcons.anglesLeft, size: 14),
          ),
        ),
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            onChangePage?.call(currentPage > 1 ? currentPage - 1 : 1);
          },
          child: const Padding(
            padding: textBtnPadding,
            child: Icon(FontAwesomeIcons.angleLeft, size: 14),
          ),
        ),
        if (currentPage > 2) ...[
          spacing,
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              onChangePage?.call(currentPage > 2 ? currentPage - 2 : 1);
            },
            child: Padding(
              padding: textBtnPadding,
              child: Text(
                "${currentPage - 2}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        if (currentPage > 1) ...[
          spacing,
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              onChangePage?.call(currentPage > 1 ? currentPage - 1 : 1);
            },
            child: Padding(
              padding: textBtnPadding,
              child: Text(
                "${currentPage - 1}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
        spacing,
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            _popupSelectPage(context);
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            padding: textBtnPadding,
            child: Text(
              "$currentPage",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
        spacing,
        if (currentPage < _totalPages) ...[
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              onChangePage?.call(
                  currentPage < _totalPages ? currentPage + 1 : _totalPages);
            },
            child: Padding(
              padding: textBtnPadding,
              child: Text(
                "${currentPage + 1}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          spacing,
        ],
        if (currentPage < _totalPages - 1) ...[
          InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              onChangePage?.call(
                  currentPage < _totalPages ? currentPage + 2 : _totalPages);
            },
            child: Padding(
              padding: textBtnPadding,
              child: Text(
                "${currentPage + 2}",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          spacing,
        ],
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            onChangePage?.call(
                currentPage < _totalPages ? currentPage + 1 : _totalPages);
          },
          child: const Padding(
            padding: textBtnPadding,
            child: Icon(FontAwesomeIcons.angleRight, size: 14),
          ),
        ),
        spacing,
        InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            onChangePage?.call(_totalPages);
          },
          child: const Padding(
            padding: textBtnPadding,
            child: Icon(FontAwesomeIcons.anglesRight, size: 14),
          ),
        ),
      ],
    );
  }

  Widget _paginationDropdown(BuildContext context) {
    List<int> pageSizeItems = [10, 25, 50];
    if (!pageSizeItems.contains(pageSize)) {
      pageSizeItems.add(pageSize);
      pageSizeItems.sort();
    }

    return SizedBox(
      width: 75,
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          isDense: true,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        ),
        value: pageSize,
        onChanged: (value) {
          if (value != null) {
            onPageSizeChange?.call(value);
          }
        },
        items: pageSizeItems.map((v) {
          return DropdownMenuItem<int>(
            value: v,
            child: Text(
              "$v",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }).toList(),
      ),
    );
  }

  int get _startIndex {
    return pageSize * (currentPage - 1) + 1;
  }

  int get _endIndex {
    return math.min(pageSize * currentPage - 1, totalElements);
  }

  int get _totalPages {
    final page = totalElements ~/ pageSize;
    if (page == 0) {
      return 1;
    }
    return page;
  }

  void _popupSelectPage(context) async {
    double page = currentPage.toDouble();

    final value = await showDialog<int?>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.paginationSelectPageTitle),
          content: SpinBox(
            value: page,
            decimals: 0,
            min: 1,
            max: _totalPages.toDouble(),
            onSubmitted: (value) {
              page = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.confirm),
              onPressed: () {
                Navigator.of(context).pop(page.toInt());
              },
            ),
          ],
        );
      },
    );

    if (value != null) {
      onChangePage?.call(value);
    }
  }
}
