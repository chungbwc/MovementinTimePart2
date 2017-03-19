public class PointInfo {
  PVector pt;
  public float x;
  public float y;
  public float w;
  public int t;

  public PointInfo() {
    x = 0;
    y = 0;
    w = 0;
    t = 0;
    pt = new PVector(x, y);
  }

  public void set(float _x, float _y, float _w, int _t) {
    x = _x;
    y = _y;
    w = _w;
    pt.set(_x, _y);
    t = _t;
  }

  public float pDist(PointInfo _p) {
    return PVector.dist(pt, _p.pt);
    //    return dist(x, y, _p.x, _p.y);
  }
}