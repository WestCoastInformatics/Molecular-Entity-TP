* Verify concept ids are unique
* Verify concept id,effectiveTime tuples are unique
* Verify tech preview concepts have an core partition ID (00)
* Verify concept identifiers are longer than 5 digits and shorter than 19
* Verify concepts have a valid check digit.
* Verify concepts have valid effectiveTime (YYYYMMDD).
* Verify concepts have valid active (0,1).
* Verify concepts have an approved moduleId
* Verify concepts have the correct number of fields (5).
* Verify concepts have a valid definitionStatusId
* Verify tech preview concepts have an active FN (typeId='$fsnConcept') and an active SY (typeId='$syConcept').
* Verify active tech preview concepts have at least one active isa relationship
* Verify tech preview Description ids are unique.
* Verify description id,effectiveTime tuples are unique
* Verify descriptions are unique
* Verify tech preview descriptions have an core partition ID (01).
* Verify description identifiers are longer than 5 digits and shorter than 19
* Verify descriptions have a valid check digit.
* Verify descriptions have valid effectiveTime (YYYYMMDD).
* Verify descriptions have valid active (0,1).
* Verify descriptions have an approved moduleId
* Verify descriptions have the correct number of fields (9).
* Verify descriptions have LanguageCode assigned = "en"
* Verify descriptions have valid typeId
* Verify descriptions have valid caseSignificanceId
* Verify tech preview descriptions are associated with valid tech preview or core concepts
* Verify active tech preview FN descriptions do not match active core FNs.
* Verify active tech preview FN descriptions are unique.
* Verify Active FN descriptions have a valid semantic tag.
* Verify all descriptions have no '?' characters in the term field
* Verify tech preview descriptions do not have double-quote characters in the term.
* Verify tech preview descriptions do not contain invalid punctuation characters
* Verify tech preview Relationship ids are unique.
* Verify relationship id,effectiveTime tuples are unique
* Verify relationships are unique
* Verify tech preview Relationship ids have an core partition ID (02).
* Verify relationship identifiers are longer than 5 digits and shorter than 19
* Verify Relationship ids have a valid check digit.
* Verify relationships have valid effectiveTime (YYYYMMDD).
* Verify relationships have valid active (0,1).
* Verify relationship have an approved moduleId
* Verify relationships have the correct number of fields (10).
* Verify relationships have valid characteristicTypeId
* Verify relationships have valid modifierId
* Verify RelationshipGroup is non-null.
* Verify tech preview relationship sourceIds are valid tech preview or core concepts
* Verify tech preview relationship destinationIds are valid tech preview or core concepts
* Verify active tech preview concepts have an active stated IS-A relationship.
* Verify active tech preview destinationIds refer to active Concepts in either the tech preview or the release.
* Verify typeIds are valid core SNOMEDCT concepts.
* Verify inactive concepts are not sourceId, destinationId, or typeId of active relationships.
* Verify tech preview relationship sourceId does not equal destinationId - snapshot only
* Verify active tech preview relationships should not have singleton, non-zero relationship group values
* Verify there are no active tech preview FN descriptions matching active core descriptions
* Verify no active tech preview FN descriptions assigned to core concepts with active core FN descriptions
* Verify tech preview Definition ids are unique.
* Verify definition id,effectiveTime tuples are unique
* Verify definitions are unique
* Verify tech preview definitions have an core partition ID (01).
* Verify definition identifiers are longer than 5 digits and shorter than 19
* Verify definitions have a valid check digit.
* Verify definitions have valid effectiveTime (YYYYMMDD).
* Verify definitions have valid active (0,1).
* Verify definitions have an approved moduleId
* Verify definitions have the correct number of fields (9).
* Verify definitions have LanguageCode assigned = "en"
* Verify definitions have valid typeId
* Verify definitions have valid caseSignificanceId
* Verify tech preview definitions are associated with valid tech preview or core concepts
* Verify definitions do not have double-quote characters in the term.
* Verify active tech preview FN definitions are unique.
* Verify all definitions have no '?' characters in the term field
* Verify language refset member ids are unique.
* Verify language refset member id,effectiveTime tuples are unique
* Verify language ref set members are unique
* Verify language refset members have valid effectiveTime (YYYYMMDD).
* Verify language refset members have valid active (0,1).
* Verify language refset members have an approved moduleId
* Verify language refset members have the correct number of fields (7).
* Verify refSetId is a valid tech preview or core concept
* Verify refSetId has valid metadata.
* Verify language refset members are tech preview descriptions.
* Verify all tech preview descriptions have a language refset entry
* Verify tech preview concepts should have exactly one active preferred FN and exactly one active preferred SY
* Verify simple map refset member ids are unique.
* Verify simple map refset member id,effectiveTime tuples are unique
* Verify simple map ref set members are unique
* Verify simple map refset members have valid effectiveTime (YYYYMMDD).
* Verify simple map refset members have valid active (0,1).
* Verify simple map refset members have an approved moduleId
* Verify simple map refset members have the correct number of fields (6).
* Verify refSetId is a valid tech preview or core concept
* Verify refSetId has valid metadata.
* Verify simple map refset members are tech preview or core concepts
* Verify inactive tech preview component entries (all files) have prior effectiveTime active entries as well
* Verify inactive tech preview component entries (all files) do not have core ID and current tech preview effectiveTime
* Verify inactive "pending move" with non-current effectiveTime corresponds with a "moved to" entry (for FULL)
* Verify inactive tech preview concepts have matching inactivation entries in relationships with same effectiveTime
* Verify inactive tech preview concepts have corresponding new entries in the attribute value "Concept inactivation indicator" refset with the same effective time
* Verify inactive tech preview concepts have corresponding new entries in the AssociationReference refset with "moved to", "replaced by", or "sameas" entries and a matching effective time
* Verify all tech preview descriptions have at least one active language refset entry
* Verify sort order
* Verify effectiveTime
* Verify all characters are valid UTF8 terminology characters.
* Verify line termination.
* Verify tech preview column headers match core.
* Verify file naming conventions.
* Verify the same date is used in all file names.
