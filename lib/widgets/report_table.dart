import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:url_launcher/url_launcher.dart";

import "../models/classroom_models.dart";

class ReportTable extends StatelessWidget {
  const ReportTable({required this.rows, super.key});

  final List<UngradedSubmissionReportRow> rows;

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

    final dateFormat = DateFormat("MMM d, HH:mm");

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
              headingRowHeight: 42,
              dataRowMinHeight: 44,
              dataRowMaxHeight: 58,
              columnSpacing: 22,
              columns: const [
                DataColumn(label: Text("Student")),
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Class")),
                DataColumn(label: Text("Subject")),
                DataColumn(label: Text("Assignment")),
                DataColumn(label: Text("State")),
                DataColumn(label: Text("Late")),
                DataColumn(label: Text("Updated")),
                DataColumn(label: Text("Submission")),
                DataColumn(label: Text("Assignment")),
              ],
              rows: [
                for (final row in rows)
                  DataRow(
                    cells: [
                      DataCell(_TableText(row.studentName, width: 150)),
                      DataCell(_TableText(row.studentEmail ?? "-", width: 180)),
                      DataCell(_TableText(row.courseName, width: 150)),
                      DataCell(_TableText(row.subject ?? "-", width: 120)),
                      DataCell(_TableText(row.assignmentTitle, width: 190)),
                      DataCell(Text(_formatState(row.submissionState))),
                      DataCell(Text(row.isLate ? "Yes" : "No")),
                      DataCell(Text(_formatDate(dateFormat, row.updatedAt))),
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
