import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hercare/core/providers/app_providers.dart';
import 'package:hercare/core/utils/date_utils.dart';
import 'package:hercare/features/cycle_tracking/domain/models/cycle_record.dart';

class PeriodEntryDialog extends ConsumerStatefulWidget {
  final CycleRecord? initialRecord;
  final DateTime? defaultDate;

  const PeriodEntryDialog({
    super.key,
    this.initialRecord,
    this.defaultDate,
  });

  @override
  ConsumerState<PeriodEntryDialog> createState() => _PeriodEntryDialogState();
}

class _PeriodEntryDialogState extends ConsumerState<PeriodEntryDialog> {
  late DateTime _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialRecord != null) {
      _startDate = widget.initialRecord!.startDate;
      _endDate = widget.initialRecord!.endDate;
      _isOngoing = _endDate == null;
    } else {
      _startDate = AppDateUtils.dateOnly(widget.defaultDate ?? DateTime.now());
      _isOngoing = true;
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _startDate = AppDateUtils.dateOnly(picked);
        if (_endDate != null && _endDate!.isBefore(_startDate)) {
          _endDate = null;
          _isOngoing = true;
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _endDate = AppDateUtils.dateOnly(picked);
        _isOngoing = false;
      });
    }
  }

  void _save() {
    final record = widget.initialRecord != null
        ? widget.initialRecord!.copyWith(
            startDate: _startDate,
            endDate: _isOngoing ? null : _endDate,
            clearEndDate: _isOngoing,
          )
        : CycleRecord(
            startDate: _startDate,
            endDate: _isOngoing ? null : _endDate,
          );

    ref.read(cycleRecordsProvider.notifier).addOrUpdate(record);
    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.initialRecord != null) {
      ref.read(cycleRecordsProvider.notifier).delete(widget.initialRecord!.id);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.initialRecord != null ? 'Edit Period Record' : 'Record Actual Period'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter confirmed start and end dates as shared by your partner. Only actual dates are recorded.',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 18),
            // Start Date Selector
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today_outlined, color: Colors.redAccent),
              title: const Text('Period Start Date'),
              subtitle: Text(AppDateUtils.formatShortDate(_startDate)),
              trailing: TextButton(
                onPressed: _pickStartDate,
                child: const Text('Change'),
              ),
            ),
            const Divider(),
            // Ongoing Checkbox
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Period is still ongoing / End date unknown'),
              value: _isOngoing,
              onChanged: (val) {
                setState(() {
                  _isOngoing = val ?? true;
                  if (_isOngoing) _endDate = null;
                });
              },
            ),
            if (!_isOngoing) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.event_available_outlined, color: Colors.green),
                title: const Text('Period End Date'),
                subtitle: Text(
                  _endDate != null
                      ? AppDateUtils.formatShortDate(_endDate!)
                      : 'Select end date',
                ),
                trailing: TextButton(
                  onPressed: _pickEndDate,
                  child: const Text('Select'),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (widget.initialRecord != null)
          TextButton(
            onPressed: _delete,
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            child: const Text('Delete'),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save Record'),
        ),
      ],
    );
  }
}
