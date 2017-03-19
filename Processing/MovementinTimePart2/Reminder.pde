import java.lang.reflect.Method;
import java.util.Timer;
import java.util.TimerTask;

public class Reminder extends TimerTask {
  Timer timer;
  PApplet parent;
  Method method;

  public Reminder(PApplet p) {
    parent = p;
    try {
      method = parent.getClass().getMethod("timesUp");
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }

  public void run() {
    println("Time is up ...");
    try {
      method.invoke(parent);
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }
}