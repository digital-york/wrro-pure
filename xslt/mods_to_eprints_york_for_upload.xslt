<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:v3="http://www.loc.gov/mods/v3" xmlns:xlin="http://www.w3.org/1999/xlink" xmlns:riox="http://docs.rioxx.net/schema/v1.0/rioxxterms/" version="1.0" exclude-result-prefixes="v3">  
  <!--
    2024-06-26 (v1.2.2)
     - fix for v5.28.3 upgrade issues (DOI; keywords)
    2024-06-11 (v1.2.1)
     - corresponding author
    2024-05-28 (v1.2.0):
     - include Sustainable Development Goals
     - improve peer reviewed mapping
     - include data from 'series' host
     - additional mapping for newer identifier representation
     - only map 'extent' to pages when it is pages
     - new ORCID mapping for v5.28
    2022-10-25 (v1.1.0): Various improvements - see closed issues on https://github.com/digital-york/wrro-pure/ 
    2017-05-15: Add mapping of DOI to id_number field. 
      Uses variable below which should be updated when Pure starts 
        using 'https://doi.org/' as the URL stem 
  -->
  <xsl:variable name="doi-url-stub">doi.org/</xsl:variable>
  <xsl:variable name="doi-resolver-base">https://doi.org/</xsl:variable>

  <xsl:output indent="yes" method="xml"/>  
  <xsl:template match="text()"/>  
  <xsl:template match="v3:mods"> 
    <eprints> 
      <eprint> 
        <!-- Institution added JA 2014/6/5 -->  
        <institution> 
          <item>York</item> 
        </institution>  
        <!-- Document visibility -->  
        <xsl:choose> 
          <xsl:when test="v3:note[@type='publication workflow state' and text()='approved']"> 
            <eprint_status>archive</eprint_status> 
          </xsl:when>  
          <xsl:otherwise> 
            <eprint_status>buffer</eprint_status> 
          </xsl:otherwise> 
        </xsl:choose>  
        <pure_status> 
          <xsl:value-of select="v3:note[@type='publication workflow state']"/> 
        </pure_status>  
        <xsl:choose> 
          <xsl:when test="v3:note[@type='publicationStatus']='published'"> 
            <ispublished>pub</ispublished> 
          </xsl:when>  
          <xsl:when test="v3:note[@type='publicationStatus']='inpress'"> 
            <ispublished>inpress</ispublished> 
          </xsl:when>  
          <xsl:when test="v3:note[@type='publicationStatus']='unpublished'"> 
            <ispublished>unpub</ispublished> 
          </xsl:when>  
          <xsl:when test="v3:note[@type='publicationStatus']='inprep'"> 
            <ispublished>inprep</ispublished> 
          </xsl:when>  
          <xsl:when test="v3:note[@type='publicationStatus']='submitted'"> 
            <ispublished>submitted</ispublished> 
          </xsl:when>  
          <xsl:when test="v3:note[@type='publicationStatus']='epub_ahead_of_print'"> 
            <ispublished>published_online</ispublished> 
          </xsl:when>  
          <xsl:otherwise> 
            <ispublished>pub</ispublished> 
          </xsl:otherwise> 
        </xsl:choose>  
        <!-- <date_type>published</date_type> -->  
        <source>pure</source>  
        <title> 
          <xsl:value-of select="v3:titleInfo/v3:title"/>  
          <xsl:if test="v3:titleInfo/v3:subTitle"> 
            <xsl:if test="v3:titleInfo/v3:subTitle != ''"> 
              <xsl:text> : </xsl:text>  
              <xsl:value-of select="v3:titleInfo/v3:subTitle"/> 
            </xsl:if> 
          </xsl:if> 
        </title>  
        <xsl:if test="v3:originInfo/v3:dateOther">
          <dates>
            <xsl:for-each select="v3:originInfo/v3:dateOther">
              <xsl:call-template name="dates"> 
                <xsl:with-param name="dateOther" select="."/> 
              </xsl:call-template> 
            </xsl:for-each>
          </dates>
        </xsl:if>

        <xsl:if test="v3:name[@type='personal']/v3:role/v3:roleTerm[@authority='pure/email']"> 
          <contact_email> 
            <xsl:value-of select="v3:name[@type='personal']/v3:role/v3:roleTerm[@authority='pure/email']"/> 
          </contact_email> 
        </xsl:if>  
        <!-- Authors -->  
        <xsl:if test="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] != 'editor' and v3:namePart[@type = 'family']]"> 
          <creators> 
            <xsl:for-each select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] != 'editor' and v3:namePart[@type = 'family']]"> 
              <item> 
                <xsl:choose> 
                  <xsl:when test="v3:role/v3:roleTerm[@authority='pure/orcid']"> 
                    <orcid> 
                      <xsl:value-of select="v3:role/v3:roleTerm[@authority='pure/orcid']"/> 
                    </orcid> 
                  </xsl:when>  
                  <xsl:when test="v3:nameIdentifier[@typeURI='http://id.loc.gov/vocabulary/identifiers/orcid']">
                    <orcid>
                      <xsl:value-of select="v3:nameIdentifier[@typeURI='http://id.loc.gov/vocabulary/identifiers/orcid']"/>
                    </orcid>
                  </xsl:when>
                  <xsl:otherwise> 
                    <id> 
                      <xsl:value-of select="v3:role/v3:roleTerm[@authority='pure/email']"/> 
                    </id> 
                  </xsl:otherwise> 
                </xsl:choose>  
                <name> 
                  <family> 
                    <xsl:value-of select="v3:namePart[@type='family']"/> 
                  </family>  
                  <given> 
                    <xsl:value-of select="v3:namePart[@type='given']"/> 
                  </given> 
                </name> 
              </item> 
            </xsl:for-each> 
          </creators> 
        </xsl:if>  
        <!-- Corresponding Author -->  
        <xsl:if test="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'correspondingAuthor' and v3:namePart[@type = 'family']]"> 
          <corresponding_author> 
            <name> 
              <family> 
                <xsl:value-of select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'correspondingAuthor' and v3:namePart[@type = 'family']]/v3:namePart[@type='family']"/> 
              </family>  
              <given> 
                <xsl:value-of select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'correspondingAuthor' and v3:namePart[@type = 'family']]/v3:namePart[@type='given']"/> 
              </given> 
            </name> 
            <email> 
              <xsl:value-of select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'correspondingAuthor' and v3:namePart[@type = 'family']]/v3:role/v3:roleTerm[@authority='pure/email']"/> 
            </email> 
          </corresponding_author> 
        </xsl:if>  
        <!-- Group Authors -->  
        <xsl:for-each select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] != 'editor' and not(v3:namePart[@type = 'family'])]"> 
          <corp_creators> 
            <xsl:value-of select="v3:namePart[@type='given']"/> 
          </corp_creators> 
        </xsl:for-each>  
        <!-- Editors -->  
        <xsl:if test="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'editor']"> 
          <editors> 
            <xsl:for-each select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'editor']"> 
              <item> 
                <xsl:choose> 
                  <xsl:when test="v3:role/v3:roleTerm[@authority='pure/orcid']"> 
                    <orcid> 
                      <xsl:value-of select="v3:role/v3:roleTerm[@authority='pure/orcid']"/> 
                    </orcid> 
                  </xsl:when>  
                  <xsl:when test="v3:nameIdentifier[@typeURI='http://id.loc.gov/vocabulary/identifiers/orcid']">
                    <orcid>
                      <xsl:value-of select="v3:nameIdentifier[@typeURI='http://id.loc.gov/vocabulary/identifiers/orcid']"/>
                    </orcid>
                  </xsl:when>
                  <xsl:otherwise> 
                    <id> 
                      <xsl:value-of select="v3:role/v3:roleTerm[@authority='pure/email']"/> 
                    </id> 
                  </xsl:otherwise> 
                </xsl:choose>  
                <name> 
                  <family> 
                    <xsl:value-of select="v3:namePart[@type='family']"/> 
                  </family>  
                  <given> 
                    <xsl:value-of select="v3:namePart[@type='given']"/> 
                  </given> 
                </name> 
              </item> 
            </xsl:for-each> 
          </editors> 
        </xsl:if>  
        <!-- Organisation associations -->  
        <xsl:if test="v3:name[@type='corporate']/v3:role/v3:roleTerm[@authority='pure/linkidentifier/eprint']"> 
          <iau_pure> 
            <xsl:for-each select="v3:name[@type='corporate']/v3:role/v3:roleTerm[@authority='pure/linkidentifier/eprint']"> 
              <item> 
                <xsl:value-of select="."/> 
              </item> 
            </xsl:for-each> 
          </iau_pure> 
        </xsl:if>  
        <!-- Peer reviewed -->  
        <xsl:choose> 
          <xsl:when test="v3:note[@type='peerreview status' and text()='Peer reviewed'] or v3:genre[@type='publicationType'] = '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontobookanthology/peerreviewedchapter'"> 
            <refereed>TRUE</refereed> 
          </xsl:when>  
          <xsl:when test="v3:note[@type='peerreview status' and text()='Non peer reviewed']"> 
            <refereed>FALSE</refereed> 
          </xsl:when>  
          <xsl:otherwise> 
            <!-- No value - unknown peer review status -->
          </xsl:otherwise> 
        </xsl:choose>  
        <!-- SDGs (see: https://github.com/digital-york/wrro-pure/issues/16) -->
        <xsl:if test="v3:classification[@authority='pure/sustainabledevelopmentgoals']">
          <sd_goals>
            <xsl:for-each select="v3:classification[@authority='pure/sustainabledevelopmentgoals']">
              <xsl:variable name="sdgToken"> 
                <xsl:call-template name="find-last-token"> 
                  <xsl:with-param name="uri" select="."/> 
                </xsl:call-template> 
              </xsl:variable>  
              <xsl:call-template name="sustainableDevelopmentGoals"> 
                <xsl:with-param name="uriToken" select="$sdgToken"/> 
              </xsl:call-template>
            </xsl:for-each>
          </sd_goals>
        </xsl:if>
        <!-- Structured keywords 
          NOTE: This is only good as long as the keyword hierarchy in PURE matches the one in ePrints
        -->  
        <xsl:if test="v3:classification[@authority!='pure/sustainabledevelopmentgoals']"> 
          <subjects> 
            <xsl:for-each select="v3:classification[@authority!='pure/sustainabledevelopmentgoals']"> 
              <item> 
                <xsl:call-template name="find-last-token"> 
                  <xsl:with-param name="uri" select="."/> 
                </xsl:call-template> 
              </item> 
            </xsl:for-each> 
          </subjects> 
        </xsl:if>  
        <xsl:if test="v3:location"> 
          <related_url> 
            <xsl:apply-templates select="v3:location/v3:url"/> 
          </related_url> 
        </xsl:if>  
        <xsl:apply-templates/> 
      </eprint> 
    </eprints> 
  </xsl:template>  
  <xsl:template match="v3:abstract[@type='content']"> 
    <abstract> 
      <xsl:value-of select="."/> 
    </abstract> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='host' or @type='series']/v3:part/v3:detail[@type='volume']/v3:number"> 
    <series_volume> 
      <xsl:value-of select="."/> 
    </series_volume> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='host' or @type='series']/v3:part/v3:detail[@type='issue']/v3:number"> 
    <xsl:choose> 
      <xsl:when test="starts-with(/v3:mods/v3:genre[@type='publicationType'], '/dk/atira/pure/researchoutput/researchoutputtypes/bookanthology/') or starts-with(/v3:mods/v3:genre[@type='publicationType'], '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontobookanthology/')"> 
        <edition> 
          <xsl:value-of select="."/> 
        </edition> 
      </xsl:when>  
      <xsl:otherwise> 
        <series_number> 
          <xsl:value-of select="."/> 
        </series_number> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='host']/v3:part/v3:detail[@type='citation']/v3:caption"> 
    <pagerange> 
      <xsl:value-of select="."/> 
    </pagerange> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='host']/v3:part/v3:detail[@type='articleNumber']/v3:number"> 
    <article_number> 
      <xsl:value-of select="."/> 
    </article_number> 
  </xsl:template>  
  <xsl:template match="v3:physicalDescription/v3:extent[not(@unit) or @unit='pages']"> 
    <pages> 
      <xsl:value-of select="."/> 
    </pages> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='host']/v3:identifier[@type='issn']"> 
    <issn> 
      <xsl:value-of select="."/> 
    </issn> 
  </xsl:template>
  <xsl:template match="v3:originInfo/v3:place/v3:placeTerm"> 
    <place_of_pub> 
      <xsl:value-of select="."/> 
    </place_of_pub> 
  </xsl:template>  
  <xsl:template match="v3:originInfo[local-name(..)='mods']/v3:publisher"> 
    <publisher> 
      <xsl:value-of select="."/> 
    </publisher> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='series']/v3:titleInfo/v3:title"> 
    <series> 
      <xsl:value-of select="."/> 
    </series> 
  </xsl:template>  
  <!-- older MODS style -->
  <xsl:template match="v3:identifier[@type='local' and starts-with(text(), 'PURE:')]"> 
    <pureid> 
      <xsl:value-of select="normalize-space(substring-after(text(), 'PURE:'))"/> 
    </pureid> 
  </xsl:template>
  <xsl:template match="v3:identifier[@type='local' and starts-with(text(), 'PubMed:')]"> 
    <pmid> 
      <xsl:value-of select="normalize-space(substring-after(text(), 'PubMed:'))"/> 
    </pmid> 
  </xsl:template>  
  <!-- Newer (5.28.3?) MODS style -->
  <xsl:template match="v3:identifier[@type='pure/id']"> 
    <pureid> 
      <xsl:value-of select="."/> 
    </pureid> 
  </xsl:template>
  <xsl:template match="v3:identifier[@type='pmid']"> 
    <pmid> 
      <xsl:value-of select="."/> 
    </pmid> 
  </xsl:template>  
  <!--
    <xsl:template match="v3:identifier[@type='isbn' and local-name(..)='mods']">
      <isbn><xsl:value-of select="." /></isbn>
    </xsl:template> 
  -->  
  <xsl:template match="v3:identifier[@type='isbn' and local-name(..)='mods'][0]"> 
    <isbn> 
      <xsl:value-of select="."/> 
    </isbn> 
  </xsl:template>  
  <xsl:template match="v3:identifier[@type='doi' and local-name(..)='mods']"> 
    <official_url> 
      <xsl:value-of select="concat($doi-resolver-base, .)"/> 
    </official_url>
    <id_number> 
      <xsl:value-of select="."/> 
    </id_number>
  </xsl:template>
  <xsl:template match="v3:part[local-name(..)='mods']/v3:detail[@type='volume']/v3:number"> 
    <volume> 
      <xsl:value-of select="."/> 
    </volume> 
  </xsl:template>  
  <xsl:template match="v3:part[local-name(..)='mods']/v3:detail[@type='edition']/v3:number"> 
    <edition> 
      <xsl:value-of select="."/> 
    </edition> 
  </xsl:template>  
  <xsl:template match="v3:part[local-name(..)='mods']/v3:detail[@type='issue']/v3:number"> 
    <number> 
      <xsl:value-of select="."/> 
    </number> 
  </xsl:template>  
  <!-- Subjects matches to free keywords -->  
  <xsl:template match="v3:subject"> 
    <xsl:choose> 
      <xsl:when test="@xlin:type != '' and @xlin:type != 'simple'"/>  
      <!-- We only want non-qualified topics -->  
      <xsl:otherwise> 
        <keywords> 
          <!-- don't include topics that belong to a known classification scheme -->
          <xsl:for-each select="v3:topic[not(.=//v3:classification/@displayLabel)]"> 
            <xsl:if test="position() != 1"> 
              <xsl:text>, </xsl:text> 
            </xsl:if>  
            <xsl:value-of select="."/> 
          </xsl:for-each> 
        </keywords> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>  
  <xsl:template match="v3:location[v3:url]"> 
    <!-- ignore this; only render the v3:url below - v3:location is handled in v3:mods template --> 
  </xsl:template>  
  <xsl:template match="v3:location/v3:url"> 
    <item> 
      <url> 
        <xsl:value-of select="."/> 
      </url>  
      <type/> 
    </item> 
  </xsl:template>  
  <xsl:template match="v3:note"> 
    <xsl:choose> 
      <xsl:when test="@type != ''"/>  
      <!-- We only want non-qualified notes -->  
      <xsl:otherwise> 
        <note> 
          <xsl:value-of select="."/> 
        </note> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='host' and @xlin:role='conference']/v3:titleInfo/v3:title"> 
    <event_title> 
      <xsl:value-of select="."/> 
    </event_title> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@type='host' and @xlin:role='conference']/v3:location/v3:physicalLocation"> 
    <event_location> 
      <xsl:value-of select="."/> 
    </event_location> 
  </xsl:template>  
  <xsl:template match="v3:relatedItem[@xlin:role='media']/v3:physicalDescription/v3:form"> 
    <output_media> 
      <xsl:value-of select="."/> 
    </output_media> 
  </xsl:template>  
  <!-- Conference start/end -->  
  <xsl:template match="v3:relatedItem[@type='host' and @xlin:role='conference']/v3:part"> 
    <xsl:choose> 
      <xsl:when test="v3:date[@point='start'] and v3:date[@point='end']"> 
        <event_dates>
          <xsl:value-of select="v3:date[@point='start']"/> - 
          <xsl:value-of select="v3:date[@point='end']"/>
        </event_dates> 
      </xsl:when>  
      <xsl:when test="v3:date[@point='start']"> 
        <event_dates> 
          <xsl:value-of select="v3:date[@point='start']"/> 
        </event_dates> 
      </xsl:when>  
      <xsl:when test="v3:date[@point='end']"> 
        <event_dates> 
          <xsl:value-of select="v3:date[@point='end']"/> 
        </event_dates> 
      </xsl:when> 
    </xsl:choose> 
  </xsl:template>  
  <xsl:template match="v3:genre[@type='publicationType']"> 
    <!-- Type token used for matching for sub types -->  
    <xsl:variable name="typeToken"> 
      <xsl:call-template name="find-last-token"> 
        <xsl:with-param name="uri" select="."/> 
      </xsl:call-template> 
    </xsl:variable>  
    <xsl:choose> 
      <!-- Other contribution -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/othercontribution/')"> 
        <type>other</type>  
        <xsl:call-template name="journalMatch"/> 
      </xsl:when>  
      <!-- Contribution to Journal -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontojournal/')"> 
        <type>article</type>  
        <xsl:call-template name="contributionToJournalType"> 
          <xsl:with-param name="uriToken" select="$typeToken"/> 
        </xsl:call-template>  
        <xsl:call-template name="journalMatch"/> 
      </xsl:when>  
      <!-- Contribution to Periodical -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontoperiodical/')"> 
        <type>article</type>  
        <xsl:call-template name="contributionToPeriodicalType"> 
          <xsl:with-param name="uriToken" select="$typeToken"/> 
        </xsl:call-template>  
        <xsl:call-template name="journalMatch"/> 
      </xsl:when>  
      <!-- Patent -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/patent/')"> 
        <type>patent</type>  
        <xsl:call-template name="patentType"/> 
      </xsl:when>  
      <!-- Contribution to Conference -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontoconference/')"> 
        <type>conference_item</type>  
        <xsl:call-template name="conferenceItemType"> 
          <xsl:with-param name="uriToken" select="$typeToken"/> 
        </xsl:call-template> 
      </xsl:when>  
      <!-- Book Anthology -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/bookanthology/')"> 
        <xsl:choose> 
          <xsl:when test="$typeToken='other' or $typeToken='commissioned'"> 
            <type>monograph</type>  
            <xsl:call-template name="monographType"> 
              <xsl:with-param name="uriToken" select="$typeToken"/> 
            </xsl:call-template> 
          </xsl:when>  
          <xsl:otherwise> 
            <type>book</type>  
            <xsl:call-template name="bookTitleMatch"/> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:when>  
      <!-- Controbution to Book Anthology -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontobookanthology/')"> 
        <xsl:choose> 
          <!-- Book special handling, issue #YORKPURE-140 -->  
          <xsl:when test="$typeToken='conference'"> 
            <type>published_conference_proceedings</type>  
            <xsl:call-template name="journalMatch"/> 
          </xsl:when>  
          <xsl:when test="$typeToken='peerreviewedchapter'"> 
            <type>book_section</type>  
            <xsl:call-template name="bookTitleMatch"/> 
          </xsl:when>  
          <xsl:otherwise> 
            <type>book_section</type>  
            <xsl:call-template name="bookTitleMatch"/> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:when>  
      <!-- Non-textual -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/nontextual/')"> 
        <xsl:choose> 
          <!-- An artist's artefact or work product. -->  
          <xsl:when test="$typeToken='artefact'"> 
            <type>artefact</type>  
            <xsl:call-template name="journalMatch"/> 
          </xsl:when>  
          <!-- Exhibition -->  
          <xsl:when test="$typeToken='exhibition'"> 
            <type>exhibition</type>  
            <xsl:call-template name="journalMatch"/> 
          </xsl:when>  
          <!-- Composition -->  
          <xsl:when test="$typeToken='composition'"> 
            <type>composition</type>  
            <xsl:call-template name="journalMatch"/> 
          </xsl:when>  
          <!-- Performance -->  
          <xsl:when test="$typeToken='performance'"> 
            <type>performance</type>  
            <xsl:call-template name="journalMatch"/> 
          </xsl:when>  
          <!-- Data Set -->  
          <xsl:when test="$typeToken='database'"> 
            <type>dataset</type>  
            <xsl:call-template name="journalMatch"/> 
          </xsl:when>  
          <!-- Other non-textual -->  
          <xsl:otherwise> 
            <type>other</type>  
            <xsl:call-template name="journalMatch"/> 
          </xsl:otherwise> 
        </xsl:choose> 
      </xsl:when>  
      <!-- Working Paper -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/workingpaper/')"> 
        <xsl:choose>
          <xsl:when test="$typeToken='preprint'">
            <type>preprint</type>  
          </xsl:when>
          <xsl:otherwise>
            <type>monograph</type>  
            <xsl:call-template name="monographType"> 
              <xsl:with-param name="uriToken" select="$typeToken"/> 
            </xsl:call-template> 
          </xsl:otherwise>        
        </xsl:choose>
      </xsl:when>  
      <!-- Thesis -->  
      <xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/thesis/')"> 
        <!-- Thesis, specified in STRATHCLYDEPURE-238, STRATHCLYDEPURE-237 -->  
        <type>thesis</type>  
        <xsl:call-template name="thesisType"> 
          <xsl:with-param name="uriToken" select="$typeToken"/> 
        </xsl:call-template> 
      </xsl:when>  
      <!--
        Other types
      -->  
      <xsl:otherwise> 
        <type>other</type>  
        <xsl:call-template name="journalMatch"/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>  

  <xsl:template match="v3:extension"> 
    <funder_grant>
      <xsl:apply-templates/> 
    </funder_grant>
  </xsl:template>  
  <xsl:template match="riox:funder"> 
    <item>
      <funding_body><xsl:value-of select="."/></funding_body> 
      <grant_number><xsl:value-of select="following-sibling::*"/></grant_number>
    </item>
  </xsl:template>  

  <xsl:template name="journalMatch"> 
    <xsl:if test="../v3:relatedItem[@type='host']/v3:titleInfo/v3:title"> 
      <publication> 
        <xsl:value-of select="../v3:relatedItem[@type='host']/v3:titleInfo/v3:title"/>  
        <xsl:if test="../v3:relatedItem[@type='host']/v3:titleInfo/v3:subTitle"> 
          <xsl:if test="../v3:relatedItem[@type='host']/v3:titleInfo/v3:subTitle"> 
            <xsl:if test="../v3:relatedItem[@type='host']/v3:titleInfo/v3:subTitle != ''"> 
              <xsl:text>:</xsl:text>  
              <xsl:value-of select="../v3:relatedItem[@type='host']/v3:titleInfo/v3:subTitle"/> 
            </xsl:if> 
          </xsl:if> 
        </xsl:if> 
      </publication> 
    </xsl:if> 
  </xsl:template>  
  <xsl:template name="bookTitleMatch"> 
    <xsl:if test="../v3:relatedItem[@type='host']/v3:titleInfo/v3:title"> 
      <book_title> 
        <xsl:value-of select="../v3:relatedItem[@type='host']/v3:titleInfo/v3:title"/> 
      </book_title> 
    </xsl:if> 
  </xsl:template>  
  <xsl:template name="contributionToJournalType"> 
    <xsl:param name="uriToken"/>  
    <xsl:choose> 
      <xsl:when test="$uriToken='article'"> 
        <article_type>article</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='letter'"> 
        <article_type>letter</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='comment'"> 
        <article_type>comment</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='book'"> 
        <article_type>book_review</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='scientific'"> 
        <article_type>science_review</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='editorial'"> 
        <article_type>editorial_comment</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='special'"> 
        <article_type>special_issue</article_type> 
      </xsl:when>  
      <xsl:otherwise> 
        <!-- nothing? --> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>  
  <xsl:template name="contributionToPeriodicalType"> 
    <xsl:param name="uriToken"/>  
    <xsl:choose> 
      <xsl:when test="$uriToken='article'"> 
        <article_type>article</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='featured'"> 
        <article_type>article</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='book'"> 
        <article_type>book_review</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='editorial'"> 
        <article_type>editorial_comment</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='letter'"> 
        <article_type>letter</article_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='special'"> 
        <article_type>special_issue</article_type> 
      </xsl:when>  
      <xsl:otherwise> 
        <!-- nothing? --> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>  
  <xsl:template name="monographType"> 
    <xsl:param name="uriToken"/>  
    <xsl:choose> 
      <xsl:when test="$uriToken='workingpaper'"> 
        <monograph_type>working_paper</monograph_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='discussionpaper'"> 
        <monograph_type>discussion_paper</monograph_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='commissioned'"> 
        <monograph_type>research_report</monograph_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='other'"> 
        <monograph_type>report</monograph_type> 
      </xsl:when>  
      <xsl:otherwise> 
        <monograph_type>other</monograph_type> 
      </xsl:otherwise> 
    </xsl:choose>  
    <xsl:call-template name="bookTitleMatch"/> 
  </xsl:template>  
  <xsl:template name="conferenceItemType"> 
    <xsl:param name="uriToken"/>  
    <xsl:choose> 
      <xsl:when test="$uriToken='paper'"> 
        <pres_type>paper</pres_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='poster'"> 
        <pres_type>poster</pres_type> 
      </xsl:when>  
      <xsl:otherwise> 
        <pres_type>other</pres_type> 
      </xsl:otherwise> 
    </xsl:choose>  
    <xsl:choose> 
      <xsl:when test="../v3:relatedItem[@type='host' and @xlin:role='conference']/v3:part/v3:text[@xlin:role='pure/conferencetype']='Conference'"> 
        <event_type>conference</event_type> 
      </xsl:when>  
      <xsl:when test="../v3:relatedItem[@type='host' and @xlin:role='conference']/v3:part/v3:text[@xlin:role='pure/conferencetype']='Workshop'"> 
        <event_type>workshop</event_type> 
      </xsl:when>  
      <xsl:otherwise> 
        <event_type>other</event_type> 
      </xsl:otherwise> 
    </xsl:choose>  
    <xsl:call-template name="journalMatch"/> 
  </xsl:template>  
  <xsl:template name="patentType"> 
    <xsl:if test="../v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role']='inventor']"> 
      <patent_applicant>
        <xsl:value-of select="../v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role']='inventor']/v3:namePart[@type='family']"/>, 
        <xsl:value-of select="../v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role']='inventor']/v3:namePart[@type='given']"/>
      </patent_applicant> 
    </xsl:if>  
    <xsl:choose> 
      <xsl:when test="../v3:subject[@xlin:type='ipc']/v3:topic"> 
        <id_number> 
          <xsl:value-of select="../v3:subject[@xlin:type='ipc']/v3:topic"/> 
        </id_number> 
      </xsl:when>  
      <xsl:when test="../v3:identifier[@type='patent_number']"> 
        <id_number> 
          <xsl:value-of select="../v3:identifier[@type='patent_number']"/> 
        </id_number> 
      </xsl:when> 
    </xsl:choose>  
    <xsl:call-template name="journalMatch"/> 
  </xsl:template>  
  <xsl:template name="thesisType"> 
    <xsl:param name="uriToken"/>  
    <xsl:choose> 
      <xsl:when test="$uriToken='master'"> 
        <thesis_type>masters</thesis_type> 
      </xsl:when>  
      <xsl:when test="$uriToken='doc'"> 
        <thesis_type>phd</thesis_type> 
      </xsl:when>  
      <xsl:otherwise> 
        <thesis_type>other</thesis_type> 
      </xsl:otherwise> 
    </xsl:choose>  
    <xsl:call-template name="journalMatch"/>  
    <institution>York</institution> 
  </xsl:template>  
  <xsl:template name="find-last-token"> 
    <xsl:param name="uri"/>  
    <xsl:choose> 
      <xsl:when test="contains($uri,'/')"> 
        <xsl:call-template name="find-last-token"> 
          <xsl:with-param name="uri" select="substring-after($uri,'/')"/> 
        </xsl:call-template> 
      </xsl:when>  
      <xsl:otherwise> 
        <xsl:value-of select="$uri"/> 
      </xsl:otherwise> 
    </xsl:choose> 
  </xsl:template>  
  <xsl:template name="uppercase"> 
    <xsl:param name="uri"/>  
    <xsl:value-of select="translate($uri, 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/> 
  </xsl:template> 

  <!-- Dates / types compund field -->
  <xsl:template name="dates"> 
    <xsl:param name="dateOther"/>  
    <xsl:choose> 
      <xsl:when test="$dateOther/@type='inprep' or $dateOther/@type='unpublished'">
        <!-- not mapped -->
      </xsl:when>  
      <xsl:when test="$dateOther/@type='inpress'">
        <item>
          <date_type>accepted</date_type>
          <date><xsl:value-of select="$dateOther"/></date>
        </item>
      </xsl:when>  
      <xsl:when test="$dateOther/@type='epub'">
        <item>
          <date_type>published_online</date_type>
          <date><xsl:value-of select="$dateOther"/></date>
        </item>
      </xsl:when>  
      <xsl:otherwise> 
        <item>
          <date_type><xsl:value-of select="$dateOther/@type"/></date_type>
          <date><xsl:value-of select="$dateOther"/></date>
        </item>
      </xsl:otherwise> 
    </xsl:choose>  
  </xsl:template>  

  <xsl:template name="sustainableDevelopmentGoals">
    <xsl:param name="uriToken"/>
    <xsl:choose>
      <xsl:when test="$uriToken='no_poverty'">
        <item>01np</item>
      </xsl:when>
      <xsl:when test="$uriToken='zero_hunger'">
        <item>02zh</item>
      </xsl:when>
      <xsl:when test="$uriToken='good_health_and_well_being'">
        <item>03ghwb</item>
      </xsl:when>
      <xsl:when test="$uriToken='quality_education'">
        <item>04qe</item>
      </xsl:when>
      <xsl:when test="$uriToken='gender_equality'">
        <item>05ge</item>
      </xsl:when>
      <xsl:when test="$uriToken='clean_water_and_sanitation'">
        <item>06cws</item>
      </xsl:when>
      <xsl:when test="$uriToken='affordable_and_clean_energy'">
        <item>07ace</item>
      </xsl:when>
      <xsl:when test="$uriToken='decent_work_and_economic_growth'">
        <item>08dweg</item>
      </xsl:when>
      <xsl:when test="$uriToken='industry_innovation_and_infrastructure'">
        <item>09iii</item>
      </xsl:when>
      <xsl:when test="$uriToken='reduced_inequalities'">
        <item>10ri</item>
      </xsl:when>
      <xsl:when test="$uriToken='sustainable_cities_and_communities'">
        <item>11scc</item>
      </xsl:when>
      <xsl:when test="$uriToken='responsible_consumption_and_production'">
        <item>12rcp</item>
      </xsl:when>
      <xsl:when test="$uriToken='climate_action'">
        <item>13ca</item>
      </xsl:when>
      <xsl:when test="$uriToken='life_below_water'">
        <item>14lbw</item>
      </xsl:when>
      <xsl:when test="$uriToken='life_on_land'">
        <item>15lol</item>
      </xsl:when>
      <xsl:when test="$uriToken='peace_justice_and_strong_institutions'">
        <item>16pjsi</item>
      </xsl:when>
      <xsl:when test="$uriToken='partnerships'">
        <item>17pfg</item>
      </xsl:when>
      <xsl:otherwise>
        <!-- nothing? -->
      </xsl:otherwise> 
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
