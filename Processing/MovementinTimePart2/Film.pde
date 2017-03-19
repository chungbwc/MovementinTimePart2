class Film {
  String filmName;
  String fileName;
  int year;

  public Film(String n1, String n2, int yr) {
    filmName = n1;
    fileName = n2;
    year = yr;
  }

  String getFile() {
    return fileName;
  }

  String getFilm() {
    return filmName;
  }

  String getYear() {
    return nf(year);
  }
}