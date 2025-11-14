import 'dart:convert';
import 'package:final_year_project/services_details/bus_details/bus_details.dart';
import 'package:flutter/material.dart';

import 'package:final_year_project/color_schema/app_colors.dart';

class Seat {
  int number;
  bool removed;

  Seat({required this.number, this.removed = false});

  Map<String, dynamic> toJson() => {'number': number, 'removed': removed};
}

class SeatLayoutConfigPage extends StatefulWidget {
  const SeatLayoutConfigPage({super.key});

  @override
  State<SeatLayoutConfigPage> createState() => _SeatLayoutConfigPageState();
}

class _SeatLayoutConfigPageState extends State<SeatLayoutConfigPage> {
  int rows = 0;
  int columns = 0;
  int lastRowColumns = 0;
  bool useLastRowOverride = true;
  String driverSide = 'Right';
  String numberingMode = 'Auto'; // 'Auto' or 'Manual'
  List<Seat> seats = [];

  int getTotalSeats() {
    if (rows <= 0 || columns <= 0) return 0;
    if (useLastRowOverride && lastRowColumns > 0 && rows > 1) {
      return (rows - 1) * columns + lastRowColumns;
    } else {
      return rows * columns;
    }
  }

  void createSeatPlan() {
    if (rows <= 0 || columns <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please set the rows and columns to create seat plan.',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: AppColors.errorRed.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final List<Seat> newSeats = [];

    // Build seats row-by-row; each row may have different column count (last row override).
    for (int r = 0; r < rows; r++) {
      final bool isLastRow = (useLastRowOverride && r == rows - 1);
      final int currentCols = isLastRow && lastRowColumns > 0
          ? lastRowColumns
          : columns;
      for (int c = 0; c < currentCols; c++) {
        if (numberingMode == 'Auto') {
          // placeholder 0 for now; assign numbers after layout created
          newSeats.add(Seat(number: 0));
        } else {
          // Manual: initialize with 0 so user can set numbers manually
          newSeats.add(Seat(number: 0));
        }
      }
    }

    // If auto, assign numbers starting from 1, row-by-row, each row numbering right-to-left.
    if (numberingMode == 'Auto') {
      int counter = 1;
      int idx = 0;
      for (int r = 0; r < rows; r++) {
        final bool isLastRow = (useLastRowOverride && r == rows - 1);
        final int currentCols = isLastRow && lastRowColumns > 0
            ? lastRowColumns
            : columns;
        // rowStart index in newSeats
        int rowStart = idx;
        // assign from rightmost to leftmost
        for (int c = currentCols - 1; c >= 0; c--) {
          newSeats[rowStart + c].number = counter;
          counter++;
        }
        idx += currentCols;
      }
    }

    setState(() => seats = newSeats);
  }

  void deleteAllSeats() => setState(() => seats = []);
  void toggleSeatRemoved(int i) =>
      setState(() => seats[i].removed = !seats[i].removed);
  void removeSingleSeat(int i) => setState(() => seats[i].removed = true);

  void saveSeatLayout() {
    if (seats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No seat layout to save.'),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final layout = {
      'rows': rows,
      'columns': columns,
      'useLastRowOverride': useLastRowOverride,
      'lastRowColumns': useLastRowOverride ? lastRowColumns : null,
      'driverSide': driverSide,
      'numberingMode': numberingMode,
      'totalSeats': seats.length,
      'seats': seats.map((s) => s.toJson()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(layout);
    debugPrint(jsonStr);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Seat layout saved successfully!'),
        backgroundColor: AppColors.lightSeaGreen,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AddBusDetailsScreen()),
      );
    });
  }

  Widget buildSeatGridPreview({
    double seatWidth = 56,
    double seatHeight = 44,
    double spacing = 6,
  }) {
    final cs = Theme.of(context).colorScheme;
    if (seats.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          'No seat plan generated. Tap "Create Seat Plan".',
          style: TextStyle(color: cs.onSurface.withOpacity(0.7)),
        ),
      );
    }

    final List<Widget> rowWidgets = [];
    int seatIndex = 0;

    for (int r = 0; r < rows; r++) {
      final bool isLastRow = (useLastRowOverride && r == rows - 1);
      final int currentCols = isLastRow && lastRowColumns > 0
          ? lastRowColumns
          : columns;

      final List<Widget> leftSeats = [];
      final List<Widget> rightSeats = [];
      int half = (currentCols / 2).ceil();

      for (int c = 0; c < currentCols; c++) {
        if (seatIndex >= seats.length) break;
        Widget tile = buildSeatTile(
          seatIndex,
          width: seatWidth,
          height: seatHeight,
        );
        if (!isLastRow && c < half) {
          leftSeats.add(tile);
        } else if (!isLastRow) {
          rightSeats.add(tile);
        } else {
          leftSeats.add(tile);
        }
        seatIndex++;
      }

      rowWidgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: spacing),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: isLastRow
                ? leftSeats
                : [...leftSeats, SizedBox(width: seatWidth), ...rightSeats],
          ),
        ),
      );
    }

    // Place driver seat above the grid aligned to the side that is chosen.
    rowWidgets.insert(
      0,
      Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 45, left: 45),
        child: Row(
          mainAxisAlignment: driverSide == 'Left'
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: driverSide == 'Left' ? 20 : 0,
                right: driverSide == 'Right' ? 20 : 0,
              ),
              child: Icon(
                Icons.event_seat_outlined,
                color: cs.primary,
                size: 40,
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: rowWidgets,
    );
  }

  // Seat Preview Popup — render the same grid (smaller) to avoid overflow
  void showSeatPreviewPopup() {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seat Preview',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              // Use the same layout logic but slightly smaller to avoid overflow
              buildSeatGridPreview(seatWidth: 44, seatHeight: 34, spacing: 8),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSeatTile(int index, {double width = 56, double height = 44}) {
    final cs = Theme.of(context).colorScheme;
    final seat = seats[index];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          GestureDetector(
            onTap: () {
              if (numberingMode == 'Manual') {
                showDialog(
                  context: context,
                  builder: (ctx) {
                    final controller = TextEditingController(
                      text: seat.number == 0 ? '' : seat.number.toString(),
                    );
                    bool showError = false;

                    return StatefulBuilder(
                      builder: (context, setStateDialog) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: const Text('Set seat number'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: controller,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: 'Enter number',
                                  errorText: showError
                                      ? 'Please enter a number'
                                      : null,
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.accentOrange,
                                    ),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: AppColors.accentOrange,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            // Cancel
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: cs.onSurface,
                                side: const BorderSide(
                                  color: AppColors.accentOrange,
                                ),
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text("Cancel"),
                            ),

                            // Save
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentOrange,
                                shape: const StadiumBorder(),
                              ),
                              onPressed: () {
                                final text = controller.text.trim();
                                final val = int.tryParse(text);

                                if (val == null) {
                                  // show inline error
                                  setStateDialog(() {
                                    showError = true;
                                  });
                                  return;
                                }

                                setState(() {
                                  seat.number = val;
                                });
                                Navigator.pop(ctx);
                              },
                              child: const Text(
                                'Save',
                                style: TextStyle(color: AppColors.textWhite),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              } else {
                toggleSeatRemoved(index);
              }
            },
            onLongPress: () {
              toggleSeatRemoved(index);
            },
            child: Container(
              width: width,
              height: height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: seat.removed ? cs.surfaceVariant : cs.surface,
                border: Border.all(
                  color: seat.removed ? cs.outlineVariant : cs.primary,
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: cs.shadow.withOpacity(0.1),
                    offset: const Offset(0, 1),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Text(
                seat.number.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: seat.removed
                      ? cs.onSurface.withOpacity(0.5)
                      : cs.onSurface,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () => removeSingleSeat(index),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: seat.removed ? cs.outlineVariant : AppColors.errorRed,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 12,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // number controls
  void incRows() => setState(() => rows = (rows + 1).clamp(0, 100));
  void decRows() => setState(() => rows = (rows - 1).clamp(0, 100));
  void incColumns() => setState(() => columns = (columns + 1).clamp(0, 10));
  void decColumns() => setState(() => columns = (columns - 1).clamp(0, 10));
  void incLastRow() => setState(
    () => lastRowColumns = (lastRowColumns + 1).clamp(0, 5),
  ); // max 5 now
  void decLastRow() => setState(
    () => lastRowColumns = (lastRowColumns - 1).clamp(0, 5),
  ); // min 0, max 5

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(45),
        child: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: cs.primary,
          title: Text(
            'Seat Layout Configuration',
            style: TextStyle(color: cs.onPrimary, fontSize: 20),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: cs.onPrimary),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // top config card
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Define total number of seats:  ${getTotalSeats()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Text('Rows:', style: TextStyle(color: cs.onSurface)),
                          const SizedBox(width: 8),
                          _numberControl(rows, decRows, incRows),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(width: 8),
                          Text(
                            'Columns:',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          const SizedBox(width: 8),
                          _numberControl(columns, decColumns, incColumns),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Last row:',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          const SizedBox(width: 8),
                          _numberControl(
                            lastRowColumns,
                            decLastRow,
                            incLastRow,
                            enabled: useLastRowOverride,
                          ),
                          const SizedBox(width: 10),
                          Checkbox(
                            value: useLastRowOverride,
                            onChanged: (v) => setState(() {
                              useLastRowOverride = v ?? false;
                              if (!useLastRowOverride) lastRowColumns = 0;
                              if (useLastRowOverride && lastRowColumns == 0) {
                                lastRowColumns = columns.clamp(0, 5);
                              }
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Driver seat:',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: cs.outlineVariant,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButton<String>(
                              value: driverSide,
                              borderRadius: BorderRadius.circular(10),
                              underline: const SizedBox(),
                              dropdownColor: cs.surface,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Right',
                                  child: Text('Right'),
                                ),
                                DropdownMenuItem(
                                  value: 'Left',
                                  child: Text('Left'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => driverSide = v ?? 'Right'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Numbering mode dropdown (Auto / Manual)
                          Text(
                            'Numbering:',
                            style: TextStyle(color: cs.onSurface),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: cs.outlineVariant,
                                width: 1,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: DropdownButton<String>(
                              value: numberingMode,
                              borderRadius: BorderRadius.circular(10),
                              underline: const SizedBox(),
                              dropdownColor: cs.surface,
                              items: const [
                                DropdownMenuItem(
                                  value: 'Auto',
                                  child: Text('Auto'),
                                ),
                                DropdownMenuItem(
                                  value: 'Manual',
                                  child: Text('Manual'),
                                ),
                              ],
                              onChanged: (v) =>
                                  setState(() => numberingMode = v ?? 'Auto'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: createSeatPlan,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accentOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Create Seat Plan'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // seat grid preview card with preview button
              Card(
                color: cs.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seat Grid Preview',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: seats.isNotEmpty
                                ? showSeatPreviewPopup
                                : null,
                            child: const Text('Preview'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Column(
                          children: [
                            buildSeatGridPreview(),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.errorRed,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: seats.isNotEmpty
                                      ? deleteAllSeats
                                      : null,
                                  child: const Text('Delete All'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: seats.isNotEmpty
                                      ? saveSeatLayout
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.accentOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text('Save seat layout'),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _numberControl(
    int value,
    VoidCallback onDec,
    VoidCallback onInc, {
    bool enabled = true,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: enabled ? onDec : null,
          icon: Icon(Icons.remove_circle_outline, color: cs.primary),
        ),
        Container(
          width: 44,
          alignment: Alignment.center,
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
        ),
        IconButton(
          onPressed: enabled ? onInc : null,
          icon: Icon(Icons.add_circle_outline, color: cs.primary),
        ),
      ],
    );
  }
}
