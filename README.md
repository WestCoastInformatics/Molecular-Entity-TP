This is a seven-step process.

STEP 0: download and install the RF2 snorocket and json conversion utilities
        and build these projects (so we can refer to the
        dependencies).
* https://github.com/IHTSDO/rf2-classification-snorocket.git
* https://github.com/IHTSDO/rf2-to-json-conversion.git

STEP 1: initialize - run to assign UUIDs to the files in src/main/resources

mvn -Pinit clean install

Commit the changes.

STEP 2: normal run with UUIDs assigned

mvn -Prf2 clean install

STEP 3: run QA (note, do not use "clean" as it expects data files in "target/" folder).

mvn -Pqa install

STEP 4: generate browser-ready data (need to configure path to full release data)
 * combine with previous release
 * re-run classification
 * combine classification output
 * convert to json
 * package for deployment

mvn -Pbrowser install

STEP 5: load mongodb
 * copy install.sh to the "browser/target/json" directory
 * Put "mongo" into path (e.g. C:\Program Files\MongoDB 2.6 Standard\bin)
 * Run in Cygwin "./install.sh MolecularEntityTechPreview-edition 20150401"
   * MAKE sure each step of the install.sh script runs. Run manually if necessary.
 
STEP 6: run the rest API in Node.js (from the "Node.js command prompt")
  * node app.js (from the sct-snapshot-rest-api folder)
    * Check http://127.0.0.1:3000/server/releases
    
STEP 7: Open the sct-browser-frontend/index.html page
