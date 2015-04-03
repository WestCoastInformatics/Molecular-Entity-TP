package org.ihtsdo.data.me;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;

/**
 * Goal which assigns UUIDs to the input files.
 * 
 * See pom.xml for sample usage
 * 
 * @goal assign-uuids
 * @phase package
 */
public class AssignUuidsMojo extends AbstractMojo {

  /**
   * The input directory.
   * @parameter
   * @required
   */
  private String inputDir;

  /**
   * The output directory.
   * @parameter
   * @required
   */
  private String outputDir;

  /** The reuse map. */
  private Map<String, String> reuseMap = new HashMap<>();

  /*
   * (non-Javadoc)
   * 
   * @see org.apache.maven.plugin.Mojo#execute()
   */
  @SuppressWarnings("resource")
  @Override
  public void execute() throws MojoFailureException {
    try {
      getLog().info("Assigning UUIDs");
      getLog().info("  inputDir = " + inputDir);
      getLog().info("  outputDir = " + outputDir);

      // Setup resources
      File outputFile = new File(outputDir);
      if (outputFile.exists()) {
        populateReuseMap();
      }
      outputFile.mkdirs();

      // Create concepts, descriptions, definitions, and language refset entries
      // assign identifiers, write RF2
      String conceptFile = "TechPrevConcepts.txt";
      BufferedReader conceptIn =
          new BufferedReader(new FileReader(new File(inputDir, conceptFile)));
      // Write out data files
      PrintWriter conceptOut =
          new PrintWriter(new FileWriter(new File(outputDir, conceptFile)));

      String line;
      // Iterate through file (no headers)
      while ((line = conceptIn.readLine()) != null) {
        // Reuse if matching
        if (reuseMap.containsKey(line)) {
          conceptOut.println(reuseMap.get(line));
          getLog().info("Reuse concept: " + line);
          continue;
        }
        String tokens[] = FieldedStringTokenizer.split(line, "|", 6);
        if (tokens.length != 6) {
          getLog().error(line);
          throw new Exception("Unexpected concept file format, tokens ct = "
              + tokens.length);
        }

        // INPUT FIELDS: fn|pt||case|chebi|def
        // OUTPUT FIELDS:
        // uuid|fn|fnuuid|fnusuuid|fngbuuid|pt|ptuuid|ptusuuid|ptgbuuid||case|chebi|def|defuuid|defusuuid|defgbuuid

        String fn = tokens[0];
        String pt = tokens[1];
        String blank = tokens[2];
        // int caseSensitiveIndex = Integer.parseInt(tokens[3]);
        String chebiId = tokens[4];
        String definition =
            (tokens[5] == null ? "" : tokens[5].replaceAll("\r", ""));

        String uuid = UUID.randomUUID().toString();
        String fnuuid = UUID.randomUUID().toString();
        String fnusuuid = UUID.randomUUID().toString();
        String fngbuuid = UUID.randomUUID().toString();
        String ptuuid = UUID.randomUUID().toString();
        String ptusuuid = UUID.randomUUID().toString();
        String ptgbuuid = UUID.randomUUID().toString();
        String defuuid = UUID.randomUUID().toString();
        String defusuuid = UUID.randomUUID().toString();
        String defgbuuid = UUID.randomUUID().toString();
        String chebiuuid = UUID.randomUUID().toString();

        String outline =
            uuid + "|" + fn + "|" + fnuuid + "|" + fnusuuid + "|" + fngbuuid
                + "|" + pt + "|" + ptuuid + "|" + ptusuuid + "|" + ptgbuuid
                + "|" + blank + "|" + tokens[3] + "|" + chebiId + "|"
                + chebiuuid + "|" + definition + "|" + defuuid + "|"
                + defusuuid + "|" + defgbuuid;
        conceptOut.println(outline);
        getLog().info(outline);

      }
      conceptIn.close();
      conceptOut.close();

      // Create concepts, descriptions, definitions, and language refset entries
      // for relationship types.
      String relTypesFile = "TechPrevRelTypes.txt";
      BufferedReader relTypesIn =
          new BufferedReader(new FileReader(new File(inputDir, relTypesFile)));
      // Write out data files
      PrintWriter relTypesOut =
          new PrintWriter(new FileWriter(new File(outputDir, relTypesFile)));

      // Iterate through file (no headers)
      while ((line = relTypesIn.readLine()) != null) {
        // Reuse if matching
        if (reuseMap.containsKey(line)) {
          relTypesOut.println(reuseMap.get(line));
          getLog().info("Reuse rel type: " + line);
          continue;
        }
        String tokens[] = FieldedStringTokenizer.split(line, "|", 4);
        if (tokens.length != 4) {
          getLog().error(line);
          throw new Exception("Unexpected relTypes file format, tokens ct = "
              + tokens.length);
        }

        // INPUT FIELDS: id|fn|pt|def
        // OUTPUT FIELDS:
        // id|uuid|fn|fnuuid|fnusuuid|fngbuuid|pt|ptuuid|ptusuuid|ptgbuuid|def|defuuid|defusuuid|defgbuuid|isauuid

        String id = tokens[0];
        String fn = tokens[1];
        String pt = tokens[2];
        String def = tokens[3];

        String uuid = UUID.randomUUID().toString();
        String fnuuid = UUID.randomUUID().toString();
        String fnusuuid = UUID.randomUUID().toString();
        String fngbuuid = UUID.randomUUID().toString();
        String ptuuid = UUID.randomUUID().toString();
        String ptusuuid = UUID.randomUUID().toString();
        String ptgbuuid = UUID.randomUUID().toString();
        String defuuid = UUID.randomUUID().toString();
        String defusuuid = UUID.randomUUID().toString();
        String defgbuuid = UUID.randomUUID().toString();
        String isauuid = UUID.randomUUID().toString();

        String outline =
            id + "|" + uuid + "|" + fn + "|" + fnuuid + "|" + fnusuuid + "|"
                + fngbuuid + "|" + pt + "|" + ptuuid + "|" + ptusuuid + "|"
                + ptgbuuid + "|" + def + "|" + defuuid + "|" + defusuuid + "|"
                + defgbuuid + "|" + isauuid;
        relTypesOut.println(outline);
        getLog().info(outline);

      }
      relTypesIn.close();
      relTypesOut.close();

      // Create relationships
      String relsFile = "TechPrevRels.txt";
      BufferedReader relsIn =
          new BufferedReader(new FileReader(new File(inputDir, relsFile)));
      // Write out data files
      PrintWriter relsOut =
          new PrintWriter(new FileWriter(new File(outputDir, relsFile)));

      // Iterate through file (no headers)
      while ((line = relsIn.readLine()) != null) {
        // Reuse if matching
        if (reuseMap.containsKey(line)) {
          relsOut.println(reuseMap.get(line));
          getLog().info("Reuse rel: " + line);
          continue;
        }
        String tokens[] = FieldedStringTokenizer.split(line, "|", 3);
        if (tokens.length != 3) {
          getLog().error(line);
          throw new Exception("Unexpected rels file format, tokens ct = "
              + tokens.length);
        }

        // INPUT FIELDS: pt|rel|pt
        // OUTPUT FIELDS: uuid|pt|rel|pt

        String pt1 = tokens[0];
        String rel = tokens[1];
        String pt2 = tokens[2];

        String uuid = UUID.randomUUID().toString();

        String outline = uuid + "|" + pt1 + "|" + rel + "|" + pt2;
        relsOut.println(outline);
        getLog().info(outline);

      }
      relsIn.close();
      relsOut.close();

      //
      // Create special relationships
      //

      // Create relationships
      String specialRelsFile = "TechPrevSpecialRels.txt";

      // Only if they do not already exist
      if (!new File(outputDir, specialRelsFile).exists()) {
        // Write out data files
        PrintWriter specialRelsOut =
            new PrintWriter(
                new FileWriter(new File(outputDir, specialRelsFile)));

        String uuid = UUID.randomUUID().toString();
        String outline = "Molecular entity|" + uuid;
        specialRelsOut.println(outline);
        getLog().info(outline);

        uuid = UUID.randomUUID().toString();
        outline = "Realizable entity|" + uuid;
        specialRelsOut.println(outline);
        getLog().info(outline);

        specialRelsOut.close();
      } else {
        getLog().info(
            "TechPrevSpecialRels.txt already exists, not regenerating.");
      }

      getLog().info("Done");
    } catch (Exception e) {
      e.printStackTrace();
      throw new MojoFailureException("Unexpected failure.", e);
    }

  }

  /**
   * Populate reuse map.
   *
   * @throws Exception the exception
   */
  @SuppressWarnings("resource")
  private void populateReuseMap() throws Exception {

    // Create concepts map
    String conceptFile = "TechPrevConcepts.txt";
    BufferedReader conceptIn =
        new BufferedReader(new FileReader(new File(outputDir, conceptFile)));
    String line;
    // Iterate through file (no headers)
    while ((line = conceptIn.readLine()) != null) {
      String tokens[] = FieldedStringTokenizer.split(line, "|", 17);
      if (tokens.length != 17) {
        getLog().error(line);
        continue;
      }

      // key: fn|pt||case|chebi|def
      // value:
      // uuid|fn|fnuuid|fnusuuid|fngbuuid|pt|ptuuid|ptusuuid|ptgbuuid||case|chebi|def|defuuid|defusuuid|defgbuuid
      //

      // 791c1984-6d8b-44e0-80ea-d15e8f13e2ad|
      // Molecular entity (molecular entity)|
      // fd5f14dc-4f1b-427b-b695-5dfeff4771b9|df45be74-90a4-47d9-a4f2-a6aedbc19550|8c4edf92-5518-4edf-99fa-54a9012aa066|
      // Molecular entity|
      // 8cadefa8-a45e-4dbb-a0b3-3cff52644b8f|362d97a2-a91f-478e-a13b-314e7e1da8ff|81f39200-86b6-41a0-af53-983ff1ec49ad||
      // 0|
      // CHEBI:23367|efc48577-52b8-45d8-a9e2-39a5e24e5729|
      // Any constitutionally or isotopically distinct atom, molecule, ion, ion
      // pair, radical, radical ion, complex, conformer etc., identifiable as a
      // separately distinguishable
      // entity.|cde18279-2914-49f7-969e-b5b14d811898|2fa06ec7-70aa-4151-ad5f-3bdc1ae23f33|ea2bda6e-38ce-4660-81f8-fbd5bcd3dc30

      String fn = tokens[1];
      String pt = tokens[5];
      String caseSensitiveIndex = tokens[10];
      String chebiId = tokens[11];
      String definition = tokens[13];

      String key =
          fn + "|" + pt + "||" + caseSensitiveIndex + "|" + chebiId + "|"
              + definition;
      putReuseMap(key, line);

    }
    conceptIn.close();

    // Create rel types map
    String relTypesFile = "TechPrevRelTypes.txt";
    BufferedReader relTypesIn =
        new BufferedReader(new FileReader(new File(outputDir, relTypesFile)));
    // Iterate through file (no headers)
    while ((line = relTypesIn.readLine()) != null) {
      String tokens[] = FieldedStringTokenizer.split(line, "|", 15);
      if (tokens.length != 15) {
        getLog().error(line);
        throw new Exception("Unexpected relTypes file format, tokens ct = "
            + tokens.length);
      }

      // key: id|fn|pt|def
      // value:
      // id|uuid|fn|fnuuid|fnusuuid|fngbuuid|pt|ptuuid|ptusuuid|ptgbuuid|def|defuuid|defusuuid|defgbuuid|isauuid

      String id = tokens[0];
      String fn = tokens[2];
      String pt = tokens[6];
      String def = tokens[10];

      String key = id + "|" + fn + "|" + "|" + pt + "|" + def;
      putReuseMap(key, line);

      // String outline =
      // id + "|" + uuid + "|" + fn + "|" + fnuuid + "|" + fnusuuid + "|"
      // + fngbuuid + "|" + pt + "|" + ptuuid + "|" + ptusuuid + "|"
      // + ptgbuuid + "|" + def + "|" + defuuid + "|" + defusuuid + "|"
      // + defgbuuid + "|" + isauuid;

    }
    relTypesIn.close();

    // Create relationships map
    String relsFile = "TechPrevRels.txt";
    BufferedReader relsIn =
        new BufferedReader(new FileReader(new File(outputDir, relsFile)));
    // Iterate through file (no headers)
    while ((line = relsIn.readLine()) != null) {
      String tokens[] = FieldedStringTokenizer.split(line, "|", 4);
      if (tokens.length != 4) {
        getLog().error(line);
        throw new Exception("Unexpected rels file format, tokens ct = "
            + tokens.length);
      }

      // INPUT FIELDS: pt|rel|pt
      // OUTPUT FIELDS: uuid|pt|rel|pt

      String pt1 = tokens[1];
      String rel = tokens[2];
      String pt2 = tokens[3];

      String key = pt1 + "|" + rel + "|" + pt2;
      putReuseMap(key, line);

    }
    relsIn.close();

  }

  /**
   * Put reuse map.
   *
   * @param key the key
   * @param value the value
   * @throws Exception the exception
   */
  private void putReuseMap(String key, String value) throws Exception {
    getLog().info("key = " + key);
    getLog().info("value = " + value);
    if (reuseMap.containsKey(key)) {
      throw new Exception("DUPLICATE DETECTED: " + key);
    }
    reuseMap.put(key, value);
  }

}
