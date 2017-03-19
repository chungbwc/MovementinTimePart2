import org.opencv.video.Video;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import com.magicandlove.cvimage.*;

public class Flow {
  Mat [] frames;
  Mat result;
  int pIdx;
  int cIdx;
  int w;
  int h;

  public Flow() {
    System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
    println(Core.VERSION);
    frames = new Mat[2];
    for (int i=0; i<frames.length; i++) {
      frames[i] = new Mat(h, w, CvType.CV_8UC1);
    }
    result = new Mat();
  }

  void init(int x, int y, PImage i) {
    w = x;
    h = y;
    pIdx = 0;
    cIdx = 1;
    CVImage img = new CVImage(w, h);
    img.copy(i, 0, 0, i.width, i.height, 0, 0, w, h);
    img.updatePixels();
    img.toCV();
    for (int j=0; j<frames.length; j++) {
      (img.getGrey()).copyTo(frames[j]);
      //     frame[j].copyTo(img.getGrey());
    }
  }

  void update(PImage i) {
    CVImage img = new CVImage(w, h);
    img.copy(i, 0, 0, i.width, i.height, 0, 0, w, h);
    img.updatePixels();
    img.toCV();
    //    frame[cIdx].release();
    // frame[cIdx].copyTo(img.getGrey());
    (img.getGrey()).copyTo(frames[cIdx]);
    swapIndex();
  }

  void swapIndex() {
    int tmp = cIdx;
    cIdx = pIdx;
    pIdx = tmp;
  }

  void calcFlow() {
    Video.calcOpticalFlowFarneback(frames[pIdx], frames[cIdx], result, 
      0.5, 3, 15, 3, 5, 1.2, Video.OPTFLOW_FARNEBACK_GAUSSIAN);
  }

  PVector [][] getFlow() {
    PVector [][] tmp = new PVector[w][h];
    for (int r=0; r<h; r++) {
      for (int c=0; c<w; c++) {
        double [] val = result.get(r, c);
        tmp[c][r] = new PVector((float) val[0], (float) val[1]);
      }
    }
    return tmp;
  }
}