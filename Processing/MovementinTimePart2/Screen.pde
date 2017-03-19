public class Screen {
  // Define the 4 screens.
  int id;
  PVector size;
  PVector offset;

  public Screen(int i, int w, int h) {
    id = i;
    int x = i % 2;
    int y = i / 2;
    size = new PVector(w, h);
    int xOff = (width - w*2)/2;
    int yOff = (height - h*2)/2;
    offset = new PVector(xOff + x*w, yOff + y*h);
  }

  void clear(color c) {
    pushStyle();
    fill(c);
    rect(offset.x, offset.y, size.x, size.y);
    popStyle();
  }
}