package org.ihtsdo.data.me;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;

/**
 * Goal which combines sets of RF2 files.
 * 
 * See pom.xml for sample usage
 * 
 * @goal combine-rf2
 * @phase package
 */
public class CombineRf2Mojo extends AbstractMojo {

  /**
   * The first input directory.
   * @parameter
   * @required
   */
  private String rf2Dir1;

  /**
   * The second input directory.
   * @parameter
   * @required
   */
  private String rf2Dir2;

  /**
   * The output directory.
   * @parameter
   * @required
   */
  private String outputDir;

  /**
   * The effectiveTime.
   * @parameter
   * @required
   */
  private String effectiveTime;

  /*
   * (non-Javadoc)
   * 
   * @see org.apache.maven.plugin.Mojo#execute()
   */
  @SuppressWarnings({
      "unused", "resource"
  })
  @Override
  public void execute() throws MojoFailureException {
    try {
      getLog().info("Combining RF2");
      getLog().info("  rf2Dir1 = " + rf2Dir1);
      getLog().info("  rf2Dir2 = " + rf2Dir2);
      getLog().info("  outputDir = " + outputDir);
      getLog().info("  effectiveTime = " + effectiveTime);

      new File(outputDir).mkdirs();
      
      // String[] allFiles =
      // new String[] {
      // "_Concept_", "_Description_", "_Identifier_", "_Relationship_",
      // "_StatedRelationship_", "_TextDefinition_",
      // "_AssociationReference", "_AttributeValue", "_Refset_Simple",
      // "_Language", "_ExtendedMap", "_ComplexMap", "_SimpleMap",
      // "_RefsetDescriptor", "_DescriptionType", "_ModuleDependency"
      // };

      String[] files =
          new String[] {
              "_Concept_", "_Description_", "_Relationship_",
              "_StatedRelationship_", "_TextDefinition_", "_Language",
              "_SimpleMap"
          };

      for (String frag : files) {
        File file1 = getFile(new File(rf2Dir1), frag);
        File file2 = getFile(new File(rf2Dir2), frag);
        if (file1 == null && file2 == null) {
          throw new Exception("Could not find " + frag + " in " + rf2Dir2);
        }

        BufferedReader in1 = new BufferedReader(new FileReader(file1));
        BufferedReader in2 = new BufferedReader(new FileReader(file2));
        File outputFile = new File(outputDir, getFilename(
            rf2Dir1, file1));
        outputFile.getParentFile().mkdirs();
        PrintWriter out =
            new PrintWriter(new FileWriter(outputFile));
      }

      getLog().info("Done");
    } catch (Exception e) {
      e.printStackTrace();
      throw new MojoFailureException("Unexpected failure.", e);
    }

  }

  /**
   * Returns the portion of the filename after the directory.
   *
   * @param dir the dir
   * @param file the file
   * @return the filename
   * @throws IOException 
   */
  public String getFilename(String dir, File file) throws IOException {
    File dirFile = new File(dir);
    String filename = file.getCanonicalFile().toString()
        .substring(dirFile.getCanonicalFile().toString().length()+1);
    getLog().info("Filename = " + filename);
    return filename;
  }

  /**
   * Returns the file.
   *
   * @param dir the dir
   * @param frag the frag
   * @return the file
   */
  public File getFile(File dir, String frag) {
    for (File f : dir.listFiles()) {
      if (f.getName().contains(frag)) {
        return f;
      }
      if (f.isDirectory()) {
        File f2 = getFile(f, frag);
        if (f2 != null) {
          return f2;
        }
      }
    }
    return null;
  }
}
