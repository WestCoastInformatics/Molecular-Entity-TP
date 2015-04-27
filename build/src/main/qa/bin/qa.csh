#!/bin/csh -f
#
# QA RF2 (international edition, no namespace)
#

# Pass it an RF2 directory
set moduleId = 705115006
set originModuleId = 705115006
set namespaceId = "[0-9]"
set type = MolecularEntityTechPreview

#
# Check Environment Variables
#
if ($?PATH_TO_PERL == 0) then
    echo '$PATH_TO_PERL must be set'
    exit 1
endif

#
# Parse arguments
#
set quick = 0
set i=1
while ($i <= $#argv)
echo $i
    switch ($argv[$i])
        case '-*help':
            cat << EOF
 This script has the following usage:
   Usage: $0 [-[-]help] [-q] <extdir> <coredir>

   This script performs QA checks on RF2 files for a technology preview.

 Options:
     --help                    : display this help 

EOF
            exit 0

         case '-q':
         	set quick = 1
         	breaksw
         default :
            set arg_count=2
            set all_args=`expr $i + $arg_count - 1`
            if ($all_args != $#argv) then
                echo "Error: Incorrect number of arguments: $all_args, $#argv"
                echo "Usage: $0 [-[-]help] [-q] <rf2 dir>"
                exit 1
            endif
            set extDir = $argv[$i]
            set i=`expr $i + 1`
            set coreDir = $argv[$i]
            set i=`expr $i + 1`
    endsw
    set i=`expr $i + 1`
end

echo "----------------------------------------------------------------------"
echo "Starting ... `/bin/date`"
echo "----------------------------------------------------------------------"
echo "Tech Preview dir:       $extDir"
echo "Release dir:            $coreDir"
echo ""

set etDir = "$extDir/Terminology"
set erDir = "$extDir/Refset"
set ctDir = "$coreDir/Terminology"
set crDir = "$coreDir/Refset"
set extType = snapshot
set coreType = snapshot

#
# Set core relationship ids and refsets
#
echo "    Look up core relationshipType, refset, and other metadata concepts `/bin/date`"
set isAConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Is a (attribute)";' $ctDir/*Description*txt`
set movedToRefset = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "MOVED TO association reference set";' $ctDir/*Description*txt`
set pendingMoveConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Pending move";' $ctDir/*Description*txt`
set replacedByRefset = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "REPLACED BY association reference set";' $ctDir/*Description*txt`
set sameAsRefset = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "SAME AS association reference set";' $ctDir/*Description*txt`
set conceptInactivationRefset = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Concept inactivation indicator reference set";' $ctDir/*Description*txt`
set conceptInactivationValue = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Concept inactivation value";' $ctDir/*Description*txt`
set descInactivationRefset = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Description inactivation indicator reference set";' $ctDir/*Description*txt`
set descInactivationValue = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Description inactivation value";' $ctDir/*Description*txt`
set fsnConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Fully specified name";' $ctDir/*Description*txt`
set syConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Synonym (core metadata concept)";' $ctDir/*Description*txt`
set preferredConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Preferred (foundation metadata concept)";' $ctDir/*Description*txt`
set acceptableConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Acceptable (foundation metadata concept)";' $ctDir/*Description*txt`
#set movedElsewhereConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Moved elsewhere";' $ctDir/*Description*txt`
set movedElsewhereConcept = 900000000000487009
set inactiveConcept = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[7] eq "Inactive concept";' $ctDir/*Description*txt`

echo "    Creating ID Files ... `/bin/date`"
if ($quick == 0) then
#
# setup UI files
#
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id" || $_[3] ne "'$originModuleId'";' $etDir/*Concept*txt | sort >&! extCid.txt
egrep "$namespaceId" extCid.txt >&! extCidExtOnly.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id" || $_[3] ne "'$originModuleId'";' $etDir/*Desc*txt | sort >&! extDid.txt
egrep "$namespaceId" extDid.txt >&! extDidExtOnly.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id" || $_[3] ne "'$originModuleId'";' $etDir/*Definition*txt | sort >&! extDefid.txt
egrep "$namespaceId" extDefid.txt >&! extDefidExtOnly.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id" || $_[3] ne "'$originModuleId'";' $etDir/*Relation*txt | sort >&! extRid.txt
egrep "$namespaceId" extRid.txt >&! extRidExtOnly.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id" || $_[3] ne "'$originModuleId'";' $etDir/*StatedRelation*txt | sort >&! extStatedRid.txt
egrep "$namespaceId" extStatedRid.txt >&! extStatedRidExtOnly.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id" || $_[3] ne "'$originModuleId'";' $etDir/*_Relation*txt | sort >&! extInferredRid.txt
egrep "$namespaceId" extInferredRid.txt >&! extInferredRidExtOnly.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]|$_[5]\n" unless $_[4] eq "sourceId" || $_[3] ne "'$originModuleId'";' $etDir/*Relation*txt | sort -u >&! extRelCid1Cid2.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" unless $_[4] eq "sourceId" || $_[3] ne "'$originModuleId'";' $etDir/*Relation*txt | sort -u >&! extRelCid1.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n" unless $_[5] eq "destinationId" || $_[3] ne "'$originModuleId'";' $etDir/*Relation*txt | sort -u >&! extRelCid2.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" unless $_[7] eq "typeId" || $_[3] ne "'$originModuleId'";' $etDir/*Relation*txt | sort -u >&! extRelType.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id";' $ctDir/*Concept*txt | sort >&! coreCid.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id";' $ctDir/*Desc*txt | sort >&! coreDid.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" unless $_[0] eq "id";' $ctDir/*Relation*txt | sort >&! coreRid.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" unless $_[7] eq "typeId";' $ctDir/*Relation*txt | sort -u >&! coreRelType.txt
endif

#####################################################################################
#
# QA of Concepts File
#
#####################################################################################
echo ""
echo "  CONCEPTS QA"
echo ""

#
# Verify concept ids are unique
#
if ($extType == "snapshot") then
    echo "    Verify concept ids are unique ...`/bin/date`"
    set ct = `uniq -d extCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: Non-unique tech preview ConceptIDs"
	uniq -d extCid.txt | sed 's/^/      /'
    endif
endif

#
# Verify concept id,effectiveTime tuples are unique
#
echo "    Verify concept id,effectiveTime tuples are unique ...`/bin/date`"
set ct = `cut -d\	 -f 1,2 $etDir/*Concept*txt | sort | uniq -d | wc -l`
if ($ct != 0) then
    echo "      ERROR: Non-unique concept id,effectiveTime"
    cut -d\	 -f 1,2 $etDir/*Concept*txt | sort | uniq -d | sed 's/^/      /'
endif

#
# Verify tech preview concepts have an core partition ID (00)
#
echo "    Verify tech preview concepts have an core partition ID (00) ...`/bin/date`"
set ct = `egrep "$namespaceId" extCid.txt | egrep -v '00.$' |  wc -l`
if ($ct != 0) then
    echo "      ERROR: tech preview ConceptID with bad partitionID"
    egrep "$namespaceId" extCid.txt | egrep -v '00.$' | sed 's/^/      /'
endif

#
# Verify concept identifiers are longer than 5 digits and shorter than 19
#
echo "    Verify concept identifiers are longer than 5 digits and shorter than 19 ...`/bin/date`"
set ct = `cut -f 1 extCid.txt | egrep '^.{1,5}$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: ConceptID is too short"
    cut -f 1 extCid.txt | egrep '^.{1,5}$' | sed 's/^/      /'
endif
set ct = `cut -f 1 extCid.txt | egrep '^.{19,}$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: ConceptID is too long"
    cut -f 1 extCid.txt | egrep '^.{19,}$' | sed 's/^/      /'
endif

#
# Verify concepts have a valid check digit.
#
echo "    Verify concepts have a valid check digit ...`/bin/date`"
set ct = `"$EXTQA_HOME"/bin/checkDigit.pl extCid.txt | egrep '0$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: ConceptID with bad check digit"
    "$EXTQA_HOME"/bin/checkDigit.pl extCid.txt | egrep '0$' | sed 's/^/      /'
endif

#
# Verify concepts have valid effectiveTime (YYYYMMDD).
#
echo "    Verify concepts have valid effectiveTime (YYYYMMDD) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Concept*txt | grep -v effective | wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid effectiveTime"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Concept*txt | grep -v effective | sed 's/^/      /'
endif

#
# Verify concepts have valid active (0,1).
#
echo "    Verify concepts have valid active (0,1) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Concept*txt | grep -v active |  wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid active value"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Concept*txt | grep -v active | sed 's/^/      /'
endif

#
# Verify concepts have an approved moduleId
#
echo "    Verify concepts have an approved moduleId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Concept*txt | grep -v module | wc -l`
if ($ct != 0) then
    echo "      ERROR: concept without approved moduleId ($namespaceId)"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Concept*txt | grep -v module | sed 's/^/      /'
endif

#
# Verify concepts have the correct number of fields (5).
#
echo "    Verify concepts have the correct number of fields (5) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 5;' $etDir/*Concept*txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: concept has wrong number of fields"
    $PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 5;' $etDir/*Concept*txt | sed 's/^/      /'
endif


#
# Verify concepts have a valid definitionStatusId
#     900000000000073002 (Defined).
#     900000000000074008 (Primitive).
#
echo "    Verify concepts have a valid definitionStatusId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[4]\n" if $_[4] ne "900000000000073002" && $_[4] ne "900000000000074008";' $etDir/*Concept* | grep -v definitionStatusId | wc -l`
if ($ct != 0) then
    echo "      ERROR: bad definitionStatusId"
    $PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[4]\n" if $_[4] ne "900000000000073002" && $_[4] ne "900000000000074008";' $etDir/*Concept* |\
	grep -v definitionStatusId | sed 's/^/      /'
endif

#
# Verify tech preview concepts have an active FN (typeId='$fsnConcept') and an active SY (typeId='$syConcept').
# NOTE: verify exactly one active FN
#
if ($extType == "snapshot") then
    echo "    Verify tech preview concepts have an active FN and an active SY ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'"' $etDir/*Description* | sort -u >&! extFn.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[2] eq "1" && $_[6] eq "'$syConcept'"' $etDir/*Description* | sort -u >&! extSy.txt
    join -t\| -j 1 -o 1.1 extFn.txt extSy.txt >&! extSyAndFn.txt
    grep 'conceptWithoutFnPt|' "$EXTQA_HOME"/etc/exceptions.txt |\
    cut -d\| -f 2 | $PATH_TO_PERL -pe 's/^/\^/; s/\(/\\\(/g; s/\)/\\\)/g;' | sort -u -o x.$$.txt
    echo "      *known exceptions = "`cat x.$$.txt | wc -l`' - "grep conceptWithoutFnPt "$EXTQA_HOME"/etc/exceptions.txt"'
    set ct = `comm -13 extSyAndFn.txt extCidExtOnly.txt | egrep -v -f x.$$.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: tech preview concept without active FN and SY"
	comm -13 extSyAndFn.txt extCidExtOnly.txt | egrep -v -f x.$$.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif
    /bin/rm -f extFn.txt extSy.txt extSyAndFn.txt
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'"' $etDir/*Description* | sort | uniq -d | wc -l`
     if ($ct != 0) then
	echo "      ERROR: tech preview concept has more than one active FN"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'"' $etDir/*Description* |\
	    sort | uniq -d | sed 's/^/      /'
    endif


endif

#
# Verify active tech preview concepts have at least one active isa relationship
#
if ($extType == "snapshot") then
    echo "    Verify active tech preview concepts have at least one active isa relationship ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1" && $_[3] eq "'$originModuleId'"' $etDir/*Concept* | sort -u -o activeExtCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[2] eq "1" && $_[7] eq "'$isAConcept'"' $etDir/*Relationship* | sort -u -o activeRelSourceId.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1"' $ctDir/*Concept* | sort -u -o activeCoreCid.txt
    set ct = `comm -23 activeExtCid.txt activeRelSourceId.txt | comm -23 - activeCoreCid.txt | wc -l`
    if ($ct != 0) then
        echo "      ERROR: active tech preview concept without active isa rel"
        comm -23 activeExtCid.txt activeRelSourceId.txt | comm -23 - activeCoreCid.txt |  sed 's/^/      /'
    endif
    /bin/rm -f activeExtCid.txt activeRelSourceId.txt activeCoreCid.txt

endif

#####################################################################################
#
# QA of Descriptions
#
#####################################################################################
echo ""
echo "  DESCRIPTIONS QA"
echo ""

#
# Verify tech preview Description ids are unique.
#
if ($extType == "snapshot") then
    echo "    Verify tech preview Description ids are unique ...`/bin/date`"
    set ct = `uniq -d extDid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: Non-unique tech preview Description ids"
	uniq -d extDid.txt | sed 's/^/      /'
    endif
endif

#
# Verify description id,effectiveTime tuples are unique
#
echo "    Verify description id,effectiveTime tuples are unique ...`/bin/date`"
set ct = `cut -d\	 -f 1,2 $etDir/*Description*txt | sort | uniq -d | wc -l`
if ($ct != 0) then
    echo "      ERROR: Non-unique description id,effectiveTime"
    cut -d\	 -f 1,2 $etDir/*Description*txt | sort | uniq -d | sed 's/^/      /'
endif

#
# Verify descriptions are unique
# There are 4 known cases in the core, exclud them here
#
echo "    Verify tech preview Descriptions are unique ...`/bin/date`"
sort $etDir/*Description*txt |\
    $PATH_TO_PERL -ne '@_ = split /\t/; @x = @_; shift @x; shift @x; print if (join "\t",@x) eq $prev; $prev = (join "\t",@x);' |\
    $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[3] eq "'$originModuleId'"' |\
    sort -u -o x$$.txt
set ct = `cat x$$.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: non-unique description"
    cat x$$.txt | sed 's/^/      /'
endif
/bin/rm -f x$$.txt exceptions.txt

#
# Verify tech preview descriptions have an core partition ID (01).
#
echo "    Verify tech preview descriptions have an core partition ID (01) ...`/bin/date`"
set ct = `egrep -v '01.$' extDidExtOnly.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: tech preview DescriptionID with bad partitionID"
    egrep -v '01.$' extDidExtOnly.txt | sed 's/^/      /'
endif

#
# Verify description identifiers are longer than 5 digits and shorter than 19
#
echo "    Verify description identifiers are longer than 5 digits and shorter than 19 ...`/bin/date`"
set ct = `cut -f 1 extDid.txt | egrep '^.{1,5}$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: DescriptionID is too short"
    cut -f 1 extDid.txt | egrep '^.{1,5}$' | sed 's/^/      /'
endif
set ct = `cut -f 1 extDid.txt | egrep '^.{19,}$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: DescriptionID is too long"
    cut -f 1 extDid.txt | egrep '^.{19,}$' | sed 's/^/      /'
endif

#
# Verify descriptions have a valid check digit.
#
echo "    Verify descriptions have a valid check digit ...`/bin/date`"
set ct = `"$EXTQA_HOME"/bin/checkDigit.pl extDid.txt | egrep '0$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: Description id with bad check digit"
    "$EXTQA_HOME"/bin/checkDigit.pl extDid.txt | egrep '0$' | sed 's/^/      /'
endif

#
# Verify descriptions have valid effectiveTime (YYYYMMDD).
#
echo "    Verify descriptions have valid effectiveTime (YYYYMMDD) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Description*txt | grep -v effective | wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid effectiveTime"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Description*txt | grep -v effective | sed 's/^/      /'
endif

#
# Verify descriptions have valid active (0,1).
#
echo "    Verify descriptions have valid active (0,1) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Description*txt | grep -v active | wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid active value"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Description*txt | grep -v active | sed 's/^/      /'
endif

#
# Verify descriptions have an approved moduleId
#
echo "    Verify descriptions have an approved moduleId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Description*txt | grep -v module | wc -l`
if ($ct != 0) then
    echo "      ERROR: description without approved moduleId ($namespaceId)"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Description*txt | grep -v module | sed 's/^/      /'
endif

#
# Verify descriptions have the correct number of fields (9).
#
echo "    Verify descriptions have the correct number of fields (9) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 9;' $etDir/*Description*txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: tech preview description has wrong number of fields"
    $PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 9;' $etDir/*Description*txt | sed 's/^/      /'
endif

#
# Verify descriptions have LanguageCode assigned = "en"
# 
echo "    Verify descriptions have language code assigned = en ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne 'chop; s/\r//; @_ = split /\t/; print "$_[0]|$_[5]\n" if $_[5] !~ /^en$/ && $_[5] ne "languageCode"' $etDir/*Description* | wc -l`
if ($ct != 0) then
    echo "      ERROR: bad LanguageCode"
    $PATH_TO_PERL -ne 'chop; s/\r//; @_ = split /\t/; print "$_[0]|$_[5]\n" if $_[5] !~ /^en$/ && $_[5] ne "languageCode";' $etDir/*Description* | sed 's/^/      /'
endif

#
# Verify descriptions have valid typeId
#    '$fsnConcept' (Fully Specified Name)
#    '$syConcept' (Synonym)
#
echo "    Verify descriptions have valid typeId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[6]\n" if $_[6] ne "'$fsnConcept'" && $_[6] ne "'$syConcept'";' $etDir/*Description* | grep -v type| wc -l`
if ($ct != 0) then
    echo "      ERROR: bad typeId"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[6]\n" if $_[6] ne "'$fsnConcept'" && $_[6] ne "'$syConcept'";' $etDir/*Description* | grep -v type | sed 's/^/      /'
endif

#
# Verify descriptions have valid caseSignificanceId
#    900000000000448009 (Case insensitive)
#    900000000000017005 (Case sensitive)
#    900000000000020002 (first letter)
#
echo "    Verify descriptions have valid caseSignificanceId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[8]|\n" if $_[8] !~ /^(900000000000448009|900000000000017005|900000000000020002)$/;' $etDir/*Description* | grep -v case | wc -l`
if ($ct != 0) then
    echo "      ERROR: bad caseSignificanceId"
    $PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[8]|\n" if $_[8] !~ /^(900000000000448009|900000000000017005|900000000000020002)$/;' $etDir/*Description* | grep -v case | sed 's/^/      /'
endif
if ($extType == "snapshot") then
  set ct = `$PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[8]|\n" if $_[2] eq "1" && $_[8] !~ /^(900000000000448009|900000000000017005|900000000000020002)$/;' $etDir/*Description* | grep -v case | wc -l`
  if ($ct != 0) then
    echo "      ERROR: bad caseSignificanceId"
    $PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[8]|\n" if $_[2] eq "1" && $_[8] !~ /^(900000000000448009|900000000000017005|900000000000020002)$/;' $etDir/*Description* | sed 's/^/      /'
  endif
endif

#
# Verify tech preview descriptions are associated with valid tech preview or core concepts
#
if ($extType == "snapshot") then
    echo "    Verify descriptions are associated with valid tech preview or core concepts ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[3] eq "'$originModuleId'"' $etDir/*Description* | grep -v conceptId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: description with invalid concept id"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n"' $etDir/*Description* | grep -v conceptId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif
endif

#
# Verify active tech preview FN descriptions do not match active core FNs.
# Cases with the same ID are acceptable due to promotion
#
if ($extType == "snapshot") then
    echo "    Verify active tech preview FN descriptions do not match core FNs ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1"' $etDir/*Concept* | sort -u -o activeExtCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]|$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[3] eq "'$originModuleId'"' $etDir/*Description* |\
        sort -t\| -k 1,1 -o extActiveCidFn.txt
    join -t\| -j 1 -o 2.2 activeExtCid.txt extActiveCidFn.txt | sort -u -o extActiveFn.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1"' $ctDir/*Concept* | sort -u -o activeCoreCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]|$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'"' $ctDir/*Description* | sort -t\| -k 1,1 -o coreActiveCidFn.txt
    join -t\| -j 1 -o 2.2 activeCoreCid.txt coreActiveCidFn.txt | sort -u -o coreActiveFn.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[3] eq "'$originModuleId'"' $etDir/*Description* |\
        sort -u -o extActiveIdFn.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'"' $ctDir/*Description* | sort -u -o coreActiveIdFn.txt
    comm -12 extActiveIdFn.txt coreActiveIdFn.txt | cut -d\| -f 2 | sort -u -o ignoreFn.txt
    set ct = `comm -12 extActiveFn.txt coreActiveFn.txt | comm -23 - ignoreFn.txt | wc -l`
    if ($ct != 0) then
        echo "      ERROR: active tech preview FN is also an FN in the core"
        comm -12 extActiveFn.txt coreActiveFn.txt | comm -23 - ignoreFn.txt | sed 's/^/      /'
    endif
    /bin/rm -f extActiveFn.txt extActiveCidFn.txt coreActiveFn.txt coreActiveCidFn.txt
    /bin/rm -f extActiveIdFn.txt coreActiveIdFn.txt ignoreFn.txt
endif

#
# Verify active tech preview FN descriptions are unique.
#

if ($extType == "snapshot") then
    echo "    Verify active tech preview FN descriptions are unique ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[3] eq "'$originModuleId'"' $etDir/*Description*txt | sort | uniq -d | wc -l`
    if ($ct != 0) then
	echo "      ERROR: duplicate active tech preview FN"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[3] eq "'$originModuleId'"' \
            $etDir/*Description*txt | sort | uniq -d | sed 's/^/      /'
    endif
endif

#
# Verify Active FN descriptions have a valid semantic tag.
#
if ($extType == "snapshot") then
    echo "    Verify Active FN descriptions have a valid semantic tag ...`/bin/date`"
	$PATH_TO_PERL -ne '@_ = split /\t/; $x = $_[7]; $x =~ s/.* \((.+)\)$/$1/; print "$x\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[7] =~ /.* \(.+\)$/;' $etDir/*Description*txt | sort -u >&! extSemanticTags.txt
	$PATH_TO_PERL -ne '@_ = split /\t/; $x = $_[7]; $x =~ s/.* \((.+)\)$/$1/; print "$x\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[7] =~ /.* \(.+\)$/;' $ctDir/*Description*txt | sort -u >&! coreSemanticTags.txt
    # ad valid exceptions (from metadata)
    cat >> coreSemanticTags.txt <<EOF
core metadata concept
foundation metadata concept
molecular entity
EOF
    sort -u -o coreSemanticTags.txt coreSemanticTags.txt
    set ct = `comm -23 extSemanticTags.txt coreSemanticTags.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: tech preview uses semantic tag not in core"
	comm -23 extSemanticTags.txt coreSemanticTags.txt | sed 's/^/      /'
    endif
    /bin/rm -f extSemanticTags.txt coreSemanticTags.txt
endif

#
# Verify all descriptions have no '?' characters in the term field
#
echo "    Verify all descriptions have no '?' characters in the term field ...`/bin/date`"
set ct = `grep '?' $etDir/*Description*txt | $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[1] ge "20100901"' | wc -l`
if ($ct != 0) then
    echo "      ERROR: tech preview description containing ? character - indicates possible bad conversion"
    grep '?' $etDir/*Description*txt | $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[1] ge "20100901"' | sed 's/^/      /'
endif

#
# Verify tech preview descriptions do not have double-quote characters in the term.
#
echo "    Verify tech preview descriptions do not have double quote characters in the term ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" if $_[3] =~ /"/;' $etDir/*Description*txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: term with double quote character"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" if $_[3] =~ /"/;' $etDir/*Description*txt | sed 's/^/      /'
endif

#
# Verify tech preview descriptions do not contain invalid punctuation characters
#
#if ($extType == "snapshot") then
#    echo "    Verify tech preview descriptions do not contain invalid punctuation characters ...`/bin/date`"
#    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" if $_[3] eq "'$originModuleId'";' $etDir/*Description*txt | $LVG_HOME/bin/lvg -f:q0 | $PATH_TO_PERL -ne '@_ = split /\|/; print if $_[0] ne $_[1];' | wc -l`
#    if ($ct != 0) then
#	echo "ERROR: descriptions containing non-ASCII punctuation characters"
#	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" if $_[3] eq "'$originModuleId'";' $etDir/*Description*txt |\
#	    $LVG_HOME/bin/lvg -f:q0 | $PATH_TO_PERL -ne '@_ = split /\|/; print if $_[0] ne $_[1];' | sed 's/^/      /'
#    endif
#endif


#####################################################################################
#
# QA of Relationships
#
#####################################################################################
echo ""
echo "  RELATIONSHIPS QA"
echo ""

#
# Verify tech preview Relationship ids are unique.
#
if ($extType == "snapshot") then
    echo "    Verify tech preview Relationship ids are unique ...`/bin/date`"
    set ct = `uniq -d extRid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: Non-unique tech preview Relationship ids"
	uniq -d extRid.txt | sed 's/^/      /'
    endif
endif

#
# Verify relationship id,effectiveTime tuples are unique
# NOTE: check files together
#
echo "    Verify relationship id,effectiveTime tuples are unique ...`/bin/date`"
set ct = `cut -d\	 -f 1,2 $etDir/*Relationship*txt | grep -v effectiveTime | sort | uniq -d | wc -l`
if ($ct != 0) then
    echo "      ERROR: Non-unique relationship id,effectiveTime"
    cut -d\	 -f 1,2 $etDir/*Relationship*txt | sort | uniq -d | sed 's/^/      /'
endif

#
# Verify relationships are unique
# NOTE: cannot assume that data was not re-activated.  Thus, if we only compare adjacent
#       lines after sorting, we will find what we are looking for
# NOTE: we only check things with dates after 2010901
#
echo "    Verify tech preview Relationships are unique ...`/bin/date`"
sort $etDir/*StatedRelationship*txt |\
    $PATH_TO_PERL -ne '@_ = split /\t/; @x = @_; $x[0]=""; $x[1] = ""; print if (join "\t",@x) eq $prev && $_[1] ge "20100901"; $prev = (join "\t",@x);' |\
    $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[3] eq "'$originModuleId'"' |\
    sort -u -o x$$.txt
set ct = `cat x$$.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: non-unique stated relationship"
    cat x$$.txt | sed 's/^/      /'
endif
/bin/rm -f x$$.txt
sort $etDir/*Relationship*txt |\
    $PATH_TO_PERL -ne '@_ = split /\t/; @x = @_; $x[0]=""; $x[1] = ""; print if (join "\t",@x) eq $prev && $_[1] ge "20100901"; $prev = (join "\t",@x);' |\
    $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[3] eq "'$originModuleId'";' |\
    sort -u -o x$$.txt
grep 'relMovedGroup|' "$EXTQA_HOME"/etc/exceptions.txt |\
    cut -d\| -f 2 | $PATH_TO_PERL -pe 's/^/\^/; s/\(/\\\(/g; s/\)/\\\)/g;' | sort -u -o exc.$$.txt
set ct = `cat x$$.txt | egrep -v -f exc.$$.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: non-unique inferred relationship"
    cat x$$.txt | egrep -v -f exc.$$.txt | sed 's/^/      /'
endif
/bin/rm -f x$$.txt


#
# Verify tech preview Relationship ids have an core partition ID (02).
#
echo "    Verify tech preview Relationship ids have an core partition ID (02) ...`/bin/date`"
set ct = `egrep -v '02.$' extRidExtOnly.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: tech preview Relationship id with bad partitionID"
    grep -v '02.$' extRidExtOnly.txt | sed 's/^/      /'
endif

#
# Verify relationship identifiers are longer than 5 digits and shorter than 19
#
echo "    Verify relationship identifiers are longer than 5 digits and shorter than 19 ...`/bin/date`"
set ct = `cut -f 1 extRid.txt | egrep '^.{1,5}$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: RelationshipID is too short"
    cut -f 1 extRid.txt | egrep '^.{1,5}$' | sed 's/^/      /'
endif
set ct = `cut -f 1 extRid.txt | egrep '^.{19,}$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: RelationshipID is too long"
    cut -f 1 extRid.txt | egrep '^.{19,}$' | sed 's/^/      /'
endif

#
# Verify Relationship ids have a valid check digit.
#
echo "    Verify Relationship ids have a valid check digit ...`/bin/date`"
set ct = `"$EXTQA_HOME"/bin/checkDigit.pl extRid.txt | egrep '0$' | wc -l`
if ($ct != 0) then
    echo "      ERROR: Relationship id with bad check digit"
    "$EXTQA_HOME"/bin/checkDigit.pl extRid.txt | egrep '0$' | sed 's/^/      /'
endif

#
# Verify relationships have valid effectiveTime (YYYYMMDD).
#
echo "    Verify relationships have valid effectiveTime (YYYYMMDD) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Relation*txt | grep -v effective | wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid effectiveTime"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Relation*txt | grep -v effective | sed 's/^/      /'
endif

#
# Verify relationships have valid active (0,1).
#
echo "    Verify relationships have valid active (0,1) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Relation*txt | grep -v active | wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid active value"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Relation*txt | grep -v active | sed 's/^/      /'
endif

#
# Verify relationship have an approved moduleId
#
echo "    Verify relationship have an approved moduleId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Relation*txt | grep -v module | wc -l`
if ($ct != 0) then
    echo "      ERROR: Relationship without approved moduleId ($namespaceId)"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Relation*txt | grep -v module | sed 's/^/      /'
endif

#
# Verify relationships have the correct number of fields (10).
#
echo "    Verify relationships have the correct number of fields (10) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 10;' $etDir/*Relationship*txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: relationship has wrong number of fields"
    $PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 10;' $etDir/*Relationship*txt | sed 's/^/      /'
endif

#
# Verify relationships have valid characteristicTypeId
#   900000000000010007 (Stated)
#   900000000000011006 (Inferred)
#   900000000000227009 (Additional)
#   
echo "    Verify tech preview relationships have valid characteristicTypeId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[8]\n" if $_[8] ne "900000000000010007";' $etDir/*StatedRelation*.txt | grep -v Type | wc -l`
if ($ct != 0) then
    echo "      ERROR: bad characteristicTypeId for Stated relationship"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[8]\n" if $_[8] ne "900000000000010007";' $etDir/*StatedRelation*.txt | grep -v Type | sed 's/^/      /'
endif

if (`ls $etDir/*_Relation*.txt | wc -l` > 0) then
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[8]\n" if $_[8] ne "900000000000011006" && $_[8] ne "900000000000227009";' $etDir/*_Relation*.txt | grep -v Type | wc -l`
if ($ct != 0) then
    echo "      ERROR: bad characteristicTypeId for relationship"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[8]\n" if $_[8] ne "900000000000011006" && $_[8] ne "900000000000227009";' $etDir/*_Relation*.txt | grep -v Type | sed 's/^/      /'
endif
endif

#
# Verify relationships have valid modifierId
#   900000000000451002 (Some)
#
echo "    Verify relationships have valid modifierId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[9]\n" if $_[9] ne "900000000000451002";' $etDir/*Relation*.txt | grep -v modifier | wc -l`
if ($ct != 0) then
    echo "      ERROR: bad modifierId"
    $PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[9]\n" if $_[9] ne "900000000000451002";' $etDir/*Relation*.txt | grep -v modifier | sed 's/^/      /'
endif

#
# Verify RelationshipGroup is non-null.
#
echo "    Verify relationshipGroup is non-null ... `/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print if $_[6] eq "";' $etDir/*Relationship*txt | wc -l`
if ($ct != 0) then
    echo "      ERROR:  RelationshipGroup is null"
    $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[6] eq "";' $etDir/*Relationship*txt | sed 's/^/      /'
endif

#
# Verify tech preview relationship sourceIds are valid tech preview or core concepts
#
if ($extType == "snapshot") then
    echo "    Verify tech preview relationship sourceIds are valid tech preview or core concepts ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n"' $etDir/*Relationship* | grep -v sourceId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: relationship with invalid sourceId"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n"' $etDir/*Relationship* | grep -v sourceId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif
endif

#
# Verify tech preview relationship destinationIds are valid tech preview or core concepts
#
if ($extType == "snapshot") then
    echo "    Verify tech preview relationship destinationIds are valid tech preview or core concepts ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n"' $etDir/*Relationship* | grep -v destinationId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: relationship with invalid destinationId"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n"' $etDir/*Relationship* | grep -v destinationId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif
endif


#
# Verify active tech preview concepts have an active stated IS-A relationship.
#  NOTE: ignore cases that are also core concept ids
#
if ($extType == "snapshot") then
    echo "    Verify active tech preview concepts have an active stated IS-A relationship ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[2] eq "1" && $_[7] eq "'$isAConcept'";' $etDir/*StatedRelationship*txt | sort -u >&! extIsaConcepts.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1" && $_[3] eq "'$originModuleId'"' $etDir/*Concept*txt | sort -u >&! activeExtCidExtOnly.txt
    set ct = `comm -23 activeExtCidExtOnly.txt extIsaConcepts.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: active tech preview concept without an active stated Is A relationship"
	comm -23 activeExtCidExtOnly.txt extIsaConcepts.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif
    /bin/rm -f  activeExtCidExtOnly.txt extIsaConcepts.txt
endif

#
# Verify active tech preview destinationIds refer to active Concepts in either the tech preview or the release.
#
if ($extType == "snapshot") then
    echo "    Verify active tech preview destinationIds refer to active Concepts in either the tech preview or the International release ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1"' $etDir/*Concept*txt |\
	grep -v id | sort -u -o activeExtCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1"' $ctDir/*Concept*txt |\
	grep -v id | sort -u -o activeCoreCid.txt
    sort -u activeExtCid.txt activeCoreCid.txt >&! activeBothCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]|$_[5]\n" unless $_[4] eq "sourceId" || $_[2] eq "0";' $etDir/*Relation*txt | sort -u -t\| -k 1,1 >&! activeExtRelCid1Cid2.txt

    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n" if $_[2] eq "1"' $etDir/*Relationship*txt | sort -u -o activeExtRelCid2.txt
    set ct = `comm -23 activeExtRelCid2.txt activeBothCid.txt  | wc -l`
    if ($ct != 0) then
	echo "      ERROR: active relationship destinationId not an (active) tech preview or core concept"
	comm -23 activeExtRelCid2.txt activeBothCid.txt | sed 's/^/      /'
    endif

    comm -12 activeExtRelCid2.txt extCidExtOnly.txt >&! transCid1.txt
    #sed 's/^/  transcid1.txt - /' transCid1.txt
    
    #
    # find cases where CID2 is in tech preview, look up relationships matching that as CID1
    # and get transitive CID2 and test it as well (in a loop).
    #
## turn off while there are missing isa rels
if (1 == 0) then
    set ct = `cat transCid1.txt | wc -l`
    while ($ct > 0)
	join -t\| -j 1 -o 2.2 transCid1.txt activeExtRelCid1Cid2.txt | sort -u >&! newExtRelCid2.txt
	#sed 's/^/newExtRelCid2.txt - /' newExtRelCid2.txt
	set ct = `comm -23 newExtRelCid2.txt activeBothCid.txt | wc -l`
	if ($ct != 0) then
	    echo "      ERROR: ConceptId2 not in tech preview or core"
	    comm -23 newExtRelCid2.txt activeBothCid.txt | sed 's/^/      /'
	endif
	comm -12 newExtRelCid2.txt extCidExtOnly.txt >&! transCid1.txt
	#sed 's/^/  transcid1.txt - /' transCid1.txt
	set ct = `cat transCid1.txt | wc -l`
end
endif
/bin/rm -f activeBothCid.txt newExtRelCid2.txt transCid1.txt activeCoreCid.txt activeExtCid.txt activeExtRelCid2.txt activeExtRelCid1Cid2.txt
endif

#
# Verify typeIds are valid core SNOMEDCT concepts.
#
echo "    Verify typeIds are valid core SNOMEDCT concepts  ... `/bin/date`"
set ct = `comm -23 extRelType.txt coreRelType.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: RelationshipType not a concept in SNOMEDCT core"
    comm -23 extRelType.txt coreRelType.txt | sed 's/^/      /'
endif


#
# Verify inactive concepts are not sourceId, destinationId, or typeId of active relationships.
#
if ($extType == "snapshot") then
    echo "    Verify inactive concepts are not sourceId, destinationId, or typeId of active relationships ... `/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "0"' $etDir/*Concept*txt | grep -v id >! inactiveCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "0"' $ctDir/*Concept*txt | grep -v id >> inactiveCid.txt
    sort -u -o inactiveCid.txt inactiveCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[2] eq "1"' $etDir/*Relationship*txt | grep -v sourceId | sort -u -o activeRelSourceId.txt
    set ct = `comm -12 inactiveCid.txt activeRelSourceId.txt | wc -l`
    if ($ct > 0) then
	echo "      ERROR: Inactive sourceId associated with active relationship"
	comm -12 inactiveCid.txt activeRelSourceId.txt | sed 's/^/      /'
    endif
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n" if $_[2] eq "1"' $etDir/*Relationship*txt | grep -v destinationId | sort -u -o activeRelDestinationId.txt
    set ct = `comm -12 inactiveCid.txt activeRelDestinationId.txt | wc -l`
    if ($ct > 0) then
	echo "      ERROR: Inactive destinationId associated with active relationship"
	comm -12 inactiveCid.txt activeRelDestinationId.txt | sed 's/^/      /'
    endif
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" if $_[2] eq "1"' $etDir/*Relationship*txt | grep -v typeId | sort -u -o activeRelTypeId.txt
    set ct = `comm -12 inactiveCid.txt activeRelTypeId.txt | wc -l`
    if ($ct > 0) then
	echo "      ERROR: Inactive typeId associated with active relationship"
	comm -12 inactiveCid.txt activeRelTypeId.txt | sed 's/^/      /'
    endif
    /bin/rm -f inactiveCid.txt activeRelSourceId.txt activeRelDestinationId.txt activeRelTypeId.txt
endif

#
# Verify tech preview relationship sourceId does not equal destinationId - snapshot only
#
echo "    Verify tech preview relationship sourceId does not equal destinationId ...`/bin/date`"
if ($extType == "snapshot") then
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print if $_[4] eq $_[5]' $etDir/*Relationship*txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: self-referential relationship"
	$PATH_TO_PERL -ne '@_ = split /\t/; print if $_[4] eq $_[5]' $etDir/*Relationship*txt | sed 's/^/      /'
    endif
endif

#
# Verify active tech preview relationships should not have singleton, non-zero relationship group values
# NOTE: need to run only against edition because there may be one part of a group expressed in the tech preview
# and another part expressed by the core.
echo "    Verify active tech preview relationships should not have singleton, non-zero relationship group values ...`/bin/date`"
if ($extType == "snapshot") then
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]|$_[6]\n" if $_[2] == 1 && $_[6] != 0' \
       $etDir/*Relationship*txt | sort | uniq -u >! x.$$.txt
    set ct = `cat x.$$.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: singleton relationship groups found"
	cat x.$$.txt | sed 's/^/      /'
    endif
    /bin/rm -f x.$$.txt
endif


#####################################################################################
#
# QA against Core
#
#####################################################################################
echo ""
echo "  EXT - CORE QA"
echo ""

#
# Verify there are no active tech preview FN descriptions matching active core descriptions
#  Same typeId, lower(term), caseSignificanceId
#
if ($extType == "snapshot") then
    echo "    Verify no active tech preview FN descriptions matching active core descriptions ...`/bin/date`"
    $PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[4]|$_[6].".(lc($_[7]))."$_[8]|$_[0]\n" \
         if $_[6] eq "900000000000003001" && $_[2] eq "1";' $etDir/*Description*txt |\
         sort -u | sort -t\| -k 1,1 -o actExtDescFld.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1" && $_[3] eq "'$originModuleId'"' $etDir/*Concept* |\
	 sort -u -o activeExtCid.txt
    join -t\| -j 1 -o 1.2 1.3 actExtDescFld.txt activeExtCid.txt | sort -u | sort -t\| -k 1,1 -o x$$.txt
    /bin/mv x$$.txt actExtDescFld.txt	   
    $PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[6].".(lc($_[7]))."$_[8]|$_[0]\n" \
         if $_[6] eq "900000000000003001" && $_[2] eq "1";' $ctDir/*Description*txt |\
         sort -u | sort -t\| -k 1,1 -o actCoreDescFld.txt  
    set ct = `join -t\| -j 1 -o 1.2 2.2 1.1 actExtDescFld.txt actCoreDescFld.txt | wc -l`
    if ($ct > 0) then
	echo "ERROR: active tech preview description matches active core description on typeId, lower(term), caseSignificanceId"
       join -t\| -j 1 -o 1.2 2.2 1.1 actExtDescFld.txt actCoreDescFld.txt | sed 's/^/      /'
    endif
    /bin/rm -f actExtDescFld.txt actCoreDescFld.txt
   
endif

#
# Verify no active tech preview FN descriptions assigned to core concepts with active core FN descriptions
# Cases with the same ID are acceptable due to promotion
#
if ($extType == "snapshot") then
    echo "    Verify no active tech preview FN descriptions assigned to core concepts with active core FN descriptions ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[4]\n" if $_[3] eq "'$originModuleId'" \
         && $_[6] eq "900000000000003001" && $_[2] eq "1";' $etDir/*Description*txt |\
         sort -u | sort -t\| -k 1,1 -o actExtFnCid.txt
    # Remove cases from actExtFnCid.txt that are inactivated in the core
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "0";' $ctDir/*Description*txt |\
       sort -u -o inactiveCoreDesc.txt
    join -t\| -j 1 -v 1 -o 1.1 1.2  actExtFnCid.txt inactiveCoreDesc.txt >! x.$$.txt
    /bin/mv -f x.$$.txt actExtFnCid.txt
    /bin/rm -f x.$$.txt
 
    sort -t\| -k 2,2 -o actExtFnCid.txt actExtFnCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[4]\n" \
         if $_[6] eq "900000000000003001" && $_[2] eq "1";' $ctDir/*Description*txt |\
         sort -u | sort -t\| -k 2,2 -o actCoreFnCid.txt
    join -t\| -j 2 -o 1.2 1.1 2.1 actExtFnCid.txt actCoreFnCid.txt |\
       $PATH_TO_PERL -ne 'chop; @_ = split /\|/; print "$_[0]\n" if $_[1] ne $_[2]' |\
         sort -u -o bothCoreFnCid.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] eq "1";' $ctDir/*Concept*txt |\
         sort -u -o actCoreCid.txt
    set ct = `comm -12 bothCoreFnCid.txt actCoreCid.txt | wc -l`
    if ($ct > 0) then
        echo "ERROR: active tech preview FN descriptions in same concept as active core FN description"
	comm -12 bothCoreFnCid.txt actCoreCid.txt | sed 's/^/      /'
    endif
    /bin/rm -f bothCoreFnCid.txt actExtFnCid.txt actCoreFnCid.txt  actCoreCid.txt inactiveCoreDesc.txt

endif



#####################################################################################
#
# QA of TextDefinition
#
#####################################################################################
echo ""
echo "  TEXT DEFINITION QA"
echo ""


    #
    # Verify tech preview Definition ids are unique.
    #
    if ($extType == "snapshot") then
	echo "    Verify tech preview Definition ids are unique ...`/bin/date`"
	set ct = `uniq -d extDefid.txt | wc -l`
	if ($ct != 0) then
	    echo "      ERROR: Non-unique tech preview Definition ids"
	    uniq -d extDefid.txt | sed 's/^/      /'
	endif
    endif

    #
    # Verify definition id,effectiveTime tuples are unique
    #
    echo "    Verify definition id,effectiveTime tuples are unique ...`/bin/date`"
    set ct = `cut -d\	 -f 1,2 $etDir/*Definition*txt | sort | uniq -d | wc -l`
    if ($ct != 0) then
	echo "      ERROR: Non-unique definition id,effectiveTime"
	cut -d\	 -f 1,2 $etDir/*Definition*txt | sort | uniq -d | sed 's/^/      /'
    endif

    #
    # Verify definitions are unique
    #
    echo "    Verify tech preview Definitions are unique ...`/bin/date`"
    sort $etDir/*Definition*txt |\
	$PATH_TO_PERL -ne '@_ = split /\t/; @x = @_; shift @x; shift @x; print if (join "\t",@x) eq $prev; $prev = (join "\t",@x);' |\
        $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[3] eq "'$originModuleId'"' |\
	sort -u -o x$$.txt
    set ct = `cat x$$.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: non-unique definition"
	cat x$$.txt | sed 's/^/      /'
    endif
    /bin/rm -f x$$.txt

    #
    # Verify tech preview definitions have an core partition ID (01).
    #
    echo "    Verify tech preview definitions have an core partition ID (01) ...`/bin/date`"
    set ct = `egrep -v '01.$' extDefidExtOnly.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: tech preview DefinitionID with bad partitionID"
	egrep -v '01.$' extDefidExtOnly.txt | sed 's/^/      /'
    endif
    
    #
    # Verify definition identifiers are longer than 5 digits and shorter than 19
    #
    echo "    Verify definition identifiers are longer than 5 digits and shorter than 19 ...`/bin/date`"
    set ct = `cut -f 1 extDefid.txt | egrep '^.{1,5}$' | wc -l`
    if ($ct != 0) then
	echo "      ERROR: DefinitionID is too short"
	cut -f 1 extDefid.txt | egrep '^.{1,5}$' | sed 's/^/      /'
    endif
    set ct = `cut -f 1 extDefid.txt | egrep '^.{19,}$' | wc -l`
    if ($ct != 0) then
	echo "      ERROR: DefinitionID is too long"
	cut -f 1 extDefid.txt | egrep '^.{19,}$' | sed 's/^/      /'
    endif

    #
    # Verify definitions have a valid check digit.
    #
    echo "    Verify definitions have a valid check digit ...`/bin/date`"
    set ct = `"$EXTQA_HOME"/bin/checkDigit.pl extDefid.txt | egrep '0$' | wc -l`
    if ($ct != 0) then
	echo "      ERROR: Definition id with bad check digit"
	"$EXTQA_HOME"/bin/checkDigit.pl extDefid.txt | egrep '0$' | sed 's/^/      /'
    endif

    #
    # Verify definitions have valid effectiveTime (YYYYMMDD).
    #
    echo "    Verify definitions have valid effectiveTime (YYYYMMDD) ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Definition*txt | grep -v effective | wc -l`
    if ($ct != 0) then
	echo "      ERROR: invalid effectiveTime"
	$PATH_TO_PERL -ne '@_ = split /\t/; print"$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $etDir/*Definition*txt | grep -v effective | sed 's/^/      /'
    endif

    #
    # Verify definitions have valid active (0,1).
    #
    echo "    Verify definitions have valid active (0,1) ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Definition*txt | grep -v active | wc -l`
    if ($ct != 0) then
	echo "      ERROR: invalid active value"
	$PATH_TO_PERL -ne '@_ = split /\t/; print"$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $etDir/*Definition*txt | grep -v active | sed 's/^/      /'
    endif

    #
    # Verify definitions have an approved moduleId
    #
    echo "    Verify definitions have an approved moduleId ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Definition*txt | grep -v module | wc -l`
    if ($ct != 0) then
	echo "      ERROR: definition without approved moduleId ($namespaceId)"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $etDir/*Definition*txt | grep -v module | sed 's/^/      /'
    endif
    
    #
    # Verify definitions have the correct number of fields (9).
    #
    echo "    Verify definitions have the correct number of fields (9) ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 9;' $etDir/*Definition*txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: tech preview definition has wrong number of fields"
	$PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 9;' $etDir/*Definition*txt | sed 's/^/      /'
    endif

    #
    # Verify definitions have LanguageCode assigned = "en"
    # 
    echo "    Verify definitions have language code assigned = en ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne 'chop; s/\r//; @_ = split /\t/; print "$_[0]|$_[5]\n" if $_[5] !~ /^en$/ && $_[5] ne "languageCode"' $etDir/*Definition* | wc -l`
    if ($ct != 0) then
	echo "      ERROR: bad LanguageCode"
	$PATH_TO_PERL -ne 'chop; s/\r//; @_ = split /\t/; print "$_[0]|$_[5]\n" if $_[5] !~ /^en$/ && $_[5] ne "languageCode";' $etDir/*Definition* | sed 's/^/      /'
    endif

#
# Verify definitions have valid typeId
#    900000000000550004 (definition)
#
echo "    Verify definitions have valid typeId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[6]\n" if $_[6] ne "900000000000550004";' $etDir/*Definition* | grep -v type| wc -l`
if ($ct != 0) then
    echo "      ERROR: bad typeId"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[6]\n" if $_[6] ne "900000000000550004";' $etDir/*Definition* | grep -v type | sed 's/^/      /'
endif

    #
    # Verify definitions have valid caseSignificanceId
    #    900000000000017005 (Case sensitive)
    #
    echo "    Verify definitions have valid caseSignificanceId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[8]\n" if $_[8] !~ /900000000000017005/;' $etDir/*Definition* | grep -v case | wc -l`
    if ($ct != 0) then
	echo "      ERROR: bad caseSignificanceId"
	$PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[0]|$_[8]\n" if $_[8] !~ /900000000000017005/;' $etDir/*Definition* | grep -v case | sed 's/^/      /'
    endif

    #
    # Verify tech preview definitions are associated with valid tech preview or core concepts
    #
    if ($extType == "snapshot") then
	echo "    Verify definitions are associated with valid tech preview or core concepts ...`/bin/date`"
	set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[3] eq "'$originModuleId'"' $etDir/*Definition* | grep -v conceptId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | wc -l`
	if ($ct != 0) then
	    echo "      ERROR: definition with invalid concept id"
	    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n"' $etDir/*Definition* | grep -v conceptId | sort -u | comm -23 - extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
	endif
    endif

    #
    # Verify definitions do not have double-quote characters in the term.
    #
    if ($extType == "snapshot") then
	echo "    Verify definitions do not have double-quote characters in the term ...`/bin/date`"
	set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" if $_[3] =~ /"/;' $etDir/*Definition*txt | wc -l`
	if ($ct != 0) then
	    echo "      ERROR: term with double quote character"
	    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" if $_[3] =~ /"/;' $etDir/*Definition*txt | sed 's/^/      /'
	endif
    endif

    #
    # Verify active tech preview FN definitions are unique.
    #
    if ($extType == "snapshot") then
    echo "    Verify active tech preview FN definitions are unique ...`/bin/date`"
	set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[3] eq "'$originModuleId'"' $etDir/*Definition*txt | sort | uniq -d | wc -l`
	if ($ct != 0) then
	    echo "      ERROR: duplicate active tech preview FN"
	    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[7]\n" if $_[2] eq "1" && $_[6] eq "'$fsnConcept'" && $_[3] eq "'$originModuleId'"' \
		$etDir/*Definition*txt | sort | uniq -d | sed 's/^/      /'
	endif
    endif

    #
    # Verify all definitions have no '?' characters in the term field
    #
    echo "    Verify all definitions have no '?' characters in the term field ...`/bin/date`"
    set ct = `grep '?' $etDir/*Definition*txt | $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[1] ge "20100901"' | wc -l`
    if ($ct != 0) then
	echo "      ERROR: tech preview definition containing ? character - indicates possible bad conversion"
	grep '?' $etDir/*Definition*txt | $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[1] ge "20100901"' | sed 's/^/      /'
    endif


#####################################################################################
#
# QA of Language Refsets
#
#####################################################################################
echo ""
echo "  LANGUAGE REFSET QA"
echo ""

#
# Verify language refset member ids are unique.
#
if ($extType == "snapshot") then
    echo "    Verify language refset member ids are unique ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n";' $erDir/Language/*Language*txt | uniq -d | wc -l`
    if ($ct != 0) then
	echo "      ERROR: Non-unique language refset member ids"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n";' $erDir/Language/*Language*txt | uniq -d | sed 's/^/      /'
    endif
endif

#
# Verify language refset member id,effectiveTime tuples are unique
#
echo "    Verify language refset member id,effectiveTime tuples are unique ...`/bin/date`"
set ct = `cut -d\	 -f 1,2 $erDir/Language/*Language*txt | sort | uniq -d | wc -l`
if ($ct != 0) then
    echo "      ERROR: Non-unique language refset member id,effectiveTime"
    cut -d\	 -f 1,2 $erDir/Language/*Language*txt | sort | uniq -d | sed 's/^/      /'
endif

#
# Verify language ref set members are unique
#
echo "    Verify language refset members are unique ...`/bin/date`"
sort $erDir/Language/*Language*txt |\
    $PATH_TO_PERL -ne '@_ = split /\t/; @x = @_; shift @x; shift @x; print if (join "\t",@x) eq $prev; $prev = (join "\t",@x);' |\
    $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[3] eq "'$originModuleId'"' |\
    sort -u -o x$$.txt
set ct = `cat x$$.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: non-unique language refset members"
    cat x$$.txt | sed 's/^/      /'
endif
/bin/rm -f x$$.txt


#
# Verify language refset members have valid effectiveTime (YYYYMMDD).
#
echo "    Verify language refset members have valid effectiveTime (YYYYMMDD) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $erDir/Language/*Language*txt | grep -v effective | wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid effectiveTime"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $erDir/Language/*Language*txt | grep -v effective | sed 's/^/      /'
endif

#
# Verify language refset members have valid active (0,1).
#
echo "    Verify language refset members have valid active (0,1) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $erDir/Language/*Language*txt | grep -v active |  wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid active value"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $erDir/Language/*Language*txt | grep -v active | sed 's/^/      /'
endif

#
# Verify language refset members have an approved moduleId
#
echo "    Verify language refset members have an approved moduleId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $erDir/Language/*Language*txt | grep -v module | wc -l`
if ($ct != 0) then
    echo "      ERROR: language refset member without approved moduleId ($namespaceId)"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $erDir/Language/*Language*txt | grep -v module | sed 's/^/      /'
endif

#
# Verify language refset members have the correct number of fields (7).
#
echo "    Verify language refset members have the correct number of fields (7) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 7;' $erDir/Language/*Language*txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: language refset has wrong number of fields"
    $PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 7;' $erDir/Language/*Language*txt | sed 's/^/      /'
endif

#
# Verify refSetId is a valid tech preview or core concept
# Verify refSetId has valid metadata.
#
if ($extType == "snapshot") then
    echo "    Verify refSetId is a valid tech preview or core concept ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n"' $erDir/Language/*Language*txt | grep -v ref | sort -u -o languageRefsetCid.txt
    set ct = `comm -23 languageRefsetCid.txt extCid.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: language refSetId is not an tech preview concept"
	comm -23 languageRefsetCid.txt extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif

    echo "    Verify refSetId has valid metadata ...`/bin/date`"
    ($PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n"' $erDir/Metadata/*Descriptor*txt; \
     $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n"' $crDir/Metadata/*Descriptor*txt) |\
	grep -v referenced | sort -u -o descRefsetCid.txt
    set ct = `comm -23 languageRefsetCid.txt descRefsetCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: language refset does not have descriptor"
	comm -23 languageRefsetCid.txt descRefsetCid.txt | sed 's/^/      /'
    endif
    /bin/rm -f languageRefsetCid.txt descRefsetCid.txt
endif

#
# Verify language refset members are tech preview descriptions.
# Verify all tech preview descriptions have a language refset entry
# NOTE: exclude core description ids from this check (because language refset entries are now manged by core and have different UUIDs)
#
if ($extType == "snapshot") then
    echo "    Verify language refset members are for active tech preview descriptions or definitions ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]|$_[2]\n" if $_[3] eq "'$originModuleId'"' $erDir/Language/*Language*txt | grep -v referenced | sort -u -o languageRefsetDidActive.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" if $_[3] eq "'$originModuleId'"' $etDir/*Description*txt | grep -v referenced | sort -u -o extDidActive.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" if $_[3] eq "'$originModuleId'"' $etDir/*Definition*txt | grep -v referenced | sort -u -o extDefActive.txt
    set ct = `comm -23 languageRefsetDidActive.txt extDidActive.txt | comm -23 - extDefActive.txt | sort -t\| -k 1,1 | join -t\| -j 1 -o 1.1 1.2 -v 1 - coreDid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: language referencedComponentId is not an active tech preview description"
	comm -23 languageRefsetDidActive.txt extDidActive.txt | comm -23 - extDefActive.txt | sort -t\| -k 1,1 | join -t\| -j 1 -o 1.1 1.2 -v 1 - coreDid.txt | sed 's/^/      /'
    endif
    echo "    Verify all tech preview descriptions have a language refset entry ...`/bin/date`"
    set ct = `comm -13 languageRefsetDidActive.txt extDidActive.txt | sort -t\| -k 1,1 | join -t\| -j 1 -o 1.1 1.2 -v 1 - coreDid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: description does not have a language refset entry with a matching active value"
	comm -13 languageRefsetDidActive.txt extDidActive.txt | sort -t\| -k 1,1 | join -t\| -j 1 -o 1.1 1.2 -v 1 - coreDid.txt | sed 's/^/      /'
    endif
    echo "    Verify all tech preview definitions have a language refset entry ...`/bin/date`"
    set ct = `comm -13 languageRefsetDidActive.txt extDefActive.txt | sort -t\| -k 1,1 | join -t\| -j 1 -o 1.1 1.2 -v 1 - coreDid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: definition does not have a language refset entry with a matching active value"
	comm -13 languageRefsetDidActive.txt extDefActive.txt | sort -t\| -k 1,1 | join -t\| -j 1 -o 1.1 1.2 -v 1 - coreDid.txt | sed 's/^/      /'
    endif
    /bin/rm -f languageRefsetDidActive.txt extDidActive.txt extDefActive.txt
endif

#
# Verify tech preview concepts should have exactly one active preferred FN and exactly one active preferred SY
#  typeId + acceptabilityId => ?
#  '$fsnConcept' (fn) + '$acceptableConcept' (preferred) = "preferred FN"
#  '$fsnConcept' (fn) + '$preferredConcept' (acceptable) = QA ERROR
#  '$syConcept' (sy) + '$acceptableConcept' (preferred) = "PT"
#  '$syConcept' (sy) + '$preferredConcept' (acceptable) = "SY"
#
# LR: id      effectiveTime   active  moduleId        refsetId        referencedComponentId   acceptabilityId
# D:  id      effectiveTime   active  moduleId        conceptId       languageCode    typeId  term    caseSignificanceId
#
# ONLY check tech preview concepts
# NOTE: this only looks at the US language Refset = 900000000000509007
if ($extType == "snapshot") then
    echo "    Verify tech preview concepts should have exactly one active preferred FN and exactly one active preferred SY ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[4]|$_[6]\n" if $_[2] eq "1"; ' $etDir/*Description*txt |\
	sort -u | sort -t\| -k 1,1 -o didCidType.txt
    $PATH_TO_PERL -ne 'chop; chop;@_ = split /\t/; print "$_[5]|$_[6]\n" if $_[2] eq "1" && $_[4] eq "900000000000509007"; ' $erDir/Language/*Language*txt |\
	sort -u | sort -t\| -k 1,1 -o didAcceptability.txt
    join -t\| -j 1 -o 1.2 1.1 1.3 2.2 didCidType.txt didAcceptability.txt | sed 's/$/\|/' | sort -u -o cidDidTypeA.txt
    set ct = `$PATH_TO_PERL -ne '@_ = split /\|/; $m{$_[0]}++ if $_[2] eq "'$fsnConcept'" && $_[3] eq "'$preferredConcept'"; print if $m{$_[0]}>1;' cidDidTypeA.txt | wc -l`
    if ($ct != 0) then
	echo "ERROR: tech preview concept has more than one preferred FN"
	$PATH_TO_PERL -ne '@_ = split /\|/; $m{$_[0]}++ if $_[2] eq "'$fsnConcept'" && $_[3] eq "'$preferredConcept'"; print if $m{$_[0]}>1;' cidDidTypeA.txt | sed 's/^/      /'
    endif
    #set ct = `$PATH_TO_PERL -ne '@_ = split /\|/; print if $_[2] eq "'$fsnConcept'" && $_[3] eq "'$acceptableConcept'"' cidDidTypeA.txt | wc -l`
    #if ($ct != 0) then
#	echo "ERROR: tech preview concept has an FN marked as 'acceptable'"
#	$PATH_TO_PERL -ne '@_ = split /\|/; print if $_[2] eq "'$fsnConcept'" && $_[3] eq "'$acceptableConcept'"' cidDidTypeA.txt | sed 's/^/      /'
    #endif
    set ct = `$PATH_TO_PERL -ne '@_ = split /\|/; $m{$_[0]}++ if $_[2] eq "'$syConcept'" && $_[3] eq "'$preferredConcept'"; print if $m{$_[0]}>1;' cidDidTypeA.txt | wc -l`
    if ($ct != 0) then
	echo "ERROR: tech preview concept has more than one preferred SY"
	$PATH_TO_PERL -ne '@_ = split /\|/; $m{$_[0]}++ if $_[2] eq "'$syConcept'" && $_[3] eq "'$preferredConcept'"; print if $m{$_[0]}>1;' cidDidTypeA.txt | sed 's/^/      /'
    endif
    set ct = `$PATH_TO_PERL -ne '@_ = split /\|/; print "$_[0]\n" if $_[2] eq "'$fsnConcept'" && $_[3] eq "'$preferredConcept'";' cidDidTypeA.txt | sort | comm -13 - extCid.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "ERROR: tech preview concept has no preferred FN"
	$PATH_TO_PERL -ne '@_ = split /\|/; print "$_[0]\n" if $_[2] eq "'$fsnConcept'" && $_[3] eq "'$preferredConcept'";' cidDidTypeA.txt | sort | comm -13 - extCid.txt |  comm -23 - coreCid.txt | sed 's/^/      /'
    endif
    set ct = `$PATH_TO_PERL -ne '@_ = split /\|/; print "$_[0]\n" if $_[2] eq "'$syConcept'" && $_[3] eq "'$preferredConcept'";' cidDidTypeA.txt | sort | comm -13 - extCid.txt |  comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "ERROR: tech preview concept has no preferred SY"
	$PATH_TO_PERL -ne '@_ = split /\|/; print "$_[0]\n" if $_[2] eq "'$syConcept'" && $_[3] eq "'$preferredConcept'";' cidDidTypeA.txt | sort | comm -13 - extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif
    /bin/rm -f didCidType.txt didAcceptability.txt cidDidTypeA.txt

endif



#####################################################################################
#
# QA of Simple Map Refsets
#
#####################################################################################
echo ""
echo "  SIMPLE MAP REFSET QA"
echo ""

#
# Verify simple map refset member ids are unique.
#
if ($extType == "snapshot") then
    echo "    Verify simple map refset member ids are unique ...`/bin/date`"
    set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n";' $erDir/Map/*SimpleMap*txt | uniq -d | wc -l`
    if ($ct != 0) then
	echo "      ERROR: Non-unique simple map refset member ids"
	$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n";' $erDir/Map/*SimpleMap*txt | uniq -d | sed 's/^/      /'
    endif
endif

#
# Verify simple map refset member id,effectiveTime tuples are unique
#
echo "    Verify simple map refset member id,effectiveTime tuples are unique ...`/bin/date`"
set ct = `cut -d\	 -f 1,2 $erDir/Map/*SimpleMap*txt | sort | uniq -d | wc -l`
if ($ct != 0) then
    echo "      ERROR: Non-unique simple map refset member id,effectiveTime"
    cut -d\	 -f 1,2 $erDir/Map/*SimpleMap*txt | sort | uniq -d | sed 's/^/      /'
endif

#
# Verify simple map ref set members are unique
# NOTE: we only check things with dates after 20100901
#
echo "    Verify simple map refset members are unique ...`/bin/date`"
sort $erDir/Map/*SimpleMap*txt |\
    $PATH_TO_PERL -ne '@_ = split /\t/; @x = @_; shift @x; $et = shift @x; print if (join "\t",@x) eq $prev && $et ge "20100901"; $prev = (join "\t",@x);' |\
    $PATH_TO_PERL -ne '@_ = split /\t/; print if $_[3] eq "'$originModuleId'"' |\
    sort -u -o x$$.txt
set ct = `cat x$$.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: non-unique simple map refset members"
    cat x$$.txt | sed 's/^/      /'
endif
/bin/rm -f x$$.txt

# Verify simple map refset members have valid effectiveTime (YYYYMMDD).
#
echo "    Verify simple map refset members have valid effectiveTime (YYYYMMDD) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $erDir/Map/*SimpleMap*txt | grep -v effective | wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid effectiveTime"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[1]\n" unless $_[1] =~ /^\d{8}$/;' $erDir/Map/*SimpleMap*txt | grep -v effective | sed 's/^/      /'
endif

#
# Verify simple map refset members have valid active (0,1).
#
echo "    Verify simple map refset members have valid active (0,1) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $erDir/Map/*SimpleMap*txt | grep -v active |  wc -l`
if ($ct != 0) then
    echo "      ERROR: invalid active value"
    $PATH_TO_PERL -ne '@_ = split /\t/; print"$_[0]|$_[2]\n" unless $_[2] =~ /^[01]$/;' $erDir/Map/*SimpleMap*txt | grep -v active | sed 's/^/      /'
endif

#
# Verify simple map refset members have an approved moduleId
#
echo "    Verify simple map refset members have an approved moduleId ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $erDir/Map/*SimpleMap*txt | grep -v module | wc -l`
if ($ct != 0) then
    echo "      ERROR: simple map refset member without approved moduleId ($namespaceId)"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[3]\n" unless $_[3] =~ /'$moduleId'/;' $erDir/Map/*SimpleMap*txt | grep -v module | sed 's/^/      /'
endif

#
# Verify simple map refset members have the correct number of fields (7).
#
echo "    Verify simple map refset members have the correct number of fields (7) ...`/bin/date`"
set ct = `$PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 7;' $erDir/Map/*SimpleMap*txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: simple map refset has wrong number of fields"
    $PATH_TO_PERL -ne '@_ = split /\t/; print unless scalar(@_) == 7;' $erDir/Map/*SimpleMap*txt | sed 's/^/      /'
endif

#
# Verify refSetId is a valid tech preview or core concept
# Verify refSetId has valid metadata.
#
if ($extType == "snapshot") then
    echo "    Verify refSetId is a valid tech preview or core concept ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n"' $erDir/Map/*SimpleMap*txt | grep -v ref | sort -u -o avRefsetCid.txt
    set ct = `comm -23 avRefsetCid.txt extCid.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: simple map refSetId is not an tech preview concept"
	comm -23 avRefsetCid.txt extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif

    ($PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n"' $erDir/Metadata/*Descriptor*txt; \
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n"' $crDir/Metadata/*Descriptor*txt) |\
	grep -v referenced | sort -u -o descRefsetCid.txt
    set ct = `comm -23 avRefsetCid.txt descRefsetCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: simple map refset does not have descriptor"
	comm -23 avRefsetCid.txt descRefsetCid.txt | sed 's/^/      /'
    endif
    /bin/rm -f avRefsetCid.txt descRefsetCid.txt
endif

#
# Verify simple map refset members are tech preview or core concepts
# 
if ($extType == "snapshot") then
    echo "    Verify simple map refset members are tech preview or core concepts ...`/bin/date`"
    $PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[5]\n" if $_[3] eq "'$originModuleId'";' \
	$erDir/Map/*SimpleMap*txt | grep -v referenced | sort -u -o simpleMapRefsetRci.txt
    set ct = `comm -23 simpleMapRefsetRci.txt extCid.txt | comm -23 - coreCid.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: attribute value referencedComponentId is not an tech preview concept or description"
	comm -23 simpleMapRefsetRci.txt extCid.txt | comm -23 - coreCid.txt | sed 's/^/      /'
    endif
    /bin/rm -f simpleMapRefsetRci.txt
endif


#####################################################################################
#
# QA of FULL
#
#####################################################################################
if ($extType == "full") then
    echo ""
    echo "  FULL QA"
    echo ""

#
# Verify inactive tech preview component entries (all files) have prior effectiveTime active entries as well
#  i.e. no components enter tech preview as inactive
# NOTE: we only check things with dates after 20100901
# NOTE: only check things with the origin module id
#
echo "    Verify inactive tech preview component entries (all files) have prior effectiveTime active entries as well ...`/bin/date`"
foreach f (`find $extDir -name "*txt"`)
    echo "      Verifying $f ...`/bin/date`"
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[1]\n" if $_[2] eq "0" && $_[3] eq "'$originModuleId'"' $f | sort -u | sort -t\| -k 1,1 -o inactiveIdEt.txt
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[1]\n" if $_[2] eq "1" && $_[3] eq "'$originModuleId'"' $f | sort -u | sort -t\| -k 1,1 -o activeIdEt.txt
    join -t\| -j 1 -o 1.1 1.2 2.2 inactiveIdEt.txt activeIdEt.txt |\
        $PATH_TO_PERL -ne 'chop; @_ = split /\|/; print "$_[0]\n" if $_[2] le $_[1]' | sort -u -o activeThenInactive.txt
    # find anything inactive that doesn't have activeThenInacitve
    sort -t\| -k 1,1 inactiveIdEt.txt | join -t\| -j 1 -v 1 -o 1.1 1.2 - activeThenInactive.txt |\
        $PATH_TO_PERL -ne 'chop; @_ = split /\|/; print "$_[0]\n" if $_[1] ge "20100901"' | sort -u -o x.$$.txt
    set ct = `cat x.$$.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: inactive components without prior active component entries"
	cat x.$$.txt | sed 's/^/      /'
    endif
    /bin/rm -f x.$$.txt inactiveIdEt.txt activeIdEt.txt activeThenInactive.txt x.$$.txt
end

#
# Verify inactive tech preview component entries (all files) do not have core ID and current tech preview effectiveTime
#
echo "    Verify inactive tech preview component entries (all files) do not have core ID and current tech preview effectiveTime ...`/bin/date`"
foreach f (`find $extDir -name "*txt"`)
    echo "      Verifying $f ...`/bin/date`"
    set frag = `echo $f:t | $PATH_TO_PERL -pe 's/(...2_[^_]*_[^_]*_).*/$1/; s/'$type'/Snapshot/'`
    set coreFile = `find $coreDir -name "*$frag*"`
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[1] eq "'$maxEffectiveTime'" && $_[2] eq "0"' $f |\
	sort -u -o extId.txt
    cut -f 1 $coreFile | sort -u -o coreId.txt
    set ct = `comm -12 extId.txt coreId.txt | wc -l`
    if ($ct > 0) then
	echo "ERROR: tech preview is inactivating core data elements"
	comm -12 extId.txt coreId.txt | sed 's/^/      /'
    endif
    /bin/rm -f extId.txt coreId.txt
end

#
# Verify inactive "pending move" with non-current effectiveTime corresponds with a "moved to" entry (for FULL)
#     id      effectiveTime   active  moduleId        refsetId        referencedComponentId   targetComponent
#
echo "    Verify inactive pending move concepts with non-current effectiveTime correspond to a moved to entry ...`/bin/date`"
$PATH_TO_PERL -ne 'chop; chop; @_ = split /\t/; print "$_[5]\n" if $_[1] le "'$maxEffectiveTime'" && $_[6] eq "'$pendingMoveConcept'"' \
    $erDir/Content/*AttributeValue*txt | sort -u >! extPendingMoveCid.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]\n" if $_[2] ne "0";' $etDir/*Concept*txt | sort -u -o inactiveExtCid.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n" if $_[4] eq "'$movedToRefset'";'  $erDir/Content/*Association*txt | sort -u >&! extHistoricalRelConcepts.txt
set ct = `comm -12 inactiveExtCid.txt extPendingMoveCid.txt | comm -23 - extHistoricalRelConcepts.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: now inactive pending move concepts without movedTo entries"
    comm -12 inactiveExtCid.txt extPendingMoveCid.txt | comm -23 - extHistoricalRelConcepts.txt | sed 's/^/      /'
endif
/bin/rm -f extPendingMoveCid.txt inactiveExtCid.txt extHistoricalRelConcepts.txt
    
#    NEW VERIFY CONCEPT INACTIVATION

#
# Verify inactive tech preview concepts have matching inactivation entries in relationships with same effectiveTime
#        i.e. when concept becomes inactive, its relationships become inactive
# NOTE: this suggests concept inactivation wasn't handled properly at that time
# NOTE: we only check things with dates after 20100901
# NOTE: we also exclude cases of concepts that have no relationships
# NOTE: 1111000119100 is a known exception (because of how it was handled by the tech preview in 20120901
#
echo "    Verify inactive tech preview concepts have matching inactivation entries in relationships with same effectiveTime ...`/bin/date`"
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[1]\n" if $_[2] eq "0" && $_[1] ge "20100901"' $etDir/*Concept*txt | sort -u -o inactiveCidEt.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]|$_[1]\n" if $_[2] eq "0" && $_[1] ge "20100901"' $etDir/*Relationship*txt | sort -u -o inactiveSourceIdEt.txt
cut -d\| -f 1 inactiveCidEt.txt | sort -u -o x.$$.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[4]\n" if $_[1] ge "20100901"' $etDir/*Relationship*txt |\
    sort | comm -23 x.$$.txt - | sort -u -o conWithoutRel.txt
set ct = `comm -23 inactiveCidEt.txt inactiveSourceIdEt.txt | join -t\| -j 1 -o 1.1 1.2 -v 1 - conWithoutRel.txt | grep -v 1111000119100 | wc -l`
if ($ct != 0) then
    echo "      ERROR: inactive concepts without corresponding effectiveTime inactive relationships - via sourceId"
    comm -23 inactiveCidEt.txt inactiveSourceIdEt.txt | join -t\| -j 1 -o 1.1 1.2 -v 1 - conWithoutRel.txt | grep -v 1111000119100 | sed 's/^/      /'
endif
/bin/rm -f inactiveCidEt.txt inactiveSourceIdEt.txt x.$$.txt conWithoutRel.txt

#
#  Verify inactive tech preview concepts have corresponding new entries in the attribute value "Concept inactivation indicator" refset with the same effective time
# NOTE: we only check things with dates after 20100901
# NOTE: we only check things with the origin module id
#
echo "    Verify inactive tech preview concepts have corresponding new entries in the attribute value 'Concept inactivation indicator' refset with the same effective time ...`/bin/date`"
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[1]\n" if $_[2] eq "0" && \
    $_[1] ge "20100901" && $_[3] eq "'$originModuleId'"' $etDir/*Concept*txt | sort -u -o inactiveCidEt.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]|$_[1]\n" if $_[2] eq "1" && \
    $_[4] eq "'$conceptInactivationRefset'" && $_[1] ge "20100901"' $erDir/Content/*AttributeValue*txt | sort -u -o inactivationCid.txt
set ct = `comm -23 inactiveCidEt.txt inactivationCid.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: inactive concepts without corresponding new entries in attribute value table"
    comm -23 inactiveCidEt.txt inactivationCid.txt | sed 's/^/      /'
endif
/bin/rm -f inactiveCidEt.txt inactivationCid.txt

#
# Verify inactive tech preview concepts have corresponding new entries in the AssociationReference refset with "moved to", "replaced by", or "sameas" entries and a matching effective time
# NOTE: if the reason for inactivation is "erroneous", no rel needed
# NOTE: we only check things with dates after 20100901
# NOTE: we only check things with the origin module id
#
echo "    Verify inactive tech preview concepts have corresponding new entries in the AssociationReference refset and a matching effective time ...`/bin/date`"
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[0]|$_[1]\n" if $_[2] eq "0" && \
    $_[1] ge "20100901" && $_[3] eq "'$originModuleId'"' $etDir/*Concept*txt | sort -u -o inactiveCidEt.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]|$_[1]\n" if $_[2] eq "1" && \
    $_[1] ge "20100901"' $erDir/Content/*AssociationReference*txt |\
    sort -u -o historicalRelCid.txt
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]|$_[1]\n" if $_[2] eq "1" && $_[1] ge "20100901" && $_[6] eq "900000000000485001\r\n"' \
    $erDir/Content/*Attribute*txt | sort -u -o erroneousCid.txt
set ct = `comm -23 inactiveCidEt.txt historicalRelCid.txt | comm -23 - erroneousCid.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: inactive tech preview concepts without corresponding historical rels"
    comm -23 inactiveCidEt.txt historicalRelCid.txt | comm -23 - erroneousCid.txt | sed 's/^/      /'
endif
/bin/rm -f inactiveCidEt.txt historicalRelCid.txt erroneousCid.txt

#
# Verify all tech preview descriptions have at least one active language refset entry
#  i.e. tech preview descriptions were part of the language subset at some point
#
echo "    Verify all tech preview descriptions have at least one active language refset entry ...`/bin/date`"
$PATH_TO_PERL -ne '@_ = split /\t/; print "$_[5]\n" if $_[2] eq "1"' $erDir/Language/*Language*txt | sort -u -o activeLanguageDid.txt
set ct = `sort -u extDidExtOnly.txt | comm -23 - activeLanguageDid.txt | wc -l`
if ($ct != 0) then
    echo "      ERROR: tech preview descriptions that never had an active language refset entry"
    sort -u extDidExtOnly.txt | comm -23 - activeLanguageDid.txt | sed 's/^/      /'
endif
/bin/rm -f activeLanguageDid.txt

endif

#####################################################################################
#
# QA - combo and other test
#
#####################################################################################
echo ""
echo "  OTHER QA"
echo ""
#
# Verify sort order  (DISABLED FOR NOW)
#
if (1 == 0) then
echo "    Verify sort order ...`/bin/date`"
foreach f (`find $extDir -name "*txt"`)
    echo "      Checking $f"
    if ($f =~ "*ExtendedMap*") then
	echo "      SKIP $f"
    else
	$PATH_TO_PERL -e '<>; while (<>) { print; }' $f | sort -c
	if ($status != 0) then
	    echo "      ERROR: bad sort order"
	endif
    endif
end

# Exceptional sort order for ExtendedMap file
echo "    Verify ExtendedMap sort order ...`/bin/date`"
foreach f (`find $extDir -name "*txt"`)
    if ($f =~ "*ExtendedMap*") then
	echo "      Checking $f"
	$PATH_TO_PERL -e '<>; while (<>) { print; }' $f |\
	    /bin/sort -c -t\	 -k 5,5 -k 6,6n -k 7,7n -k 8,8n -k 1,4 -k 9,9 -k 10,10 -k 11,11 -k 12,12 -k 13,13
	if ($status != 0) then
	    echo "      ERROR: bad sort order"
	endif
    endif
end
endif


#
# Verify effectiveTime
# 20110301
# 20110801
# 20120301
# 20120901
#
echo "    Verify effectiveTime ...`/bin/date`"
if (extType == "full") then
    $PATH_TO_PERL -ne '@_ = split /\t/; print "$_[1]\n" unless $_[1] =~ /[a-zA-Z]/' `find $extDir -name "*txt" | grep -v -i identifier` | sort -u >! x.$$.txt
    set ct = `diff "$EXTQA_HOME"/etc/effectiveTimes.txt x.$$.txt | wc -l`
    if ($ct != 0) then
	echo "      ERROR: unexpected effectiveTime"
	diff  "$EXTQA_HOME"/etc/effectiveTimes.txt x.$$.txt | sed 's/^/      /'
    endif
    /bin/rm -f x.$$.txt
endif

#
# Verify all characters are valid UTF8 terminology characters. 
#
echo "    Verify all characters are valid UTF8 terminology characters ...`/bin/date`"
foreach file (`find $extDir -name "*txt"`)
    $PATH_TO_PERL -MEncode -ne 'Encode::from_to($_,"utf8","UTF-16LE"); Encode::from_to($_,"UTF-16LE","utf8"); print;' $file >&! fileConv.txt
    set ct = `diff $file fileConv.txt | wc -l`
    if ($ct != 0) then
	echo "ERROR: invalid UTF8 chars in $file"
	diff $file fileConv.txt | sed 's/^/      /'
    endif
end
/bin/rm -f fileConv.txt

#
# Verify line termination.
#
echo "    Verify line termination ...`/bin/date`"
foreach file (`find $extDir -name "*txt"`)
    set ct = `$PATH_TO_PERL -ne 'print unless /\r\n/;' $file | wc -l`
    if ($ct != 0) then
	echo "ERROR: invalid line termination in $file"
	$PATH_TO_PERL -ne 'print unless /\r\n/;' $file | sed 's/^/      /'
    endif
    set ct = `$PATH_TO_PERL -ne 'print if /\r\r\n/;' $file | wc -l`
    if ($ct != 0) then
	echo "ERROR: invalid line termination (extra ^M) in $file"
	$PATH_TO_PERL -ne 'print if /\r\r\n/;' $file | sed 's/^/      /'
    endif
end

#
# Verify tech preview column headers match core.
#
echo "    TODO: (needs better impl) Verify tech preview column headers match core ...`/bin/date`"
if (1 == 0) then

end
/bin/rm -f h1.txt h2.txt cf.txt
endif

# Verify file naming conventions.
#
echo "    Verify file naming conventions ...`/bin/date`"
find $etDir -name "*txt" | $PATH_TO_PERL -ne 'print unless /xsct2_(Concept|Description|StatedRelationship|Relationship|Identifier|TextDefinition)_'$type'(-en)?_INT_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].txt/;' >! exceptions.et.txt
if (`cat exceptions.et.txt | wc -l` > 0) then
    echo "ERROR: File naming convention issues"
    cat exceptions.et.txt | sed 's/^/      /'
endif
/bin/rm -f exceptions.et.txt
find $erDir -name "*txt" | $PATH_TO_PERL -ne 'print unless /xder2_[isc]*Refset_..*'$type'(-en|)_INT_[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9].txt/;' >! exceptions.er.txt
if (`cat exceptions.er.txt | wc -l` > 0) then
    echo "ERROR: File naming convention issues"
    cat exceptions.er.txt | sed 's/^/      /'
endif
/bin/rm -f exceptions.er.txt

#
# Verify the same date is used in all file names.
#
echo "    Verify the same date is used in all file names ...`/bin/date`"
set date = `ls $etDir/*Concept* | sed -e 's/^.*_\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\)\.txt/\1/'`
set verified_date = `echo $date | grep '^[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$'`
if ("$verified_date" == "") then
    echo "      ERROR: invalid date in Concepts file (and possibly other files)"
        ls $etDir/*Concepts* | sed 's/^/      /'
else
    set ct = `find $extDir -name "*txt" | grep -v '^.*_'$date'\.txt$' | grep -v prepExt.txt | wc -l`
    if ($ct != 0) then
        echo "      ERROR: inconsistent dates in file names"
        echo "      Files with date ${verified_date}:"
        find $extDir -name "*txt" | grep '^.*_'$date'\.txt$' | sed 's/^/      /'
        echo "      Files with other date(s):"
        find $extDir -name "*txt" | grep -v '^.*_'$date'\.txt$' | grep -v prepExt.txt | sed 's/^/      /'
    endif

    echo "    Verify max effective time matches the file names ...`/bin/date`"
    if ($date != $maxEffectiveTime) then
        echo "      ERROR: concept file date does not match max effectiveTime"
    endif

endif

#
# Cleanup
#
cat >! clean.$$.txt <<EOF
x.$$.txt
coreCid.txt
coreDid.txt
coreRelType.txt
coreRid.txt
extCid.txt
extCidExtOnly.txt
extDefid.txt
extDefidExtOnly.txt
extDesc.txt
extDid.txt
extDidExtOnly.txt
extInferredRid.txt
extInferredRidExtOnly.txt
extRelCid1.txt
extRelCid1Cid2.txt
extRelCid2.txt
extRelType.txt
extRid.txt
extRidExtOnly.txt
extStatedRid.txt
extStatedRidExtOnly.txt
EOF
/bin/rm -f `cat clean.$$.txt`
/bin/rm -f clean.$$.txt

echo "----------------------------------------------------------------------"
echo "Finished ... `/bin/date`"
echo "----------------------------------------------------------------------"
