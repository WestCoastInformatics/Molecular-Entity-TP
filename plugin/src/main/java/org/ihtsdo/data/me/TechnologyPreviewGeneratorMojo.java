package org.ihtsdo.data.me;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;
import org.ihtsdo.idgeneration.IdAssignmentBI;
import org.ihtsdo.idgeneration.IdAssignmentImpl;

/**
 * Goal which generates technology preview data
 * 
 * See pom.xml for sample usage
 * 
 * @goal tech-preview
 * @phase package
 */
public class TechnologyPreviewGeneratorMojo extends AbstractMojo {

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
   * The effective time.
   * @parameter
   * @required
   */
  private String effectiveTime;

  /**
   * The id generator url.
   * @parameter
   * @required
   */
  private String idGeneratorUrl;

  /** The config. */
  private Properties config;

  /** The namespace id. */
  private int namespaceId;

  /**
   * The module id.
   * @parameter
   * @required
   */
  private String moduleId;

  /*
   * (non-Javadoc)
   * 
   * @see org.apache.maven.plugin.Mojo#execute()
   */
  @SuppressWarnings("resource")
  @Override
  public void execute() throws MojoFailureException {
    try {
      getLog().info("Generating ME Technology Preview");
      getLog().info("  inputDir = " + inputDir);
      getLog().info("  outputDir = " + outputDir);
      getLog().info("  effectiveTime = " + effectiveTime);
      getLog().info("  idGeneratorUrl = " + idGeneratorUrl);

      config = new Properties();
      config.load(new FileInputStream(new File(inputDir, "config.properties")));
      getLog().info(config.toString());

      namespaceId = Integer.parseInt(config.getProperty("NAMESPACE_ID"));

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

      // Tracking variables
      Map<UUID, String> conceptLines = new HashMap<>();
      Map<UUID, String> descLines = new HashMap<>();
      Map<UUID, String> defLines = new HashMap<>();
      Map<UUID, String> chebiMap = new HashMap<>();
      Map<UUID, UUID> compConceptMap = new HashMap<>();
      Map<UUID, UUID> langUsDescMap = new HashMap<>();
      Map<UUID, UUID> langGbDescMap = new HashMap<>();
      Map<UUID, UUID> langUsDefMap = new HashMap<>();
      Map<UUID, UUID> langGbDefMap = new HashMap<>();
      Map<String, UUID> ptConceptMap = new HashMap<>();

      //
      // Load concepts file
      //
      String conceptFile = "TechPrevConcepts.txt";
      getLog().info("    Load " + conceptFile);
      BufferedReader conceptIn =
          new BufferedReader(new FileReader(new File(inputDir, conceptFile)));
      String line;
      // Iterate through file (no headers)
      while ((line = conceptIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "|", 17);
        if (tokens.length != 17) {
          getLog().error(line);
          throw new Exception("Unexpected concept file format, tokens ct = "
              + tokens.length);
        }

        // FIELDS: uuid|fn|fnuuid|pt|ptuuid||case|chebi|chebiuuid|def|defuuid
        String uuid = tokens[0];
        String fn = tokens[1];
        String fnuuid = tokens[2];
        String fnusuuid = tokens[3];
        String fngbuuid = tokens[4];
        String pt = tokens[5];
        String ptuuid = tokens[6];
        String ptusuuid = tokens[7];
        String ptgbuuid = tokens[8];
        String blank = tokens[9];
        int caseSignificanceIndex = Integer.parseInt(tokens[10]);
        String chebiId = tokens[11];
        String chebiuuid = tokens[12];
        String definition =
            (tokens[13] == null ? "" : tokens[13].replaceAll("\r", ""));
        String defuuid = tokens[14];
        String defusuuid = tokens[15];
        String defgbuuid = tokens[16];

        getLog().info("uuid = " + uuid);
        getLog().info("  fn = " + fn);
        getLog().info("    fnuuid = " + fnuuid);
        getLog().info("    fnusuuid = " + fnusuuid);
        getLog().info("    fngbuuid = " + fngbuuid);
        getLog().info("  pt = " + pt);
        getLog().info("    ptuuid = " + ptuuid);
        getLog().info("    ptusuuid = " + ptusuuid);
        getLog().info("    ptgbuuid = " + ptgbuuid);
        getLog().info("  blank = " + blank);
        getLog().info("  caseSignificanceIndex = " + caseSignificanceIndex);
        getLog().info("  chebiId = " + chebiId);
        getLog().info("    chebiuuid = " + chebiuuid);
        getLog().info("  definition = " + definition);
        getLog().info("    defuuid = " + defuuid);
        getLog().info("    defusuuid = " + defusuuid);
        getLog().info("    defgbuuid = " + defgbuuid);

        if (!blank.equals("")) {
          // blank is possibly a synonym field.
          getLog().warn("  BLANK field is unexpectedly not blank: " + blank);
        }

        // Link components to concepts
        compConceptMap.put(UUID.fromString(fnuuid), UUID.fromString(uuid));
        compConceptMap.put(UUID.fromString(ptuuid), UUID.fromString(uuid));
        ptConceptMap.put(pt, UUID.fromString(uuid));
        compConceptMap.put(UUID.fromString(defuuid), UUID.fromString(uuid));
        compConceptMap.put(UUID.fromString(chebiuuid), UUID.fromString(uuid));
        chebiMap.put(UUID.fromString(chebiuuid), chebiId);

        // Link languages to descriptions
        langUsDescMap.put(UUID.fromString(fnusuuid), UUID.fromString(fnuuid));
        langGbDescMap.put(UUID.fromString(fngbuuid), UUID.fromString(fnuuid));
        langUsDescMap.put(UUID.fromString(ptusuuid), UUID.fromString(ptuuid));
        langGbDescMap.put(UUID.fromString(ptgbuuid), UUID.fromString(ptuuid));
        langUsDefMap.put(UUID.fromString(defusuuid), UUID.fromString(defuuid));
        langGbDefMap.put(UUID.fromString(defgbuuid), UUID.fromString(defuuid));

        // Assemble concept lines (in advance of assigning an SCTID)
        String cline =
            effectiveTime + "\t1\t" + moduleId + "\t"
                + config.getProperty("DEFINITION_STATUS_ID") + "\r\n";
        conceptLines.put(UUID.fromString(uuid), cline);

        // Assemble PT/FN lines (in advance of assigning an SCTID)
        String fsnline =
            "en\t"
                + config.getProperty("FN_TYPE_ID")
                + "\t"
                + fn
                + "\t"
                + config.getProperty("CASE_SIGNIFICANCE_"
                    + caseSignificanceIndex) + "\r\n";
        descLines.put(UUID.fromString(fnuuid), fsnline);
        String ptline =
            "en\t"
                + config.getProperty("PT_TYPE_ID")
                + "\t"
                + fn
                + "\t"
                + config.getProperty("CASE_SIGNIFICANCE_"
                    + caseSignificanceIndex) + "\r\n";
        descLines.put(UUID.fromString(ptuuid), ptline);

        // Assemble definition line (in advance of assigning an SCTID)
        if (!definition.equals("") && !definition.equals("null")) {
          // Always use fixed case Significance value
          String defline =
              "en\t" + config.getProperty("DEF_TYPE_ID") + "\t" + definition
                  + "\t" + config.getProperty("CASE_SIGNIFICANCE_0") + "\r\n";
          defLines.put(UUID.fromString(defuuid), defline);

        }
      }
      conceptIn.close();

      //
      // Load relationship types file
      //
      String relTypesFile = "TechPrevRelTypes.txt";
      getLog().info("    Load " + relTypesFile);
      BufferedReader relTypesIn =
          new BufferedReader(new FileReader(new File(inputDir, relTypesFile)));
      Map<String, UUID> relTypeIdConceptMap = new HashMap<>();
      Map<UUID, UUID> relTypeIsaConceptMap = new HashMap<>();
      // Iterate through file (no headers)
      while ((line = relTypesIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "|", 15);
        if (tokens.length != 15) {
          getLog().error(line);
          throw new Exception("Unexpected rel types file format, tokens ct = "
              + tokens.length);
        }

        if (tokens[0].equals("isa")) {
          continue;
        }

        // FIELDS:
        // id|uuid|fn|fnuuid|fnusuuid|fngbuuid|pt|ptuuid|ptusuuid|ptgbuuid|def|defuuid|defusuuid|defgbuuid|isauuid

        String id = tokens[0];
        String uuid = tokens[1];
        String fn = tokens[2];
        String fnuuid = tokens[3];
        String fnusuuid = tokens[4];
        String fngbuuid = tokens[5];
        String pt = tokens[6];
        String ptuuid = tokens[7];
        String ptusuuid = tokens[8];
        String ptgbuuid = tokens[9];
        String definition =
            (tokens[10] == null ? "" : tokens[10].replaceAll("\r", ""));
        String defuuid = tokens[11];
        String defusuuid = tokens[12];
        String defgbuuid = tokens[13];
        String isauuid = tokens[13];

        getLog().info("id = " + uuid);
        getLog().info("  uuid = " + uuid);
        getLog().info("  fn = " + fn);
        getLog().info("    fnuuid = " + fnuuid);
        getLog().info("    fnusuuid = " + fnusuuid);
        getLog().info("    fngbuuid = " + fngbuuid);
        getLog().info("  pt = " + pt);
        getLog().info("    ptuuid = " + ptuuid);
        getLog().info("    ptusuuid = " + ptusuuid);
        getLog().info("    ptgbuuid = " + ptgbuuid);
        getLog().info("  definition = " + definition);
        getLog().info("    defuuid = " + defuuid);
        getLog().info("    defusuuid = " + defusuuid);
        getLog().info("    defgbuuid = " + defgbuuid);
        getLog().info("    isauuid = " + isauuid);

        // gather relationship UUIDs
        relTypeIsaConceptMap.put(UUID.fromString(isauuid),
            UUID.fromString(uuid));

        // Link components to concepts
        relTypeIdConceptMap.put(id, UUID.fromString(uuid));
        compConceptMap.put(UUID.fromString(fnuuid), UUID.fromString(uuid));
        compConceptMap.put(UUID.fromString(ptuuid), UUID.fromString(uuid));
        compConceptMap.put(UUID.fromString(defuuid), UUID.fromString(uuid));
        ptConceptMap.put(pt, UUID.fromString(uuid));
        ptConceptMap.put(id, UUID.fromString(uuid));

        // Link languages to descriptions
        langUsDescMap.put(UUID.fromString(fnusuuid), UUID.fromString(fnuuid));
        langGbDescMap.put(UUID.fromString(fngbuuid), UUID.fromString(fnuuid));
        langUsDescMap.put(UUID.fromString(ptusuuid), UUID.fromString(ptuuid));
        langGbDescMap.put(UUID.fromString(ptgbuuid), UUID.fromString(ptuuid));
        langUsDefMap.put(UUID.fromString(defusuuid), UUID.fromString(defuuid));
        langGbDefMap.put(UUID.fromString(defgbuuid), UUID.fromString(defuuid));

        // Assemble concept lines (in advance of assigning an SCTID)
        String cline =
            effectiveTime + "\t1\t" + moduleId + "\t"
                + config.getProperty("DEFINITION_STATUS_ID") + "\r\n";
        conceptLines.put(UUID.fromString(uuid), cline);

        // Assemble PT/FN lines (in advance of assigning an SCTID)
        String fsnline =
            "en\t" + config.getProperty("FN_TYPE_ID") + "\t" + fn + "\t"
                + config.getProperty("CASE_SIGNIFICANCE_0") + "\r\n";
        descLines.put(UUID.fromString(fnuuid), fsnline);
        String ptline =
            "en\t" + config.getProperty("PT_TYPE_ID") + "\t" + pt + "\t"
                + config.getProperty("CASE_SIGNIFICANCE_0") + "\r\n";
        descLines.put(UUID.fromString(ptuuid), ptline);

        // Assemble definition line (in advance of assigning an SCTID)
        if (!definition.equals("") && !definition.equals("null")) {
          // Always use fixed case Significance value
          String defline =
              "en\t" + config.getProperty("DEF_TYPE_ID") + "\t" + definition
                  + "\t" + config.getProperty("CASE_SIGNIFICANCE_0") + "\r\n";
          defLines.put(UUID.fromString(defuuid), defline);

        }
      }
      relTypesIn.close();

      //
      // Load relationships file
      //
      String relsFile = "TechPrevRels.txt";
      getLog().info("    Load " + relsFile);
      BufferedReader relsIn =
          new BufferedReader(new FileReader(new File(inputDir, relsFile)));
      Map<UUID, UUID> relsSourceConceptIdMap = new HashMap<>();
      Map<UUID, UUID> relsTypeIdMap = new HashMap<>();
      Map<UUID, UUID> relsDestinationConceptIdMap = new HashMap<>();
      // Iterate through file (no headers)
      while ((line = relsIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "|", 4);
        if (tokens.length != 4) {
          getLog().error(line);
          throw new Exception("Unexpected rels file format, tokens ct = "
              + tokens.length);
        }

        // FIELDS:
        // id|uuid|fn|fnuuid|fnusuuid|fngbuuid|pt|ptuuid|ptusuuid|ptgbuuid|def|defuuid|defusuuid|defgbuuid

        String uuid = tokens[0];
        String pt1 = tokens[1];
        String rel = tokens[2];
        String pt2 = tokens[3];

        getLog().info("uuid = " + uuid + "," + pt1 + "|" + rel + "|" + pt2);

        // Link relationships
        UUID pt1Concept = ptConceptMap.get(pt1);
        if (pt1Concept == null) {
          // throw new Exception("PT concept cannot be found: " + pt1);
          getLog().error("PT concept cannot be found: " + pt1);
        }

        UUID relConcept = ptConceptMap.get(rel);
        if (relConcept == null && !rel.equals("isa")) {
          // throw new Exception("rel concept cannot be found: " + rel);
          getLog().error("rel concept cannot be found: " + rel);
        }

        UUID pt2Concept = ptConceptMap.get(pt2);
        if (pt2Concept == null) {
          // throw new Exception("PT concept cannot be found: " + pt2);
          getLog().error("PT concept cannot be found: " + pt2);
        }
        if (ptConceptMap.containsKey(pt1) && ptConceptMap.containsKey(pt2)
            && ptConceptMap.containsKey(rel)) {
          relsSourceConceptIdMap.put(UUID.fromString(uuid), pt1Concept);
          relsTypeIdMap.put(UUID.fromString(uuid), relConcept);
          relsDestinationConceptIdMap.put(UUID.fromString(uuid), pt2Concept);
        }
      }
      relsIn.close();

      //
      // Load "special" relationships file
      //
      String specialRelsFile = "TechPrevSpecialRels.txt";
      getLog().info("    Load " + specialRelsFile);
      BufferedReader specialRelsIn =
          new BufferedReader(
              new FileReader(new File(inputDir, specialRelsFile)));
      Map<String, UUID> specialRelsMap = new HashMap<>();
      // Iterate through file (no headers)
      while ((line = specialRelsIn.readLine()) != null) {
        String tokens[] = FieldedStringTokenizer.split(line, "|", 2);
        if (tokens.length != 2) {
          getLog().error(line);
          throw new Exception(
              "Unexpected special rels file format, tokens ct = "
                  + tokens.length);
        }

        // FIELDS:
        // pt|isauuid

        String pt = tokens[0];
        String isauuid = tokens[1];

        getLog().info("pt = " + pt);
        getLog().info("  isauuid = " + isauuid);

        specialRelsMap.put(pt, UUID.fromString(isauuid));
      }
      specialRelsIn.close();

      //
      // Open data files and write headers
      //
      getLog().info("    Open data files and write headers");
      PrintWriter conceptOut =
          new PrintWriter(new FileWriter(new File(terminologyDir,
              "xsct2_Concept_" + config.getProperty("RF2_FILE_TYPE") + "_INT_"
                  + effectiveTime + ".txt")));
      conceptOut
          .print("id\teffectiveTime\tactive\tmoduleId\tdefinitionStatusId\r\n");
      PrintWriter descOut =
          new PrintWriter(new FileWriter(new File(terminologyDir,
              "xsct2_Description_" + config.getProperty("RF2_FILE_TYPE")
                  + "_INT_" + effectiveTime + ".txt")));
      descOut
          .print("id\teffectiveTime\tactive\tmoduleId\tconceptId\tlanguageCode\ttypeId\tterm\tcaseSignificanceId\r\n");
      PrintWriter defOut =
          new PrintWriter(new FileWriter(new File(terminologyDir,
              "xsct2_TextDefinition_" + config.getProperty("RF2_FILE_TYPE")
                  + "_INT_" + effectiveTime + ".txt")));
      defOut
          .print("id\teffectiveTime\tactive\tmoduleId\tconceptId\tlanguageCode\ttypeId\tterm\tcaseSignificanceId\r\n");
      PrintWriter languageOut =
          new PrintWriter(new FileWriter(new File(languageDir,
              "xder2_cRefset_Language" + config.getProperty("RF2_FILE_TYPE")
                  + "-en_INT_" + effectiveTime + ".txt")));
      languageOut
          .print("id\teffectiveTime\tactive\tmoduleId\trefsetId\treferencedComponentId\tacceptabilityId\r\n");

      PrintWriter statedRelsOut =
          new PrintWriter(new FileWriter(new File(terminologyDir,
              "xsct2_StatedRelationship_" + config.getProperty("RF2_FILE_TYPE")
                  + "_INT_" + effectiveTime + ".txt")));
      statedRelsOut
          .print("id\teffectiveTime\tactive\tmoduleId\tsourceId\tdestinationId\trelationshipGroup\ttypeId\tcharacteristicTypeId\tmodifierId\r\n");

      //
      // Write concepts
      //
      getLog().info("    Write concepts");
      Map<UUID, Long> conceptIds =
          getIdList(new ArrayList<UUID>(conceptLines.keySet()), namespaceId,
              "00", effectiveTime, effectiveTime, moduleId);
      for (UUID uuid : conceptIds.keySet()) {
        conceptOut.print(conceptIds.get(uuid) + "\t" + conceptLines.get(uuid));
      }

      //
      // Write descriptions and definitions
      //
      getLog().info("    Write descriptions");
      Map<UUID, Long> descIds =
          getIdList(new ArrayList<UUID>(descLines.keySet()), namespaceId, "01",
              effectiveTime, effectiveTime, moduleId);
      for (UUID uuid : descIds.keySet()) {
        descOut.print(descIds.get(uuid) + "\t" + effectiveTime + "\t1\t"
            + moduleId + "\t" + conceptIds.get(compConceptMap.get(uuid)) + "\t"
            + descLines.get(uuid));
      }
      Map<UUID, Long> defIds =
          getIdList(new ArrayList<UUID>(defLines.keySet()), namespaceId, "01",
              effectiveTime, effectiveTime, moduleId);
      for (UUID uuid : defIds.keySet()) {
        defOut.print(defIds.get(uuid) + "\t" + effectiveTime + "\t1\t"
            + moduleId + "\t" + conceptIds.get(compConceptMap.get(uuid)) + "\t"
            + defLines.get(uuid));
      }

      //
      // Write language refset members
      //
      getLog().info("    Write language refset entries");
      for (UUID uuid : langUsDescMap.keySet()) {
        languageOut.print(uuid + "\t" + effectiveTime + "\t1\t" + moduleId
            + "\t" + config.getProperty("US_LANGUAGE_REFSET_ID") + "\t"
            + descIds.get(langUsDescMap.get(uuid)) + "\t"
            + config.getProperty("PREFERRED_ACCEPTABILITY_ID") + "\r\n");
      }
      for (UUID uuid : langGbDescMap.keySet()) {
        languageOut.print(uuid + "\t" + effectiveTime + "\t1\t" + moduleId
            + "\t" + config.getProperty("GB_LANGUAGE_REFSET_ID") + "\t"
            + descIds.get(langGbDescMap.get(uuid)) + "\t"
            + config.getProperty("PREFERRED_ACCEPTABILITY_ID") + "\r\n");
      }
      for (UUID uuid : langUsDefMap.keySet()) {
        if (defIds.containsKey(langUsDefMap.get(uuid))) {
          languageOut.print(uuid + "\t" + effectiveTime + "\t1\t" + moduleId
              + "\t" + config.getProperty("US_LANGUAGE_REFSET_ID") + "\t"
              + defIds.get(langUsDefMap.get(uuid)) + "\t"
              + config.getProperty("PREFERRED_ACCEPTABILITY_ID") + "\r\n");
        }
      }
      for (UUID uuid : langGbDefMap.keySet()) {
        if (defIds.containsKey(langGbDefMap.get(uuid))) {
          languageOut.print(uuid + "\t" + effectiveTime + "\t1\t" + moduleId
              + "\t" + config.getProperty("GB_LANGUAGE_REFSET_ID") + "\t"
              + defIds.get(langGbDefMap.get(uuid)) + "\t"
              + config.getProperty("PREFERRED_ACCEPTABILITY_ID") + "\r\n");
        }
      }

      //
      // Write relationships
      //
      getLog().info("    Write relationships");
      Map<UUID, Long> relIds =
          getIdList(new ArrayList<UUID>(relsSourceConceptIdMap.keySet()),
              namespaceId, "02", effectiveTime, effectiveTime, moduleId);
      for (UUID uuid : relsSourceConceptIdMap.keySet()) {
        Long sourceId = conceptIds.get(relsSourceConceptIdMap.get(uuid));
        Long destinationId =
            conceptIds.get(relsDestinationConceptIdMap.get(uuid));
        UUID typeUuid = relsTypeIdMap.get(uuid);
        Long typeId = Long.parseLong(config.getProperty("ISA_TYPE_ID"));
        if (typeUuid != null) {
          typeId = conceptIds.get(typeUuid);
        }
        statedRelsOut.print(relIds.get(uuid) + "\t" + effectiveTime + "\t1\t"
            + moduleId + "\t" + sourceId + "\t" + destinationId + "\t0\t"
            + typeId + "\t" + config.getProperty("CHARACTERISTIC_TYPE_ID")
            + "\t" + config.getProperty("MODIFIER_ID") + "\r\n");
      }

      //
      // Write relType relationships and special relationships
      //
      getLog().info("    Write special relationships");
      Map<UUID, Long> rel2Ids =
          getIdList(new ArrayList<UUID>(relTypeIsaConceptMap.keySet()),
              namespaceId, "02", effectiveTime, effectiveTime, moduleId);
      for (UUID uuid : relTypeIsaConceptMap.keySet()) {
        Long relId = rel2Ids.get(uuid);
        Long sourceId = conceptIds.get(relTypeIsaConceptMap.get(uuid));
        statedRelsOut.print(relId + "\t" + effectiveTime + "\t1\t" + moduleId
            + "\t" + sourceId + "\t"
            + config.getProperty("CONCEPT_MODEL_ATTRIBUTE_ID") + "\t0\t"
            + config.getProperty("ISA_TYPE_ID") + "\t"
            + config.getProperty("CHARACTERISTIC_TYPE_ID") + "\t"
            + config.getProperty("MODIFIER_ID") + "\r\n");
      }
      // Molecular Entity -> isa -> ROOT
      // Realizable entity -> isa -> QualifierValue
      Map<UUID, Long> rel3Ids =
          getIdList(new ArrayList<UUID>(specialRelsMap.values()), namespaceId,
              "02", effectiveTime, effectiveTime, moduleId);
      statedRelsOut.print(rel3Ids.get(specialRelsMap.get("Molecular entity"))
          + "\t" + effectiveTime + "\t1\t" + moduleId + "\t"
          + conceptIds.get(ptConceptMap.get("Molecular entity")) + "\t"
          + config.getProperty("SNOMEDCT_ROOT_ID") + "\t0\t"
          + config.getProperty("ISA_TYPE_ID") + "\t"
          + config.getProperty("CHARACTERISTIC_TYPE_ID") + "\t"
          + config.getProperty("MODIFIER_ID") + "\r\n");
      statedRelsOut.print(rel3Ids.get(specialRelsMap.get("Realizable entity"))
          + "\t" + effectiveTime + "\t1\t" + moduleId + "\t"
          + conceptIds.get(ptConceptMap.get("Realizable entity")) + "\t"
          + config.getProperty("QUALIFIER_VALUE_ID") + "\t0\t"
          + config.getProperty("ISA_TYPE_ID") + "\t"
          + config.getProperty("CHARACTERISTIC_TYPE_ID") + "\t"
          + config.getProperty("MODIFIER_ID") + "\r\n");

      conceptOut.close();
      descOut.close();
      defOut.close();
      languageOut.close();
      statedRelsOut.close();

      //
      // Write CHEBI identifiers simple map
      //
      getLog().info("    Write CHEBI ids");
      PrintWriter simpleMapOut =
          new PrintWriter(new FileWriter(new File(mapDir,
              "xder2_cRefset_SimpleMap" + config.getProperty("RF2_FILE_TYPE")
                  + "_INT_" + effectiveTime + ".txt")));
      simpleMapOut
          .print("id\teffectiveTime\tactive\tmoduleId\trefsetId\treferencedComponentId\tmapTarget\r\n");
      for (UUID uuid : chebiMap.keySet()) {
        if (!chebiMap.get(uuid).equals("")) {
          simpleMapOut.print(uuid + "\t" + effectiveTime + "\t1\t" + moduleId
              + "\tNeedRefset\t" + conceptIds.get(compConceptMap.get(uuid))
              + "\t" + chebiMap.get(uuid) + "\r\n");
        }

      }
      simpleMapOut.close();

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
    IdAssignmentBI client = new IdAssignmentImpl(idGeneratorUrl);
    Map<UUID, Long> result =
        client.createSCTIDList(componentUuids,
            Integer.valueOf(config.getProperty("NAMESPACE_ID")), partitionId,
            releaseId, buildId, moduleId);
    // Map<UUID, Long> result = new HashMap<>();
    // for (UUID uuid : componentUuids) {
    // result.put(uuid, ct++);
    // }
    return result;

  }

}
