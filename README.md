# example_reader_epub

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

### : example demo reading .epub file from assets( pakage epub_view và epubx tôi dùng toàn bị lỗi "EPUB parsing error: file OEBPS/../js/kobo.js not found in archive." cáu thật sự)
### b1: đọc file theo đúng hướng dẫn trên pub.dev
      final data = await rootBundle.load('assets/Flutter.epub');
      final epub = Epub.fromBytes(data.buffer.asUint8List());
### b2: sử dụng epub_decoder để lấy title(string) , author(list<String>), sections(list<section>), coverImg(Item)

### b2:
#### + để đọc được ảnh coverImg có type Item sử dụng "epub.cover!.fileContent" nó trả về dạng Uint8List()
#### + nội dung section thì "epub.section.content.fileContent"

# example_reader_epub_file_does_not_use_reader
