// Web implementation using `dart:html`.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

void downloadBytesAsFile(List<int> bytes, String filename, String mimeType) {
  final blob = html.Blob([bytes], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement;
  anchor.href = url;
  anchor.download = filename;
  html.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
