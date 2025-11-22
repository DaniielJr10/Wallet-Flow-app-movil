// Conditional export: when building for web the implementation in
// `web_downloader_web.dart` (which imports dart:html) will be used.
export 'web_downloader_stub.dart'
  if (dart.library.html) 'web_downloader_web.dart';
