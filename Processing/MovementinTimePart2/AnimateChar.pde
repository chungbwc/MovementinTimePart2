import java.util.Arrays;
import java.io.FilenameFilter;
import java.io.File;
import processing.data.XML;

public class AnimateChar {
  private File [] files;
  private XML [] strokes;
  private XML [] points;
  private XML xml;
  private color [] strokeCol;
  private XML currStroke;
  private PointInfo lastPt;
  private PointInfo currPt;
  private PointInfo drawPt;
  private int strokeIdx;
  private int pointIdx;
  private PVector offset;
  private boolean moving;
  private boolean initialized;
  private float depthFactor;
  private float strokeFactor;
  private float widthFactor;
  private String fName;
  private PVector mSize;
  private int nStrokes;
  private float rotY;

  public AnimateChar(PVector of, PVector sc) {
    lastPt = new PointInfo();
    currPt = new PointInfo();
    drawPt = new PointInfo();
    moving = false;
    initialized = false;
    depthFactor = 70;
    strokeFactor = 4;
    widthFactor = 0.02;
    mSize = new PVector(sc.x, sc.y);
    offset = new PVector(of.x+mSize.x/2, of.y+mSize.y/2, depthFactor/2);
    files = getFiles();
    Arrays.sort(files);
    rotY = 0.0;
  }

  public void init(XML [] _s) {
    strokes = _s;
    strokeIdx = 0;
    pointIdx = 0;
    if (strokes.length > 0) {
      nStrokes = strokes.length;
      strokeCol = new color[strokes.length];
      for (int i=0; i<strokes.length; i++) {
        strokeCol[i] = color(random(255), random(255), random(255));
      }
      currStroke = strokes[strokeIdx];
      points = currStroke.getChildren("point");
      if (points.length > 0) {
        getCurrPt(points[0]);
        lastPt.set(currPt.x, currPt.y, currPt.w, currPt.t);
        moving = true;
      }
    }
    initialized = true;
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

  public void getCurrPt(XML _p) {
    float x = _p.getChild("x").getFloatContent();
    float y = _p.getChild("y").getFloatContent();
    float w = _p.getChild("w").getFloatContent();
    int t = _p.getChild("t").getIntContent();
    currPt.set(x, y, w, t);
  }

  public void getDrawPt(XML _p) {
    float x = _p.getChild("x").getFloatContent();
    float y = _p.getChild("y").getFloatContent();
    float w = _p.getChild("w").getFloatContent();
    int t = _p.getChild("t").getIntContent();
    drawPt.set(x, y, w, t);
  }

  public boolean getMoving() {
    return moving;
  }

  public void update() {
    if (!moving || !initialized) 
      return;
    pointIdx++;
    if (pointIdx >= points.length) {
      strokeIdx++;
      if (strokeIdx >= strokes.length) {
        moving = false;
        strokeIdx--;
        pointIdx = points.length;
      } else {
        pointIdx = 0;
        currStroke = strokes[strokeIdx];
        points = currStroke.getChildren("point");
        if (points.length > 0) {
          getCurrPt(points[0]);
          lastPt.set(currPt.x, currPt.y, currPt.w, currPt.t);
        }
      }
    } else {
      getCurrPt(points[pointIdx]);
    }
    currPt.t = round(enc.getXOffset(mSize.x)); // not good practice ...
    //    mot.updatePoint(currPt); // not good practice ...
  }

  public void render() {
    if (!initialized)
      return;
    pushMatrix();
    translate(offset.x, offset.y, offset.z);
    rotateY(radians(rotY));
    rotY += 0.05;
    rotY %= 360;
    pushStyle();
    fill(240, 240, 240, 200);
    noStroke();
    for (int i=0; i<strokeIdx; i++) {
      XML [] pts = strokes[i].getChildren("point");
      if (pts.length == 0) 
        continue;
      getDrawPt(pts[0]);
      lastPt.set(drawPt.x, drawPt.y, drawPt.w, drawPt.t);
      //      fill(strokeCol[i]);
      beginShape(QUAD_STRIP);
      for (int j=0; j<pts.length; j++) {
        getDrawPt(pts[j]);
        float rad = lastPt.w*widthFactor;
        float ang = atan2((drawPt.y-lastPt.y), (drawPt.x-lastPt.x));
        float x1 = rad*cos(ang+HALF_PI) + lastPt.x;
        float y1 = rad*sin(ang+HALF_PI) + lastPt.y;
        float x2 = rad*cos(ang-HALF_PI) + lastPt.x;
        float y2 = rad*sin(ang-HALF_PI) + lastPt.y;
        x1 -= 0.5;
        y1 -= 0.5;
        x2 -= 0.5;
        y2 -= 0.5;
        vertex(x1*mSize.y, y1*mSize.y, -lastPt.w*depthFactor);
        vertex(x2*mSize.y, y2*mSize.y, -lastPt.w*depthFactor);
        lastPt.set(drawPt.x, drawPt.y, drawPt.w, drawPt.t);
      }
      endShape();
    }

    XML [] pts = strokes[strokeIdx].getChildren("point");
    if (pts.length == 0)
      return;
    getDrawPt(pts[0]);
    lastPt.set(drawPt.x, drawPt.y, drawPt.w, drawPt.t);
    //    fill(strokeCol[strokeIdx]);
    beginShape(QUAD_STRIP);
    for (int j=0; j<pointIdx; j++) {
      getDrawPt(pts[j]);
      float rad = lastPt.w*widthFactor;
      float ang = atan2((drawPt.y-lastPt.y), (drawPt.x-lastPt.x));
      float x1 = rad*cos(ang+HALF_PI) + lastPt.x;
      float y1 = rad*sin(ang+HALF_PI) + lastPt.y;
      float x2 = rad*cos(ang-HALF_PI) + lastPt.x;
      float y2 = rad*sin(ang-HALF_PI) + lastPt.y;
      x1 -= 0.5;
      y1 -= 0.5;
      x2 -= 0.5;
      y2 -= 0.5;
      vertex(x1*mSize.y, y1*mSize.y, -lastPt.w*depthFactor);
      vertex(x2*mSize.y, y2*mSize.y, -lastPt.w*depthFactor);
      lastPt.set(drawPt.x, drawPt.y, drawPt.w, drawPt.t);
    }
    endShape();
    popStyle();
    popMatrix();
  }

  void setFile(int i) {
    if (i < 1) {
      moving = false;
      return;
    }
    fName = files[i-1].getName();
    xml = loadXML(fName);
    init(xml.getChildren("stroke"));
  }

  int getNumStrokes() {
    return nStrokes;
  }
}