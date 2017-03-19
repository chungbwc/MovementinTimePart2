import processing.video.*;
// Number of films
final int CNT = 4;
// Film frame size
final int scnW = 720;
final int scnH = 360;
Film [] films;
Movie mov;
int idx;
String fmName;
// Define 4 screens.
Screen [] screens;
Flow opFlow;
float scaling;
int w, h;
boolean first;
Encode enc;
WkDatabase db;
Drawing dw;
PVector scale1, scale2;
AnimateChar animation;
//Motion mot;
PFont font, cFont;
State state;
Timer timer;

void setup() {
  size(1920, 1080, P3D);
  background(0);
  hint(DISABLE_DEPTH_TEST);
  noCursor();
  smooth();
  films = new Film[CNT];
  films[1] = new Film("Hero", "Hero720x360.mp4", 2002);
  films[3] = new Film("Seven Swords", "Swords720x360.mp4", 2005);
  films[0] = new Film("Crouching Tiger, Hidden Dragon", "Tiger720x360.mp4", 2000);
  films[2] = new Film("House of Flying Daggers", "Daggers720x360.mp4", 2004);
  idx = 0;
  mov = new Movie(this, films[idx].getFile());
  mov.play();
  mov.read();
  fmName = films[idx].getFilm() + " " + films[idx].getYear();
  screens = new Screen[4];
  for (int i=0; i<screens.length; i++) {
    screens[i] = new Screen(i, scnW, scnH);
  }
  scaling = 10.0;
  w = floor(scnW/scaling);
  h = floor(scnH/scaling);
  opFlow = new Flow();
  enc = new Encode(w, h);
  scale1 = new PVector(scnW, scnH);
  scale2 = new PVector(scnH, scnH);
  first = true;
  db = new WkDatabase();
  dw = new Drawing();
  animation = new AnimateChar(screens[3].offset, scale1);
  //  mot = new Motion(scale1, screens[1].offset);
  directionalLight(255, 255, 255, 1, 1, 1);
  font = loadFont("MyriadPro-Regular-24.vlw");
  cFont = loadFont("STKaiti-40.vlw");
  state = State.START;
  frameRate(30);
}

void draw() {
  switch (state) {
  case START:
    timer = new Timer();
    timer.schedule(new Reminder(this), 2500);
    state = State.BLANK1;
    break;
  case BLANK1:
    blank();
    break;
  case TITLE:
    title();
    break;
  case MAIN:
    mainMovie();
    break;
  case BLANK2:
    blank();
    break;
  case CREDIT:
    credit();
    break;
  }
}

void blank() {
  background(0);
}

void mainMovie() {
  if (!mov.available()) 
    return;
  clearScreen();
  lights();
  mov.read();
  //  image(mov, screens[0].offset.x, screens[0].offset.y);
  if (first) {
    first = false;
    opFlow.init(w, h, mov);
  }
  float rat = mov.time() / mov.duration();
  if (rat > 0.95) {
    nextMovie();
  } else {
    opFlow.update(mov);
    opFlow.calcFlow();
    enc.accumAngles(opFlow.getFlow());
    //    enc.drawGrid(mov, screens[1].offset, scale1);
    enc.drawFixedGrid(mov, screens[2].offset, scale1);
    drawFlow(screens[0].offset);
    //PVector oSet = new PVector(enc.getXOffset(scnW), 0);
    int rc = matchFlow();
    if (rc != -1) {

      //      dw.drawChar(PVector.add(oSet, screens[1].offset), scale2);
      //int cnt = animation.getNumStrokes();
      //for (int i=0; i<cnt; i++) {
      //  animation.update();
      //  animation.render();
      //}
      //dw.drawChar(screens[3].offset, scale2);
    }
    int cnt = animation.getNumStrokes()*10;
    for (int i=0; i<cnt; i++) {
      animation.update();
      animation.render();
    }
    dw.showChar(screens[1].offset);
    //    mot.drawPoint(mov);
    //animation.drawPoint(mov, screens[1].offset);
  }
  text(fmName, screens[0].offset.x+5, screens[0].offset.y-30);
}

void nextMovie() {
  if (mov == null) 
    return;
  mov.stop();
  idx++;
  if (idx >= CNT) {
    state = State.BLANK2;
    timer = new Timer();
    timer.schedule(new Reminder(this), 2500);
  } else {
    mov = new Movie(this, films[idx].getFile());
    mov.play();
    fmName = films[idx].getFilm() + " " + films[idx].getYear();
    //    mot.clear();
    dw.clear();
  }
}

void drawFlow(PVector off) {
  PVector [][] ff = opFlow.getFlow();
  int cols = ff.length;
  int rows = ff[0].length;
  int len = floor(scaling/2);
  pushStyle();
  strokeWeight(2);
  PVector pos1 = new PVector(0, 0);
  PVector pos2 = new PVector(0, 0);
  for (int x=0; x<cols; x++) {
    pos1.x = floor(x*scaling);
    for (int y=0; y<rows; y++) {
      pos1.y = floor(y*scaling);
      color col = mov.pixels[floor(pos1.y*mov.width+pos1.x)];
      stroke(col);
      pos2 = PVector.add(pos1, PVector.mult(ff[x][y], len));
      pos2.x = constrain(pos2.x, 0, scnW-1);
      pos2.y = constrain(pos2.y, 0, scnH-1);
      PVector t1 = PVector.add(pos1, off);
      PVector t2 = PVector.add(pos2, off);
      line(t1.x, t1.y, t2.x, t2.y);
    }
  }
  popStyle();
}

int matchFlow() {
  float matRes = -1;
  try {
    //      println("Feature length : " + enc.getFeatures().length);
    matRes = db.predict(enc.getFeatures());
  } 
  catch (Exception e) {
    e.printStackTrace();
  }
  if (matRes != -1) {
    dw.setFile((int) matRes);
    animation.setFile((int) matRes);
  }
  return (int) matRes;
}

void clearScreen() {
  background(0);
  screens[0].clear(color(0, 0, 0));
  screens[1].clear(color(0, 0, 0)); 
  screens[2].clear(color(0, 0, 0));
  screens[3].clear(color(0, 0, 0));
}

void timesUp() {
  // Timer callback
  if (state == State.BLANK1) {
    state = State.TITLE;
    timer = new Timer();
    timer.schedule(new Reminder(this), 3000);
    state = State.TITLE;
  } else if (state == State.TITLE) {
    state = State.MAIN;
    textFont(font, 16);
  } else if (state == State.BLANK2) {
    state = State.CREDIT;
    timer = new Timer();
    timer.schedule(new Reminder(this), 5000);
  } else if (state == State.CREDIT) {
    exit();
  }
}

void title() {
  // Display artwork title.
  background(0);
  textFont(font, 48);
  text("Movement in Time, Part II", 700, 500);
}

void credit() {
  // Display credit information.
  background(0);
  textFont(font, 32);
  text("Bryan Chung", 750, 300);
  text("Lisa Lam", 750, 350);
  text("Perry Tang", 750, 400);
  text("Academy of Visual Arts", 750, 550);
  text("Hong Kong Baptist University", 750, 600);
  text("2016", 750, 650);
}

void keyPressed() {
  nextMovie();
}