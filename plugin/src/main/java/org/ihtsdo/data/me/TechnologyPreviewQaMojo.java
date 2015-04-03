package org.ihtsdo.data.me;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;

/**
 * Goal which performs some QA on technology preview data
 * 
 * See pom.xml for sample usage
 * 
 * @goal qa-tech-preview
 * @phase package
 */
public class TechnologyPreviewQaMojo extends AbstractMojo {

  /** The ct. */
  private long ct = 1L;

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

  /**
   * The effectiveTime.
   * @parameter
   * @required
   */
  private String effectiveTime;

  /** The config. */
  private Properties config;

  /**
   * The Enum Stats.
   */
  private enum Stats {

    /** The concept ct. */
    CONCEPT_CT,
    /** The desc ct. */
    DESC_CT,
    /** The def ct. */
    DEF_CT,
    /** The lang ct. */
    LANG_CT,
    /** The CAS e_0. */
    CASE_0,
    /** The CAS e_1. */
    CASE_1,
    /** The rel ct. */
    REL_CT,
    /** The isa ct. */
    ISA_CT,
    /** The chebi ct. */
    CHEBI_CT

  }

  /*
   * (non-Javadoc)
   * 
   * @see org.apache.maven.plugin.Mojo#execute()
   */
  @SuppressWarnings("resource")
  @Override
  public void execute() throws MojoFailureException {
    try {
      getLog().info("QA ME Technology Preview");
      getLog().info("  inputDir = " + inputDir);
      getLog().info("  outputDir = " + outputDir);

      config = new Properties();
      config.load(new FileInputStream(new File(inputDir, "config.properties")));
      getLog().info(config.toString());

      // Setup resources
      getLog().info("");
      getLog().info("    Setup Resources");
      new File(outputDir).mkdirs();
      File terminologyDir = new File(outputDir, "Terminology");
      terminologyDir.mkdirs();
      File refsetDir = new File(outputDir, "Refset");
      refsetDir.mkdirs();
      File mapDir = new File(refsetDir, "Map");
      mapDir.mkdirs();
      File languageDir = new File(refsetDir, "Language");
      languageDir.mkdirs();

      Map<Stats, Integer> inStats = new HashMap<>();
      Map<Stats, Integer> outStats = new HashMap<>();
      for (Stats stat : Stats.values()) {
        inStats.put(stat, 0);
        outStats.put(stat, 0);
      }

      //
      // Load Input data
      //
      String conceptFile = "TechPrevConcepts.txt";
      getLog().info("    Load " + conceptFile);
      BufferedReader conceptIn =
          new BufferedReader(new FileReader(new File(inputDir, conceptFile)));
      String line;
      // Iterate through file (no headers)
      while ((line = conceptIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "|", 17);

        int caseSignificanceIndex = Integer.parseInt(tokens[10]);
        String chebiId = tokens[11];
        String definition =
            (tokens[13] == null ? "" : tokens[13].replaceAll("\r", ""));

        // Stats
        incrementStat(inStats, Stats.CONCEPT_CT);
        incrementStat(inStats, Stats.DESC_CT);
        incrementStat(inStats, Stats.DESC_CT);
        if (!definition.equals("") && !definition.equals("null")) {
          incrementStat(inStats, Stats.DEF_CT);
          incrementStat(inStats, Stats.CASE_0);
        }
        if (!chebiId.equals("") && !chebiId.equals("null")) {
          incrementStat(inStats, Stats.CHEBI_CT);
        }
        if (caseSignificanceIndex == 0) {
          incrementStat(inStats, Stats.CASE_0);
          incrementStat(inStats, Stats.CASE_0);
        }
        if (caseSignificanceIndex == 1) {
          incrementStat(inStats, Stats.CASE_1);
          incrementStat(inStats, Stats.CASE_1);
        }

      }
      conceptIn.close();

      String relTypesFile = "TechPrevRelTypes.txt";
      getLog().info("    Load " + relTypesFile);
      BufferedReader relTypesIn =
          new BufferedReader(new FileReader(new File(inputDir, relTypesFile)));
      // Iterate through file (no headers)
      while ((line = relTypesIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "|", 15);

        // alraedy exists
        if (tokens[0].equals("isa")) {
          continue;
        }

        String definition =
            (tokens[10] == null ? "" : tokens[10].replaceAll("\r", ""));

        // Stats
        incrementStat(inStats, Stats.CONCEPT_CT);
        incrementStat(inStats, Stats.DESC_CT);
        incrementStat(inStats, Stats.DESC_CT);
        if (!definition.equals("") && !definition.equals("null")) {
          incrementStat(inStats, Stats.DEF_CT);
          incrementStat(inStats, Stats.CASE_0);
        }
        incrementStat(inStats, Stats.CASE_0);
        incrementStat(inStats, Stats.CASE_0);
        incrementStat(inStats, Stats.REL_CT);
        incrementStat(inStats, Stats.ISA_CT);

      }
      relTypesIn.close();

      // 2 languages per description/definition
      inStats.put(Stats.LANG_CT,
          (inStats.get(Stats.DESC_CT) + inStats.get(Stats.DEF_CT)) * 2);

      String relsFile = "TechPrevRels.txt";
      getLog().info("    Load " + relsFile);
      BufferedReader relsIn =
          new BufferedReader(new FileReader(new File(inputDir, relsFile)));
      // Iterate through file (no headers)
      while ((line = relsIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "|", 4);
        String rel = tokens[2];

        incrementStat(inStats, Stats.REL_CT);
        if (rel.equals("isa")) {
          incrementStat(inStats, Stats.ISA_CT);
        }

      }
      relsIn.close();

      String specialRelsFile = "TechPrevSpecialRels.txt";
      getLog().info("    Load " + specialRelsFile);
      BufferedReader specialRelsIn =
          new BufferedReader(
              new FileReader(new File(inputDir, specialRelsFile)));
      // Iterate through file (no headers)
      while ((line = specialRelsIn.readLine()) != null) {
        // String tokens[] = FieldedStringTokenizer.split(line, "|", 2);
        incrementStat(inStats, Stats.REL_CT);
        incrementStat(inStats, Stats.ISA_CT);
      }
      specialRelsIn.close();

      //
      // Load RF2
      //
      boolean errorFlag = false;
      List<String> nullLines = new ArrayList<>();
      String rf2ConceptFile =
          "Terminology/xsct2_Concept_" + config.getProperty("RF2_FILE_TYPE")
              + "_INT_" + effectiveTime + ".txt";
      getLog().info("    Load " + rf2ConceptFile);
      BufferedReader rf2ConceptIn =
          new BufferedReader(
              new FileReader(new File(outputDir, rf2ConceptFile)));
      while ((line = rf2ConceptIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "\t");
        if (tokens[0].equals("id"))
          continue;
        incrementStat(outStats, Stats.CONCEPT_CT);
        if (line.contains("null")) {
          errorFlag = true;
          nullLines.add(line);
        }
      }
      rf2ConceptIn.close();

      // Print null lines
      for (String nullLine : nullLines) {
        getLog().info("NULL LINE: " + nullLine);
      }

      nullLines = new ArrayList<>();
      String rf2DescFile =
          "Terminology/xsct2_Description_"
              + config.getProperty("RF2_FILE_TYPE") + "_INT_" + effectiveTime
              + ".txt";
      getLog().info("    Load " + rf2DescFile);
      BufferedReader rf2DescIn =
          new BufferedReader(new FileReader(new File(outputDir, rf2DescFile)));
      while ((line = rf2DescIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "\t", 9);
        if (tokens[0].equals("id"))
          continue;
        String caseSignificanceId = tokens[8].replaceAll("\r", "");
        incrementStat(outStats, Stats.DESC_CT);
        if (caseSignificanceId
            .equals(config.getProperty("CASE_SIGNIFICANCE_0"))) {
          incrementStat(outStats, Stats.CASE_0);
        }
        if (caseSignificanceId
            .equals(config.getProperty("CASE_SIGNIFICANCE_1"))) {
          incrementStat(outStats, Stats.CASE_1);
        }
        if (line.contains("null")) {
          errorFlag = true;
          nullLines.add(line);
        }
      }
      rf2DescIn.close();

      // Print null lines
      for (String nullLine : nullLines) {
        getLog().info("NULL LINE: " + nullLine);
      }

      nullLines = new ArrayList<>();
      String rf2DefFile =
          "Terminology/xsct2_TextDefinition_"
              + config.getProperty("RF2_FILE_TYPE") + "_INT_" + effectiveTime
              + ".txt";
      getLog().info("    Load " + rf2DefFile);
      BufferedReader rf2DefIn =
          new BufferedReader(new FileReader(new File(outputDir, rf2DefFile)));
      while ((line = rf2DefIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "\t");
        if (tokens[0].equals("id"))
          continue;
        String caseSignificanceId = tokens[8].replaceAll("\r", "");
        incrementStat(outStats, Stats.DEF_CT);
        if (caseSignificanceId
            .equals(config.getProperty("CASE_SIGNIFICANCE_0"))) {
          incrementStat(outStats, Stats.CASE_0);
        }
        if (caseSignificanceId
            .equals(config.getProperty("CASE_SIGNIFICANCE_1"))) {
          incrementStat(outStats, Stats.CASE_1);
        }
        if (line.contains("null")) {
          errorFlag = true;
          nullLines.add(line);
        }
      }
      rf2DefIn.close();

      // Print null lines
      for (String nullLine : nullLines) {
        getLog().info("NULL LINE: " + nullLine);
      }

      nullLines = new ArrayList<>();
      String rf2RelFile =
          "Terminology/xsct2_StatedRelationship_"
              + config.getProperty("RF2_FILE_TYPE") + "_INT_" + effectiveTime
              + ".txt";
      getLog().info("    Load " + rf2RelFile);
      BufferedReader rf2RelIn =
          new BufferedReader(new FileReader(new File(outputDir, rf2RelFile)));
      while ((line = rf2RelIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "\t");
        if (tokens[0].equals("id"))
          continue;
        String typeId = tokens[7];
        incrementStat(outStats, Stats.REL_CT);
        if (typeId.equals(config.getProperty("ISA_TYPE_ID"))) {
          incrementStat(outStats, Stats.ISA_CT);
        }
        if (line.contains("null")) {
          errorFlag = true;
          nullLines.add(line);
        }
      }
      rf2DefIn.close();

      // Print null lines
      for (String nullLine : nullLines) {
        getLog().info("NULL LINE: " + nullLine);
      }
      nullLines = new ArrayList<>();
      String rf2MapFile =
          "Refset/Map/xder2_cRefset_SimpleMap"
              + config.getProperty("RF2_FILE_TYPE") + "_INT_" + effectiveTime
              + ".txt";
      getLog().info("    Load " + rf2MapFile);
      BufferedReader rf2MapIn =
          new BufferedReader(new FileReader(new File(outputDir, rf2MapFile)));
      while ((line = rf2MapIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "\t");
        if (tokens[0].equals("id"))
          continue;
        incrementStat(outStats, Stats.CHEBI_CT);
        if (line.contains("null")) {
          errorFlag = true;
          nullLines.add(line);
        }
      }
      rf2MapIn.close();
      // Print null lines
      for (String nullLine : nullLines) {
        getLog().info("NULL LINE: " + nullLine);
      }

      nullLines = new ArrayList<>();
      String rf2LangFile =
          "Refset/Language/xder2_cRefset_Language"
              + config.getProperty("RF2_FILE_TYPE") + "-en_INT_"
              + effectiveTime + ".txt";
      getLog().info("    Load " + rf2LangFile);
      BufferedReader rf2LangIn =
          new BufferedReader(new FileReader(new File(outputDir, rf2LangFile)));
      while ((line = rf2LangIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "\t");
        if (tokens[0].equals("id"))
          continue;
        incrementStat(outStats, Stats.LANG_CT);
        if (line.contains("null")) {
          errorFlag = true;
          nullLines.add(line);
        }
      }
      rf2LangIn.close();
      // Print null lines
      for (String nullLine : nullLines) {
        getLog().info("NULL LINE: " + nullLine);
      }

      // Print the report
      getLog().info("STATISTICS REPORT");
      // Different counts, same keys
      List<String> matching = new ArrayList<>();
      List<String> notMatching = new ArrayList<>();
      for (Stats stat : inStats.keySet()) {
        int in = inStats.get(stat);
        int out = outStats.get(stat);
        if (in == out) {
          matching.add(stat + " - " + in);
        } else {
          notMatching.add(stat + " - " + in + ", " + out);
        }

      }

      getLog().info("  MATCHING");
      for (String s : matching) {
        getLog().info("    " + s);
      }

      getLog().info("");
      getLog().info("  NOT MATCHING");
      for (String s : notMatching) {
        getLog().info("    " + s);
        errorFlag = true;
      }

      if (errorFlag) {
        throw new Exception("ERRORS, please review log");
      }
      getLog().info("Done");
    } catch (Exception e) {
      e.printStackTrace();
      throw new MojoFailureException("Unexpected failure.", e);
    }

  }

  /**
   * Returns the SNOMED ids for the UUIDs.
   * 
   * @param componentUuids the component uuids
   * @param namespaceId the namespace id
   * @param partitionId the partition id
   * @param releaseId the release id
   * @param buildId the build id
   * @param moduleId the module id
   * @return the id
   * @throws Exception the exception
   */
  public Map<UUID, Long> getIdList(List<UUID> componentUuids,
    Integer namespaceId, String partitionId, String releaseId, String buildId,
    String moduleId) throws Exception {
    // IdAssignmentBI client = new IdAssignmentImpl(idGeneratorUrl);
    // Map<UUID, Long> result =
    // client.createSCTIDList(componentUuids, namespaceId, partitionId,
    // releaseId, buildId, moduleId);
    Map<UUID, Long> map = new HashMap<>();
    for (UUID uuid : componentUuids) {
      map.put(uuid, ct++);
    }
    return map;

  }

  /**
   * Increment stat.
   *
   * @param map the map
   * @param stat the stat
   */
  private static void incrementStat(Map<Stats, Integer> map, Stats stat) {
    map.put(stat, map.get(stat) + 1);
  }
}
