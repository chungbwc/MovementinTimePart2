public class Encode {
  final int H = 5;
  final int SIZE = H*H;
  final float MIN_LEN = 2;
  final int TYPE = 2;

  float [] features;
  Grid [] grids;
  int W;
  int nStrokes;
  int xStart;

  public Encode(int w, int h) {
    features = new float[SIZE*TYPE];
    W = floor(w*H/h);
    grids = new Grid[W*H];
    for (int i=0; i<grids.length; i++) {
      grids[i] = new Grid();
    }
    resetData();
    nStrokes = 1;
    xStart = 0;
  }

  int getLength() {
    return features.length;
  }

  float [] getFeatures() {
    return features;
  }

  void resetData() {
    for (int i=0; i<features.length; i++) {
      features[i] = 0.0;
    }
    for (Grid g : grids) {
      g.reset();
    }
  }

  void accumAngles(PVector [][] f) {
    resetData();
    int w = f.length;
    int h = f[0].length;

    float xStep = w/W;
    float yStep = h/H;

    for (int x=0; x<w; x++) {
      int xIdx = constrain(floor(x/xStep), 0, W-1);
      for (int y=0; y<h; y++) {
        int yIdx = constrain(floor(y/yStep), 0, H-1);
        grids[yIdx*W+xIdx].accumAngles(f[x][y]);
      }
    }
    prepareData();
  }

  void prepareData() {
    xStart = 0;
    int diff = W - H + 1;
    float max_val = Float.MIN_VALUE;
    for (int t=0; t<diff; t++) {
      float sum = 0.0;
      for (int x=0; x<H; x++) {
        for (int y=0; y<H; y++) {
          int idx = y*W+(x+t);
          sum += grids[idx].angles.mag();
        }
      }
      if (sum > max_val) {
        max_val = sum;
        xStart = t;
      }
    }
    float mn = Float.MAX_VALUE;
    float mx = Float.MIN_VALUE;
    for (int x=0; x<H; x++) {
      int x1 = x+xStart;
      for (int y=0; y<H; y++) {
        float v = grids[y*W+x1].angles.mag();
        if (v < mn) {
          mn = v;
        } 
        if (v > mx) {
          mx = v;
        }
      }
    }
    float range = mx - mn;
    //    features[0] = nStrokes/10.0;
    int i=0;
    for (int x=0; x<H; x++) {
      int x1 = x+xStart;
      for (int y=0; y<H; y++) {
        float len = grids[y*W+x1].angles.mag();
        len = (len - mn)/range;
        float ang = degrees(grids[y*W+x1].angles.heading());
        if (ang < 0) {
          ang += 360;
        }
        features[i] = len;
        features[i+SIZE] = ang / 360.0;
        i++;
      }
    }
  }

  void drawGrid(PImage m, PVector o, PVector s) {
    float factor = 0.9;
    PVector step = new PVector(s.x/W, s.y/H);
    //   float xStep = s.x/W;
    //   float yStep = s.y/H;

    float mn = Float.MAX_VALUE;
    float mx = Float.MIN_VALUE;
    for (int x=0; x<H; x++) {
      int x1 = x+xStart;
      for (int y=0; y<H; y++) {
        float v = grids[y*W+x1].angles.mag();
        if (v < mn) {
          mn = v;
        } 
        if (v > mx) {
          mx = v;
        }
      }
    }
    float range = mx - mn;
    pushStyle();
    noFill();
    rectMode(CENTER);
    for (int x=0; x<H; x++) {
      for (int y=0; y<H; y++) {
        int x0 = x + xStart;
        float ang = grids[y*W+x0].angles.heading();
        float x1 = constrain(x0*step.x+step.x/2, 0, m.width-1);
        float y1 = constrain(y*step.y+step.y/2, 0, m.height-1);
        color col = m.pixels[floor(y1*m.width+x1)];
        noStroke();
        fill(red(col), green(col), blue(col), 180);
        rect(x1+o.x, y1+o.y, step.x-4, step.y-4);
        stroke(255, 200, 0);
        float rad = (grids[y*W+x0].angles.mag()-mn)*(min(step.x, step.y)/2)/range;
        rad *= factor;
        /*
        float x2 = x1 + rad*cos(ang);
         float y2 = y1 + rad*sin(ang);
         float x3 = x1 + rad*cos(ang+PI);
         float y3 = y1 + rad*sin(ang+PI);
         float r = rad/4;
         float x4 = x2 + r*cos(ang+PI/1.2);
         float y4 = y2 + r*sin(ang+PI/1.2);
         float x5 = x2 + r*cos(ang-PI/1.2);
         float y5 = y2 + r*sin(ang-PI/1.2);
         //      stroke(col);
         line(x1+o.x, y1+o.y, x2+o.x, y2+o.y);
         line(x1+o.x, y1+o.y, x3+o.x, y3+o.y);
         line(x2+o.x, y2+o.y, x4+o.x, y4+o.y);
         line(x2+o.x, y2+o.y, x5+o.x, y5+o.y);
         */
      }
    }
    popStyle();
  }

  void drawFixedGrid(PImage m, PVector o, PVector s) {
    float factor = 0.85;
    PVector step = new PVector(s.x/W, s.y/H);

    float mn = Float.MAX_VALUE;
    float mx = Float.MIN_VALUE;

    //   for (int x=0; x<H; x++) {
    for (int x=0; x<W; x++) {
      //      int x1 = x+xStart;
      int x1 = x;
      for (int y=0; y<H; y++) {
        float v = grids[y*W+x1].angles.mag();
        if (v < mn) {
          mn = v;
        } 
        if (v > mx) {
          mx = v;
        }
      }
    }
    float range = mx - mn;
    pushStyle();
    noFill();
    rectMode(CENTER);
    for (int x=0; x<W; x++) {
      //    for (int x=0; x<H; x++) {
      for (int y=0; y<H; y++) {
        //int x0 = x + xStart;
        int x0 = x;
        float ang = grids[y*W+x0].angles.heading();
        float x1 = constrain(x0*step.x+step.x/2, 0, m.width-1);
        //float x1 = constrain(x*step.x+step.x/2, 0, m.width-1);
        float y1 = constrain(y*step.y+step.y/2, 0, m.height-1);

        //noStroke();
        //       fill(red(col), green(col), blue(col), 200);
        //       rect(x1+o.x, y1+o.y, step.x-4, step.y-4);
        if (x0 < xStart || x0 >= (xStart + H)) {
          stroke(80, 80, 80);
        } else {
          noStroke();
          color col = m.pixels[floor(y1*m.width+x1)];
          fill(red(col), green(col), blue(col), 220);
          rect(x1+o.x, y1+o.y, step.x-4, step.y-4);
          noFill();
          //stroke(250, 250, 250);
          stroke(255-red(col), 255-green(col), 255-blue(col));
        }
        float rad = (grids[y*W+x0].angles.mag()-mn)*(min(step.x, step.y)/2)/range;
        rad *= factor;
        float x2 = x1 + rad*cos(ang);
        float y2 = y1 + rad*sin(ang);
        float x3 = x1 + rad*cos(ang+PI);
        float y3 = y1 + rad*sin(ang+PI);
        float r = rad/4;
        float x4 = x2 + r*cos(ang+PI/1.2);
        float y4 = y2 + r*sin(ang+PI/1.2);
        float x5 = x2 + r*cos(ang-PI/1.2);
        float y5 = y2 + r*sin(ang-PI/1.2);
        //      stroke(col);
        //noStroke();
        //fill(10, 10, 10, 200);
        //ellipse(x1+o.x, y1+o.y, 20, 20);
        //ellipse(x2+o.x, y2+o.y, 10, 10);
        //ellipse(x3+o.x, y3+o.y, 30, 30);
        line(x1+o.x, y1+o.y, x2+o.x, y2+o.y);
        line(x1+o.x, y1+o.y, x3+o.x, y3+o.y);
        line(x2+o.x, y2+o.y, x4+o.x, y4+o.y);
        line(x2+o.x, y2+o.y, x5+o.x, y5+o.y);
      }
    }
    popStyle();
  }

  float getXOffset(float s) {
    return xStart*s/W;
  }
}