import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:url_launcher/url_launcher.dart";

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
    if (rows.isEmpty) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text("No ungraded Classroom work to show.")),
      );
    }

    final dateFormat = DateFormat("MMM d, yyyy HH:mm");
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
      sortableColumn("Student", ReportSortColumn.student),
      if (showStudentEmailColumn)
        sortableColumn("Email", ReportSortColumn.email),
      sortableColumn("Class", ReportSortColumn.course),
      sortableColumn("Subject", ReportSortColumn.subject),
      sortableColumn("Assignment", ReportSortColumn.assignment),
      sortableColumn("State", ReportSortColumn.state),
      if (showLateColumn) sortableColumn("Late", ReportSortColumn.late),
      sortableColumn("Submitted", ReportSortColumn.submitted),
      plainColumn("Submission"),
      plainColumn("Assignment"),
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
                      DataCell(Text(_formatState(row.submissionState))),
                      if (showLateColumn)
                        DataCell(Text(row.isLate ? "Yes" : "No")),
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

  static String _formatState(SubmissionState state) {
    return switch (state) {
      SubmissionState.newSubmission => "New",
      SubmissionState.created => "Assigned",
      SubmissionState.turnedIn => "Turned in",
      SubmissionState.returned => "Returned",
      SubmissionState.reclaimedByStudent => "Taken back",
      SubmissionState.unknown => "Unknown",
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
      child: const Text("Open"),
    );
  }
}
