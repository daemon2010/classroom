import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:url_launcher/url_launcher.dart";

import "../l10n/app_localizations.dart";
import "../models/classroom_models.dart";

enum ReportSortColumn {
  student,
  email,
  course,
  subject,
  assignment,
  state,
  late,
  submitted,
}

class ReportTable extends StatelessWidget {
  const ReportTable({
    required this.rows,
    required this.sortColumn,
    required this.sortAscending,
    required this.onSort,
    this.showStudentEmailColumn = true,
    this.showLateColumn = true,
    super.key,
  });

  final List<UngradedSubmissionReportRow> rows;
  final ReportSortColumn sortColumn;
  final bool sortAscending;
  final void Function(ReportSortColumn column, bool ascending) onSort;
  final bool showStudentEmailColumn;
  final bool showLateColumn;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (rows.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(child: Text(l10n.noUngradedWork)),
      );
    }

    final dateFormat = DateFormat("yyyy-MM-dd HH:mm", l10n.localeName);
    var columnIndex = 0;
    int? sortColumnIndex;

    DataColumn sortableColumn(String label, ReportSortColumn column) {
      final currentIndex = columnIndex;
      columnIndex += 1;
      if (sortColumn == column) {
        sortColumnIndex = currentIndex;
      }

      return DataColumn(
        label: Text(label),
        onSort: (_, ascending) => onSort(column, ascending),
      );
    }

    DataColumn plainColumn(String label) {
      columnIndex += 1;
      return DataColumn(label: Text(label));
    }

    final columns = [
      sortableColumn(l10n.student, ReportSortColumn.student),
      if (showStudentEmailColumn)
        sortableColumn(l10n.email, ReportSortColumn.email),
      sortableColumn(l10n.className, ReportSortColumn.course),
      sortableColumn(l10n.subject, ReportSortColumn.subject),
      sortableColumn(l10n.assignment, ReportSortColumn.assignment),
      sortableColumn(l10n.state, ReportSortColumn.state),
      if (showLateColumn) sortableColumn(l10n.late, ReportSortColumn.late),
      sortableColumn(l10n.submitted, ReportSortColumn.submitted),
      plainColumn(l10n.submission),
      plainColumn(l10n.assignment),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              headingRowHeight: 42,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 58,
              columnSpacing: 22,
              columns: columns,
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(_TableText(row.studentName, width: 150)),
                      if (showStudentEmailColumn)
                        DataCell(
                          _TableText(row.studentEmail ?? "-", width: 180),
                        ),
                      DataCell(_TableText(row.courseName, width: 150)),
                      DataCell(_TableText(row.subject ?? "-", width: 120)),
                      DataCell(_TableText(row.assignmentTitle, width: 190)),
                      DataCell(Text(_formatState(l10n, row.submissionState))),
                      if (showLateColumn)
                        DataCell(Text(row.isLate ? l10n.yes : l10n.no)),
                      DataCell(
                        Text(
                          _formatDate(
                            dateFormat,
                            row.submittedAt ?? row.updatedAt,
                          ),
                        ),
                      ),
                      DataCell(_OpenButton(url: row.submissionUrl)),
                      DataCell(_OpenButton(url: row.assignmentUrl)),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateFormat dateFormat, DateTime? value) {
    if (value == null) {
      return "-";
    }
    return dateFormat.format(value.toLocal());
  }

  static String _formatState(AppLocalizations l10n, SubmissionState state) {
    return switch (state) {
      SubmissionState.newSubmission => l10n.newState,
      SubmissionState.created => l10n.assignedState,
      SubmissionState.turnedIn => l10n.turnedInState,
      SubmissionState.returned => l10n.returnedState,
      SubmissionState.reclaimedByStudent => l10n.takenBackState,
      SubmissionState.unknown => l10n.unknown,
    };
  }
}

class _TableText extends StatelessWidget {
  const _TableText(this.value, {required this.width});

  final String value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }
}

class _OpenButton extends StatelessWidget {
  const _OpenButton({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final value = url;
    return TextButton(
      onPressed: value == null || value.isEmpty
          ? null
          : () => launchUrl(
              Uri.parse(value),
              mode: LaunchMode.externalApplication,
            ),
      child: Text(context.l10n.open),
    );
  }
}
