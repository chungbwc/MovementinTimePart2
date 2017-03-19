public class Motion {
  final int MAX_PNT = 12;
  ArrayList<PointInfo> pList;
  PointInfo currP;
  PointInfo lastP;
  boolean first;
  PVector sSize;
  PVector sOff;
  PGraphics page;
  float depthFactor;
  float maxDepth;
  float colStep;

  public Motion(PVector s, PVector o) {
    sSize = s;
    sOff = o;
    currP = new PointInfo();
    lastP = new PointInfo();
    page = createGraphics((int)sSize.x, (int)sSize.y, P3D);
    first = true;
    pList = new ArrayList<PointInfo>();
    depthFactor = 10.0;
    maxDepth = -120.0;
    colStep = 256.0/MAX_PNT;
    textureMode(NORMAL);
  }

  void updatePoint(PointInfo p) {
    if (first) {
      currP.set(p.x, p.y, p.w, p.t);
      lastP.set(currP.x, currP.y, currP.w, currP.t);
      first = false;
    } else {
      lastP.set(currP.x, currP.y, currP.w, currP.t);
      currP.set(p.x, p.y, p.w, p.t);
    }
  }

  void clear() {
    page.beginDraw();
    page.background(0);
    page.endDraw();
    image(page, sOff.x, sOff.y);
  }

  void addPoint(PointInfo p) {
    if (pList.size() >= MAX_PNT) {
      pList.remove(0);
    }
    pList.add(p);
  }

  void drawPoint(PImage m) {

    //page.beginDraw();
    //page.pushMatrix();
    //page.pushStyle();
    //page.noFill();
    //    page.fill(0, 0, 0, 8);
    //    page.rect(0, 0, sSize.x, sSize.y);
    int x1 = floor(constrain(lastP.x*sSize.x, 0, sSize.x-1));
    int y1 = floor(constrain(lastP.y*sSize.y, 0, sSize.y-1));
    int x2 = floor(constrain(currP.x*sSize.x, 0, sSize.x-1));
    int y2 = floor(constrain(currP.y*sSize.y, 0, sSize.y-1));
    //color c = m.pixels[floor(y2*sSize.x+x2)];
    //page.stroke(c);
    //page.strokeWeight(currP.w*10);
    //PVector t1 = new PVector(x1+lastP.t, y1);
    PVector t2 = new PVector(x2+currP.t, y2);
    //page.line(t1.x, t1.y, t2.x, t2.y);

    //page.popStyle();
    //page.popMatrix();
    //page.endDraw();

    PointInfo pt = new PointInfo();
    pt.set(t2.x, t2.y, currP.w, currP.t);
    addPoint(pt);

    page.beginDraw();
    page.background(0);
    page.noFill();
    page.beginShape();
    for (int i=0; i<pList.size(); i++) {
      PointInfo pp = pList.get(i);
      int x3 = floor(constrain(pp.x, 0, sSize.x-1));
      int y3 = floor(constrain(pp.y, 0, sSize.y-1));
      color col = m.pixels[floor(y3*sSize.x+x3)];
      page.stroke(red(col), green(col), blue(col), i*colStep);
      //page.stroke(200, 200, 200, i*colStep);
      page.strokeWeight(max(2, pp.w*4));
      page.curveVertex(pp.x, pp.y, i*depthFactor+maxDepth);
    }
    page.endShape();
    page.endDraw();
    image(page, sOff.x, sOff.y);
  }
}