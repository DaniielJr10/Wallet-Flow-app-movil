// Stub used when dart:html is not available (non-web platforms).
// The real implementation is in web_downloader_web.dart and is selected
// automatically via the conditional export in `web_downloader.dart`.

void downloadBytesAsFile(List<int> bytes, String filename, String mimeType) {
  // Not supported on non-web; callers should guard with kIsWeb.
  throw UnsupportedError('downloadBytesAsFile is only available on web');
}
