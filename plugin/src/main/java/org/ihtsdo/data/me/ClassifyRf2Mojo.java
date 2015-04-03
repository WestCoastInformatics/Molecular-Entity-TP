package org.ihtsdo.data.me;

import java.io.File;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;
import org.ihtsdo.classifier.ClassificationRunner;

/**
 * Goal which classifies RF2 files.
 * 
 * See pom.xml for sample usage
 * 
 * @goal classify-rf2
 * @phase package
 */
public class ClassifyRf2Mojo extends AbstractMojo {

  /**
   * The config file.
   * @parameter
   * @required
   */
  private String configFile;

  /*
   * (non-Javadoc)
   * 
   * @see org.apache.maven.plugin.Mojo#execute()
   */
  @Override
  public void execute() throws MojoFailureException {
    try {
      getLog().info("Classifying RF2");
      getLog().info("  configFile = " + configFile);
      ClassificationRunner cc = new ClassificationRunner(new File(configFile));
      cc.execute();
      getLog().info("Done");
    } catch (Exception e) {
      e.printStackTrace();
      throw new MojoFailureException("Unexpected failure.", e);
    }

  }
}
