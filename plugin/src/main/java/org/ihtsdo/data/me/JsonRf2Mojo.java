package org.ihtsdo.data.me;

import java.util.Collection;

import org.apache.commons.configuration.XMLConfiguration;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.MojoFailureException;
import org.ihtsdo.json.TransformerConfig;
import org.ihtsdo.json.TransformerDiskBased;

/**
 * Goal which converts RF2 to JSON
 * 
 * See pom.xml for sample usage
 * 
 * @goal rf2-json
 * @phase package
 */
public class JsonRf2Mojo extends AbstractMojo {

  /**
   * The config file.
   * @parameter
   * @required
   */
  private String configFile;

  /**
   * The validation rules file
   * @parameter
   * @required
   */
  private String validationRulesFile;

  /*
   * (non-Javadoc)
   * 
   * @see org.apache.maven.plugin.Mojo#execute()
   */
  @SuppressWarnings("unchecked")
  @Override
  public void execute() throws MojoFailureException {
    try {
      getLog().info("Converting JSON to RF2");
      getLog().info("  configFile = " + configFile);
      getLog().info("  validationRulesFile = " + validationRulesFile);
      System.setProperty("validation.rules.file", validationRulesFile);

      XMLConfiguration xmlConfig = new XMLConfiguration(configFile);

      TransformerConfig runnableConfig = new TransformerConfig();

      runnableConfig.setDefaultTermLangCode(xmlConfig
          .getString("defaultTermLangCode"));
      runnableConfig.setDefaultTermDescriptionType(xmlConfig
          .getString("defaultTermDescriptionType"));
      runnableConfig.setDefaultTermLanguageRefset(xmlConfig
          .getString("defaultTermLanguageRefset"));
      runnableConfig.setNormalizeTextIndex(xmlConfig.getString(
          "normalizeTextIndex").equals("true"));
      runnableConfig.setCreateCompleteConceptsFile(xmlConfig.getString(
          "createCompleteConceptsFile").equals("true"));
      runnableConfig.setProcessInMemory(xmlConfig.getString("processInMemory")
          .equals("true"));
      runnableConfig.setEditionName(xmlConfig.getString("editionName"));
      runnableConfig.setDatabaseName(xmlConfig.getString("databaseName"));
      runnableConfig.setEffectiveTime(xmlConfig.getString("effectiveTime"));
      runnableConfig.setExpirationTime(xmlConfig.getString("expirationTime"));
      runnableConfig.setOutputFolder(xmlConfig.getString("outputFolder"));

      Object prop = xmlConfig.getProperty("foldersBaselineLoad.folder");
      if (prop instanceof Collection) {
        for (String loopProp : (Collection<String>) prop) {
          runnableConfig.getFoldersBaselineLoad().add(loopProp);
          System.out.println(loopProp);
        }
      } else if (prop instanceof String) {
        runnableConfig.getFoldersBaselineLoad().add((String) prop);
        System.out.println(prop);
      }

      prop = xmlConfig.getProperty("modulesToIgnoreBaselineLoad.folder");
      if (prop instanceof Collection) {
        for (String loopProp : (Collection<String>) prop) {
          runnableConfig.getModulesToIgnoreBaselineLoad().add(loopProp);
          System.out.println(loopProp);
        }
      } else if (prop instanceof String) {
        runnableConfig.getModulesToIgnoreBaselineLoad().add((String) prop);
        System.out.println(prop);
      }

      prop = xmlConfig.getProperty("foldersExtensionLoad.folder");
      if (prop instanceof Collection) {
        for (String loopProp : (Collection<String>) prop) {
          runnableConfig.getFoldersExtensionLoad().add(loopProp);
          System.out.println(loopProp);
        }
      } else if (prop instanceof String) {
        runnableConfig.getFoldersExtensionLoad().add((String) prop);
        System.out.println(prop);
      }

      prop = xmlConfig.getProperty("modulesToIgnoreExtensionLoad.folder");
      if (prop instanceof Collection) {
        for (String loopProp : (Collection<String>) prop) {
          runnableConfig.getModulesToIgnoreExtensionLoad().add(loopProp);
          System.out.println(loopProp);
        }
      } else if (prop instanceof String) {
        runnableConfig.getModulesToIgnoreExtensionLoad().add((String) prop);
        System.out.println(prop);
      }

      TransformerDiskBased tr = new TransformerDiskBased();

      tr.convert(runnableConfig);
      getLog().info("Done");
    } catch (Exception e) {
      e.printStackTrace();
      throw new MojoFailureException("Unexpected failure.", e);
    }

  }
}
