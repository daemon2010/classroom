import "package:csv/csv.dart";
import "package:intl/intl.dart";

import "../models/classroom_models.dart";

class CsvExportService {
  String buildCsv(List<UngradedSubmissionReportRow> rows) {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    final data = <List<Object?>>[
      const [
        "Course",
        "Assignment",
        "Student",
        "Submission state",
        "Due date",
        "Updated",
        "Course ID",
        "CourseWork ID",
        "Submission ID",
      ],
      ...rows.map(
        (row) => [
          row.courseName,
          row.assignmentTitle,
          row.studentName,
          row.submissionState.name,
          _formatDate(dateFormat, row.dueDate),
          _formatDate(dateFormat, row.updatedAt),
          row.courseId,
          row.courseWorkId,
          row.submissionId,
        ],
      ),
    ];

    return const CsvEncoder().convert(data);
  }

  Future<void> exportCsvFile(List<UngradedSubmissionReportRow> rows) async {
    throw UnimplementedError(
      "CSV file writing is intentionally not implemented yet.",
    );
  }

  String _formatDate(DateFormat dateFormat, DateTime? value) {
    if (value == null) {
      return "";
    }
    return dateFormat.format(value.toLocal());
  }
}
