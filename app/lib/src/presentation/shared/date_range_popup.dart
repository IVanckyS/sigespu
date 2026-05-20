import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Compact date range selector popup.
/// Anchor it below a button using [DateRangePopupController] + [CompositedTransformTarget].
class DateRangePopup extends StatefulWidget {
  final DateTime? initialFrom;
  final DateTime? initialTo;
  final void Function(DateTime? from, DateTime? to) onApply;
  final VoidCallback onDismiss;

  const DateRangePopup({
    super.key,
    this.initialFrom,
    this.initialTo,
    required this.onApply,
    required this.onDismiss,
  });

  @override
  State<DateRangePopup> createState() => _DateRangePopupState();
}

class _DateRangePopupState extends State<DateRangePopup> {
  late DateTime? _from;
  late DateTime? _to;
  bool _pickingFrom = true;

  static final _firstDate = DateTime(2024);
  static final _lastDate = DateTime(2028);

  @override
  void initState() {
    super.initState();
    _from = widget.initialFrom;
    _to = widget.initialTo;
    _pickingFrom = _from == null;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 10,
      borderRadius: BorderRadius.circular(12),
      color: Colors.white,
      child: SizedBox(
        width: 340,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tabs Desde / Hasta
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(children: [
                _TabChip(
                  label: 'Desde',
                  value: _from != null ? _formatDate(_from!) : '—',
                  active: _pickingFrom,
                  onTap: () => setState(() => _pickingFrom = true),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward,
                    size: 14, color: AppTheme.stone400),
                const SizedBox(width: 8),
                _TabChip(
                  label: 'Hasta',
                  value: _to != null ? _formatDate(_to!) : '—',
                  active: !_pickingFrom,
                  onTap: () => setState(() => _pickingFrom = false),
                  disabled: _from == null,
                ),
              ]),
            ),
            const Divider(height: 1),
            // Mini calendar
            SizedBox(
              height: 220,
              child: CalendarDatePicker(
                initialDate: _pickingFrom
                    ? (_from ?? DateTime.now())
                    : (_to ?? _from ?? DateTime.now()),
                firstDate: _pickingFrom ? _firstDate : (_from ?? _firstDate),
                lastDate: _lastDate,
                onDateChanged: (d) {
                  setState(() {
                    if (_pickingFrom) {
                      _from = d;
                      if (_to != null && d.isAfter(_to!)) { _to = null; }
                      _pickingFrom = false;
                    } else {
                      _to = d;
                    }
                  });
                },
              ),
            ),
            const Divider(height: 1),
            // Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _from = null;
                      _to = null;
                    });
                    widget.onApply(null, null);
                    widget.onDismiss();
                  },
                  child: const Text('Limpiar',
                      style: TextStyle(color: AppTheme.stone500)),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {
                    widget.onApply(_from, _to);
                    widget.onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.orange600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Aplicar',
                      style: TextStyle(fontSize: 13)),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _TabChip extends StatelessWidget {
  final String label;
  final String value;
  final bool active;
  final bool disabled;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.value,
    required this.active,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: disabled ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: active
                ? AppTheme.orange50
                : disabled
                    ? AppTheme.stone100
                    : AppTheme.stone50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: active ? AppTheme.orange600 : AppTheme.stone200,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color:
                          disabled ? AppTheme.stone300 : AppTheme.stone500,
                      fontWeight: FontWeight.w600)),
              Text(value,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: active
                          ? AppTheme.orange700
                          : disabled
                              ? AppTheme.stone300
                              : AppTheme.stone700)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper to show [DateRangePopup] as a dialog.
/// [link] is kept for backward compatibility with [CompositedTransformTarget]
/// wrappers in callers — it is no longer used for positioning.
class DateRangePopupController {
  final LayerLink link;
  BuildContext? _dialogCtx;

  DateRangePopupController(this.link);

  void show(
    BuildContext context, {
    DateTime? initialFrom,
    DateTime? initialTo,
    required void Function(DateTime? from, DateTime? to) onApply,
  }) {
    dismiss();
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.20),
      builder: (ctx) {
        _dialogCtx = ctx;
        return Center(
          child: DateRangePopup(
            initialFrom: initialFrom,
            initialTo: initialTo,
            onApply: onApply,
            onDismiss: dismiss,
          ),
        );
      },
    ).then((_) => _dialogCtx = null);
  }

  void dismiss() {
    final ctx = _dialogCtx;
    _dialogCtx = null;
    if (ctx != null && ctx.mounted) {
      Navigator.of(ctx).pop();
    }
  }
}
