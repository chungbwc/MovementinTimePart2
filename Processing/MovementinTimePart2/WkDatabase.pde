import weka.core.converters.CSVLoader;
import weka.core.Instances;
import weka.core.DenseInstance;
import weka.core.Instance;
import weka.core.neighboursearch.KDTree;
import weka.core.neighboursearch.LinearNNSearch;
import weka.core.converters.CSVLoader;
import java.io.File;
import java.util.Enumeration;

public class WkDatabase {
  Instances data;
  KDTree tree;
  LinearNNSearch lns;
  String dataFile;
  float dist;
  int chrIdx;
  float threshold;

  public WkDatabase() {
    dataFile = "charTrain.csv";
    dist = 0;
    chrIdx = -1;
    threshold = 4;
    try {
      loadFile();
      buildModel();
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
  }

  void loadFile() throws Exception {
    CSVLoader loader = new CSVLoader();
    loader.setNoHeaderRowPresent(true);
    loader.setSource(new File(dataPath(dataFile)));
    data = loader.getDataSet();
    data.setClassIndex(0);
    println("Number of attributes : " + data.numAttributes());
    println("Number of instances : " + data.numInstances());
    //    println("Name : " + data.classAttribute().toString());
    /*
    Enumeration all = data.enumerateInstances();
     int cnt = 0;
     while (all.hasMoreElements()) {
     Instance i = (Instance) all.nextElement();
     println(cnt + "> " + (int) i.classValue() + ": " + i.toString());
     cnt++;
     }
     */
  }

  void buildModel() throws Exception {
    tree = new KDTree();
    lns = new LinearNNSearch(data);
    tree.setInstances(data);
    //    println(tree.measureTreeSize());
  }

  float predict(float [] p) throws Exception {
    //    println("Attribute length : " + data.numAttributes());
    double [] val = new double[data.numAttributes()];
    val[0] = 0;
    for (int i=0; i<p.length; i++) {
      val[i+1] = p[i];
    }
    DenseInstance inst = new DenseInstance(1.0, val);
    inst.setDataset(data);
    Instance chr = tree.nearestNeighbour(inst);
    // Instance chr = lns.nearestNeighbour(inst);
    double [] tmp1 = tree.getDistances();
    //double [] tmp1 = lns.getDistances();
    dist = (float) tmp1[0];
    chrIdx = (int) chr.classValue();
    //    print("Features from film : ");
    //    println(val);
    //    println("Matched char : " + data.instance(chrIdx).toString());
    //    println("Matched distance : " + dist);
    if (dist > threshold) {
      return -1;
    } else {
      return chrIdx;
    }
  }
}