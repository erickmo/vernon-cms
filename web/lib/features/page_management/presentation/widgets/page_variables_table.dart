import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Widget untuk edit variables halaman sebagai child table (key-value pairs).
class PageVariablesTable extends StatefulWidget {
  /// Initial variables map.
  final Map<String, dynamic> variables;

  /// Called when variables change.
  final ValueChanged<Map<String, dynamic>> onChanged;

  const PageVariablesTable({
    super.key,
    required this.variables,
    required this.onChanged,
  });

  @override
  State<PageVariablesTable> createState() => _PageVariablesTableState();
}

class _PageVariablesTableState extends State<PageVariablesTable> {
  late List<_VariableRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.variables.entries
        .map((e) => _VariableRow(
              key: e.key,
              value: e.value?.toString() ?? '',
            ))
        .toList();
    if (_rows.isEmpty) _rows.add(const _VariableRow(key: '', value: ''));
  }

  void _notifyChanged() {
    final map = <String, dynamic>{};
    for (final row in _rows) {
      if (row.key.trim().isNotEmpty) {
        map[row.key.trim()] = row.value;
      }
    }
    widget.onChanged(map);
  }

  void _addRow() {
    setState(() {
      _rows.add(const _VariableRow(key: '', value: ''));
    });
  }

  void _removeRow(int index) {
    setState(() {
      _rows.removeAt(index);
      if (_rows.isEmpty) _rows.add(const _VariableRow(key: '', value: ''));
    });
    _notifyChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        _buildRows(),
        _buildFooter(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.divider),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusM),
        ),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Text(
              'Key',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              'Value',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildRows() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(color: AppColors.divider),
          right: BorderSide(color: AppColors.divider),
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _rows.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) => _buildRow(context, index),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.divider),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radiusM),
        ),
      ),
      child: TextButton.icon(
        onPressed: _addRow,
        icon: const Icon(Icons.add, size: 16),
        label: const Text(
          'Tambah variabel',
          style: TextStyle(fontSize: 12),
        ),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
          shape: const RoundedRectangleBorder(),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, int index) {
    final row = _rows[index];
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: AppDimensions.spacingXS,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: row.key,
              decoration: const InputDecoration(
                hintText: 'nama_variabel',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                  fontFamily: 'monospace',
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: AppDimensions.spacingXS,
                ),
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
              ),
              onChanged: (val) {
                _rows[index] = _VariableRow(key: val, value: row.value);
                _notifyChanged();
              },
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppColors.divider,
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: TextFormField(
              initialValue: row.value,
              maxLines: null,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'nilai (teks, angka, true/false, atau JSON)',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                  vertical: AppDimensions.spacingXS,
                ),
                isDense: true,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
              ),
              onChanged: (val) {
                _rows[index] = _VariableRow(key: row.key, value: val);
                _notifyChanged();
              },
            ),
          ),
          IconButton(
            onPressed: () => _removeRow(index),
            icon: const Icon(Icons.close, size: 16),
            color: AppColors.textHint,
            tooltip: 'Hapus',
            style: IconButton.styleFrom(
              minimumSize: const Size(32, 32),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariableRow {
  final String key;
  final String value;
  const _VariableRow({required this.key, required this.value});
}
