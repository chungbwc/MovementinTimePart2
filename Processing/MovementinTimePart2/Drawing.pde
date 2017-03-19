import java.util.Arrays;
import java.io.FilenameFilter;
import java.io.File;
import processing.data.XML;

public class Drawing {
  final int ROWS = 7;
  final int COLS = 16;
  final int MAX_CHR = ROWS*COLS;
  final int XGAP = 47;
  final int YGAP = 46;

  int [] pages;
  File [] files;
  String fName;
  int idx;
  int chr;
  int cnt;
  XML xml;
  float factor;
  boolean drawn;

  public Drawing() {
    factor = 16.0;
    files = getFiles();
    Arrays.sort(files);
    drawn = false;
    idx = 0;
    chr = 0;
    cnt = 0;
    pages = new int[MAX_CHR];
  }

  File [] getFiles() {
    File [] fs;
    File dir = new File(dataPath(""));
    fs = dir.listFiles(new FilenameFilter() {
      public boolean accept(File d, String n) {
        return n.toLowerCase().endsWith(".xml");
      }
    }
    );
    return fs;
  }

  void setFile(int i) {
    if (i < 1) {
      drawn = false;
      return;
    }
    fName = files[i-1].getName();
    xml = loadXML(fName);
    char cc = fName.charAt(5);
    pages[cnt] = int(cc);
    if (cnt == 0) {
      for (int j=1; j<MAX_CHR; j++) {
        pages[j] = 0;
      }
    }
    cnt++;
    cnt %= MAX_CHR;
    drawn = true;
  }

  void drawChar(PVector o, PVector s) {
    if (!drawn) 
      return;
    XML [] strokes = xml.getChildren("stroke");
    pushStyle();
    //stroke(255, 100, 255);
    stroke(160, 160, 160);
    for (XML x : strokes) {
      XML [] pts = x.getChildren("point");
      if (pts.length < 2) 
        continue;
      for (int i=0; i<pts.length-1; i++) {
        XML pt1 = pts[i];
        XML pt2 = pts[i+1];
        float x1 = pt1.getChild("x").getFloatContent();
        float y1 = pt1.getChild("y").getFloatContent();
        float x2 = pt2.getChild("x").getFloatContent();
        float y2 = pt2.getChild("y").getFloatContent();
        float w1 = pt1.getChild("w").getFloatContent();
        strokeWeight(w1*factor);
        line(x1*s.x+o.x, y1*s.y+o.y, x2*s.x+o.x, y2*s.y+o.y);
      }
    }
    popStyle();
  }

  void clear() {
    drawn = false;
    cnt = 0;
    for (int i=0; i<pages.length; i++) {
      pages[i] = 0;
    }
  }

  void showChar(PVector o) {
    pushStyle();
    noStroke();
    fill(200);
    textFont(cFont, 40);
    for (int i=0; i<pages.length; i++) {
      if (pages[i] == 0) 
        continue;
      int x = (COLS-1) - (i / ROWS);
      int y = i % ROWS;
      text(char(pages[i]), x*XGAP+o.x, y*YGAP+o.y+44);
    }
    popStyle();
  }
}