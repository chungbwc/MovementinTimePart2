public class Grid {
  PVector angles;

  public Grid() {
    angles = new PVector(0.0, 0.0);
  }

  void reset() {
    angles.set(0.0, 0.0);
  }

  void accumAngles(PVector v) {
    angles.add(v);
  }
}