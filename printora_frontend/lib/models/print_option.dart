class PrintOption {
  int copies;
  bool color;
  bool allPages;
  String pageRange;

  PrintOption({
    this.copies = 1,
    this.color = false,
    this.allPages = true,
    this.pageRange = "",
  });
}
