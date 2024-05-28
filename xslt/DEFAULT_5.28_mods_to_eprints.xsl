<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:v3="http://www.loc.gov/mods/v3"
				xmlns:xlin="http://www.w3.org/1999/xlink"
				exclude-result-prefixes="v3">

	<xsl:output indent="yes" method="xml"/>
	<xsl:template match="text()"/>
	
	<xsl:variable name="MasterThesis">Master's Thesis</xsl:variable>
	
	<xsl:template match="v3:mods">
		<eprints>
			<eprint>
				<!-- Document visibility -->
				<xsl:choose>
					<xsl:when test="v3:note[@type='publication workflow state' and text()='approved']">
						<eprint_status>archive</eprint_status>
					</xsl:when>
					<xsl:otherwise>
						<eprint_status>buffer</eprint_status>
					</xsl:otherwise>
				</xsl:choose>
				<!-- publishing status UKPURE-403 -->
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
						<ispublished>submitted</ispublished>
					</xsl:when>
					<xsl:otherwise>
						<ispublished>pub</ispublished>
					</xsl:otherwise>
				</xsl:choose>
				<date_type>published</date_type>
				<source>pure</source>
				<date><xsl:value-of select="v3:originInfo/v3:dateIssued" /></date>
				<xsl:if test="v3:name[@type='personal']/v3:role/v3:roleTerm[@authority='pure/email']">
					<contact_email><xsl:value-of select="v3:name[@type='personal']/v3:role/v3:roleTerm[@authority='pure/email']" /></contact_email>
				</xsl:if>
				
				<!-- Authors -->
				<xsl:if test="v3:name[@type='personal' and count(v3:role/v3:roleTerm[@authority='pure/role' and text()='editor'])=0 and count(v3:role/v3:roleTerm[@authority='pure/role' and text()='groupauthor'])=0]">
					<creators>
						<xsl:for-each select="v3:name[@type='personal' and count(v3:role/v3:roleTerm[@authority='pure/role' and text()='editor'])=0 and count(v3:role/v3:roleTerm[@authority='pure/role' and text()='groupauthor'])=0]">
							<item>
								<name>
									<family><xsl:value-of select="v3:namePart[@type='family']"/></family>
									<given><xsl:value-of select="v3:namePart[@type='given']"/></given>
								</name>
								<xsl:if test="v3:role/v3:roleTerm[@authority='pure/email']">
									<id><xsl:value-of select="v3:role/v3:roleTerm[@authority='pure/email']"/></id>
								</xsl:if>
							</item>
						</xsl:for-each>
					</creators>
				</xsl:if>
				<!-- Group Authors -->
				<xsl:if test="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'groupauthor']">
					<corp_creators>
						<xsl:for-each select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'groupauthor']">
							<item>
								<xsl:value-of select="v3:namePart[@type='given']"/>
							</item>
						</xsl:for-each>
					</corp_creators>
				</xsl:if>

				<!-- Editors -->
				<xsl:if test="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'editor']"> 
					<editors>
						<xsl:for-each select="v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role'] = 'editor']">
							<item>
								<name>
									<family><xsl:value-of select="v3:namePart[@type='family']"/></family>
									<given><xsl:value-of select="v3:namePart[@type='given']"/></given>
								</name>
								<xsl:if test="v3:role/v3:roleTerm[@authority='pure/email']">
									<email><xsl:value-of select="v3:role/v3:roleTerm[@authority='pure/email']"/></email>
								</xsl:if>
							</item>
						</xsl:for-each>
					</editors>
				</xsl:if>

				<!-- Organisation associations -->
				<xsl:if test="v3:name[@type='corporate']/v3:role/v3:roleTerm[@authority='pure/linkidentifier/eprint']">
					<divisions>
						<xsl:for-each select="v3:name[@type='corporate']/v3:role/v3:roleTerm[@authority='pure/linkidentifier/eprint']">
							<item><xsl:value-of select="."/></item>
						</xsl:for-each>
					</divisions>
				</xsl:if>
				
				<!-- Peer reviewed -->
				<xsl:choose>
					<xsl:when test="v3:note[@type='peerreview status' and text()='Peer reviewed']">
						<refereed>TRUE</refereed>
					</xsl:when>
					<xsl:otherwise>
						<refereed>FALSE</refereed>
					</xsl:otherwise>
				</xsl:choose>
				
				<!-- Library of congress keywords to subject -->
				<!-- NOTE: This is only good as long as the keyword hierarchy in PURE matches the one in ePrints -->
				<xsl:if test="v3:subject"> 
					<subjects>
						<xsl:for-each select="v3:subject">
							<item>
								<xsl:call-template name="find-last-token">
									<xsl:with-param name="uri" select="." />
								</xsl:call-template>
							</item>
						</xsl:for-each>
					</subjects>
				</xsl:if>

				<!-- Links -->
				<xsl:if test="v3:location/v3:url[@note!='Official URL']">
					<related_url>
						<xsl:for-each select="v3:location/v3:url[@note!='Official URL']">
							<item>
								<url><xsl:value-of select="."/></url>
								<xsl:choose>
									<xsl:when test="@note='Author'">
										<type>author</type>
									</xsl:when>
									<xsl:when test="@note='Department'">
										<type>department</type>
									</xsl:when>
									<xsl:when test="@note='Event'">
										<type>event</type>
									</xsl:when>
									<xsl:when test="@note='Journal or Publication'">
										<type>journal</type>
									</xsl:when>
									<xsl:when test="@note='Organisation'">
										<type>org</type>
									</xsl:when>
									<xsl:when test="@note='Publisher'">
										<type>pub</type>
									</xsl:when>
									<xsl:when test="@note='Related Item'">
										<type>related</type>
									</xsl:when>
									<xsl:otherwise>
										<type/>
									</xsl:otherwise>
								</xsl:choose>
							</item>
						</xsl:for-each>
					</related_url>
				</xsl:if>
				<xsl:if test="v3:location/v3:url[@note='Official URL']">
					<official_url><xsl:value-of select="v3:location/v3:url[@note='Official URL']"/></official_url>
				</xsl:if>

				<xsl:apply-templates/>
			</eprint>
		</eprints>
	</xsl:template>

	<xsl:template match="v3:note[@type='referencetext']">
		<referencetext>
			<xsl:value-of select="."/>
		</referencetext>
	</xsl:template>

	<xsl:template match="v3:abstract[@type='content']">
		<abstract><xsl:value-of select="." /></abstract>
	</xsl:template>
	
	<xsl:template match="v3:relatedItem[@type='host']/v3:part/v3:detail[@type='articleNumber']/v3:number">
		<article_number><xsl:value-of select="." /></article_number>
	</xsl:template>
	
	<xsl:template match="v3:relatedItem[@type='host']/v3:part/v3:detail[@type='citation']/v3:caption">
		<pagerange><xsl:value-of select="." /></pagerange>
	</xsl:template>
	
	<xsl:template match="v3:physicalDescription/v3:extent">
		<pages><xsl:value-of select="." /></pages>
	</xsl:template>
	
	<xsl:template match="v3:relatedItem[@type='host']/v3:identifier[@type='issn'][1]">
		<issn><xsl:value-of select="." /></issn>
	</xsl:template>

	<xsl:template match="v3:originInfo/v3:place/v3:placeTerm">
		<place_of_pub><xsl:value-of select="." /></place_of_pub>
	</xsl:template>
	
	<xsl:template match="v3:originInfo[local-name(..)='mods']/v3:publisher">
		<publisher><xsl:value-of select="." /></publisher>
	</xsl:template>

	<xsl:template match="v3:identifier[@type='isbn' and local-name(..)='mods'][1]">
		<isbn><xsl:value-of select="." /></isbn>
	</xsl:template>
	
	<xsl:template match="v3:identifier[@type='doi' and local-name(..)='mods']">
		<doi><xsl:value-of select="substring-after(.,'http://dx.doi.org/')"/></doi>
	</xsl:template>

	<!-- structured keywords matches to free keywords -->	
	<xsl:template match="v3:classification[1]">
		<keywords><xsl:value-of select="." /></keywords>		
	</xsl:template>
	
	<xsl:template match="v3:note">
		<xsl:choose>
			<xsl:when test="@type != ''" />
			<!-- We only want non-qualified notes -->
			<xsl:otherwise>
   				<note><xsl:value-of select="." /></note>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:template>
	
	<xsl:template match="v3:relatedItem[@type='host' and @xlin:role='conference']/v3:titleInfo/v3:title">
		<event_title><xsl:value-of select="." /></event_title>
	</xsl:template>

	<xsl:template match="v3:relatedItem[@type='host' and @xlin:role='conference']/v3:location/v3:physicalLocation">
		<event_location><xsl:value-of select="." /></event_location>
	</xsl:template>
	
	<xsl:template match="v3:relatedItem[@xlin:role='media']/v3:physicalDescription/v3:form">
		<output_media><xsl:value-of select="." /></output_media>
	</xsl:template>
	
	<!-- metadata visibility -->
	<xsl:template match="v3:note[@type='metadata visibility']">
		<xsl:choose>
			<xsl:when test=".='FREE'">
				<metadata_visibility>show</metadata_visibility>
			</xsl:when>
			<xsl:when test=".='CAMPUS'">
				<metadata_visibility>no_search</metadata_visibility>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Conference start/end -->
	<xsl:template match="v3:relatedItem[@type='host' and @xlin:role='conference']/v3:part">
		<xsl:choose>
			<xsl:when test="v3:date[@point='start'] and v3:date[@point='end']">
				<event_dates><xsl:value-of select="v3:date[@point='start']" /> - <xsl:value-of select="v3:date[@point='end']" /></event_dates>
			</xsl:when>
			<xsl:when test="v3:date[@point='start']">
				<event_dates><xsl:value-of select="v3:date[@point='start']" /></event_dates>
			</xsl:when>
			<xsl:when test="v3:date[@point='end']">
				<event_dates><xsl:value-of select="v3:date[@point='end']" /></event_dates>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="v3:genre[@type='publicationType']">
		<!-- Type token used for matching for sub types -->
		<xsl:variable name="typeToken">
				<xsl:call-template name="find-last-token">
					<xsl:with-param name="uri" select="." />
				</xsl:call-template>
		</xsl:variable>	
	
		<xsl:choose>
			
			<!-- Contribution to Book Anthology -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontobookanthology/')">
				<type>book_section</type>
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="bookTitleMatch"/>
			</xsl:when>
			
			<!-- Other contribution -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/othercontribution/')">
				<type>other</type>
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="journalMatch"/>
			</xsl:when>
			
			<!-- Contribution to Journal -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontojournal/')">
				<type>article</type>
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="journalMatch"/>
			</xsl:when>
			
			<!-- Contribution to Periodical -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontoperiodical/')">
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:choose>
					<xsl:when test="$typeToken = 'book'">
						<type>review</type>
						<xsl:call-template name="journalMatch"/>
					</xsl:when>
					<xsl:otherwise>
						<type>article</type>
						<xsl:call-template name="journalMatch"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- Non-textual -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/nontextual/')">
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
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
					
					<xsl:when test="$typeToken='digitalorvisualproducts'">
						<type>other</type>
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
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="monographType">
					<xsl:with-param name="uriToken" select="$typeToken" />
				</xsl:call-template>
			</xsl:when>
						
			<!-- Contribution to Conference -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/contributiontoconference/')">
				<type>conference_item</type>
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="conferenceItemType">
					<xsl:with-param name="uriToken" select="$typeToken" />
				</xsl:call-template>
			</xsl:when>

			<!-- Patent -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/patent/')">
				<type>patent</type>
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="patentType"/>
			</xsl:when>
					
			<!-- Book Anthology -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/bookanthology/')">
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:choose>
					<xsl:when test="$typeToken='OTHER' or $typeToken='commissioned'">
						<type>report</type>
						<xsl:call-template name="journalMatch"/>
					</xsl:when>
					<xsl:otherwise>
						<type>book</type>
						<xsl:call-template name="bookTitleMatch"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			
			<!-- Thesis -->
			<xsl:when test="starts-with(text(), '/dk/atira/pure/researchoutput/researchoutputtypes/thesis/')">
				<!-- Thesis -->
				<type>thesis</type>
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="thesisType">
					<xsl:with-param name="uriToken" select="$typeToken" />
				</xsl:call-template>
			</xsl:when>

			<!--
				Other types
			-->
			<xsl:otherwise>
				<type>other</type>
				<xsl:call-template name="titleMatch"/>
				<xsl:call-template name="hostVolumeNumberMatch"/>
				<xsl:call-template name="journalMatch"/>
			</xsl:otherwise>
		</xsl:choose>	

	</xsl:template>

	<!-- Title -->	
	<xsl:template name="titleMatch">
		<title>
			<xsl:call-template name="extractTitle"/>
		</title>
	</xsl:template>
	<xsl:template name="titleWithVolumeAndEditionMatch">
		<title>
        	<xsl:call-template name="extractTitleWithVolumeAndNumber"/>
		</title>
	</xsl:template>
	<xsl:template name="extractTitleWithVolumeAndNumber">
        <xsl:variable name="title"><xsl:call-template name="extractTitle"/></xsl:variable>
        <xsl:variable name="vol"><xsl:call-template name="extractHostVolume"/></xsl:variable>
        <xsl:variable name="ed"><xsl:call-template name="extractHostEdition"/></xsl:variable>
        <xsl:if test="string-length($title)">
      		<xsl:value-of select="$title" />
      		<xsl:if test="string-length($vol) or string-length($ed)">
	      		<xsl:if test="substring($title, string-length($title), 1) != '.'">. </xsl:if>
	      		<xsl:if test="string-length($vol)">Vol. <xsl:value-of select="$vol" />. </xsl:if>
	      		<xsl:if test="string-length($ed)"><xsl:value-of select="$ed" /> ed.</xsl:if>
      		</xsl:if>
        </xsl:if>
	</xsl:template>
	<xsl:template name="extractTitle">
		<xsl:value-of select="/v3:mods/v3:titleInfo/v3:title" />
		<xsl:if test="/v3:mods/v3:titleInfo/v3:subTitle">
	        <xsl:variable name="subtitle"><xsl:value-of select="/v3:mods/v3:titleInfo/v3:subTitle"/></xsl:variable>
			<xsl:if test="string-length($subtitle)">
				<xsl:text> : </xsl:text><xsl:value-of select="$subtitle"/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

	<!-- Volume, Number and Series info: Use either hostVolumeNumberMatch or seriesVolumeNumberMatch -->
	<xsl:template name="hostVolumeNumberMatch">
		<xsl:call-template name="seriesMatch"/>
        <xsl:variable name="vol"><xsl:call-template name="extractHostVolume"/></xsl:variable>
        <xsl:variable name="ed"><xsl:call-template name="extractHostEdition"/></xsl:variable>
		<xsl:if test="string-length($vol)">
			<volume><xsl:value-of select="$vol" /></volume>
		</xsl:if>
		<xsl:if test="string-length($ed)">
			<number><xsl:value-of select="$ed" /></number>
		</xsl:if>
	</xsl:template>
	<xsl:template name="seriesVolumeNumberMatch">
		<xsl:call-template name="seriesMatch"/>
        <xsl:variable name="vol"><xsl:call-template name="extractSeriesVolume"/></xsl:variable>
        <xsl:variable name="ed"><xsl:call-template name="extractSeriesEdition"/></xsl:variable>
		<xsl:if test="string-length($vol)">
			<volume><xsl:value-of select="$vol" /></volume>
		</xsl:if>
		<xsl:if test="string-length($ed)">
			<number><xsl:value-of select="$ed" /></number>
		</xsl:if>
	</xsl:template>

	<!-- Series -->
	<xsl:template name="seriesMatch">
        <xsl:variable name="series"><xsl:call-template name="extractSeries"/></xsl:variable>
		<xsl:if test="string-length($series)">
			<series><xsl:value-of select="$series" /></series>
		</xsl:if>
	</xsl:template>
	<xsl:template name="extractSeries">
		<xsl:if test="/v3:mods/v3:relatedItem[@type='series']/v3:titleInfo/v3:title">
			<xsl:value-of select="/v3:mods/v3:relatedItem[@type='series']/v3:titleInfo/v3:title" />
		</xsl:if>
	</xsl:template>

	<!-- Volume: Either use host or series volume match, not both! -->
	<xsl:template name="hostVolumeMatch">
        <xsl:variable name="vol"><xsl:call-template name="extractHostVolume"/></xsl:variable>
		<xsl:if test="string-length($vol)">
			<volume><xsl:value-of select="$vol" /></volume>
		</xsl:if>
	</xsl:template>
	<xsl:template name="extractHostVolume">
		<xsl:if test="/v3:mods/v3:relatedItem[@type='host']/v3:part/v3:detail[@type='volume']/v3:number or /v3:mods/v3:part[local-name(..)='mods']/v3:detail[@type='volume']/v3:number">
			<xsl:choose>
				<xsl:when test="/v3:mods/v3:relatedItem[@type='host']/v3:part/v3:detail[@type='volume']/v3:number">
					<xsl:value-of select="/v3:mods/v3:relatedItem[@type='host']/v3:part/v3:detail[@type='volume']/v3:number" />
				</xsl:when>
				<xsl:when test="/v3:mods/v3:part[local-name(..)='mods']/v3:detail[@type='volume']/v3:number">
					<xsl:value-of select="/v3:mods/v3:part[local-name(..)='mods']/v3:detail[@type='volume']/v3:number" />
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template name="seriesVolumeMatch">
        <xsl:variable name="vol"><xsl:call-template name="extractSeriesVolume"/></xsl:variable>
		<xsl:if test="string-length($vol)">
			<volume><xsl:value-of select="$vol" /></volume>
		</xsl:if>
	</xsl:template>
	<xsl:template name="extractSeriesVolume">
		<xsl:if test="/v3:mods/v3:relatedItem[@type='series']/v3:part/v3:detail[@type='volume']/v3:number">
			<xsl:value-of select="/v3:mods/v3:relatedItem[@type='series']/v3:part/v3:detail[@type='volume']/v3:number" />
		</xsl:if>
	</xsl:template>

	<!-- Edition: Either use host or series edition match, not both! -->	
	<xsl:template name="hostEditionMatch">
        <xsl:variable name="ed"><xsl:call-template name="extractHostEdition"/></xsl:variable>
		<xsl:if test="string-length($ed)">
			<number><xsl:value-of select="$ed" /></number>
		</xsl:if>
	</xsl:template>
	<xsl:template name="extractHostEdition">
		<xsl:if test="/v3:mods/v3:relatedItem[@type='host']/v3:part/v3:detail[@type='issue']/v3:number or /v3:mods/v3:part[local-name(..)='mods']/v3:detail[@type='edition']/v3:number">
			<xsl:choose>
				<xsl:when test="/v3:mods/v3:relatedItem[@type='host']/v3:part/v3:detail[@type='issue']/v3:number">
					<xsl:value-of select="/v3:mods/v3:relatedItem[@type='host']/v3:part/v3:detail[@type='issue']/v3:number" />
				</xsl:when>
				<xsl:when test="/v3:mods/v3:part[local-name(..)='mods']/v3:detail[@type='edition']/v3:number">
					<xsl:value-of select="/v3:mods/v3:part[local-name(..)='mods']/v3:detail[@type='edition']/v3:number" />
				</xsl:when>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	<xsl:template name="seriesEditionMatch">
        <xsl:variable name="ed"><xsl:call-template name="extractSeriesEdition"/></xsl:variable>
		<xsl:if test="string-length($ed)">
			<number><xsl:value-of select="$ed" /></number>
		</xsl:if>
	</xsl:template>
	<xsl:template name="extractSeriesEdition">
		<xsl:if test="/v3:mods/v3:relatedItem[@type='series']/v3:part/v3:detail[@type='issue']/v3:number">
			<xsl:value-of select="/v3:mods/v3:relatedItem[@type='series']/v3:part/v3:detail[@type='issue']/v3:number" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="journalMatch">
        <xsl:variable name="title"><xsl:call-template name="extractHostTitle"/></xsl:variable>
		<xsl:if test="string-length($title)">
			<publication>
				<xsl:value-of select="$title" />
			</publication>
		</xsl:if>
	</xsl:template>
	<xsl:template name="bookTitleMatch">
        <xsl:variable name="title"><xsl:call-template name="extractHostTitle"/></xsl:variable>
		<xsl:if test="string-length($title)">
			<book_title>
				<xsl:value-of select="$title" />
			</book_title>
		</xsl:if>
	</xsl:template>
	<xsl:template name="extractHostTitle">
		<xsl:value-of select="/v3:mods/v3:relatedItem[@type='host']/v3:titleInfo/v3:title" />
		<xsl:if test="/v3:mods/v3:relatedItem[@type='host']/v3:titleInfo/v3:subTitle"><xsl:text> : </xsl:text><xsl:value-of select="/v3:mods/v3:relatedItem[@type='host']/v3:titleInfo/v3:subTitle"/></xsl:if>
	</xsl:template>
	<xsl:template name="extractHostTitleWithVolumeAndNumber">
        <xsl:variable name="title"><xsl:call-template name="extractHostTitle"/></xsl:variable>
        <xsl:variable name="vol"><xsl:call-template name="extractHostVolume"/></xsl:variable>
        <xsl:variable name="ed"><xsl:call-template name="extractHostEdition"/></xsl:variable>
        <xsl:if test="string-length($title)">
      		<xsl:value-of select="$title" />
      		<xsl:if test="string-length($vol) or string-length($ed)">
	      		<xsl:if test="substring($title, string-length($title), 1) != '.'">.</xsl:if>
	      		<xsl:if test="string-length($vol)"> Vol. <xsl:value-of select="$vol" />. </xsl:if>
	      		<xsl:if test="string-length($ed)"> <xsl:value-of select="$ed" /> ed.</xsl:if>
      		</xsl:if>
        </xsl:if>
	</xsl:template>
	
	<xsl:template name="monographType">
        <xsl:param name="uriToken"/>
		<type>monograph</type>
		<xsl:choose>
			<xsl:when test="$uriToken='workingpaper'">
				<monograph_type>working_paper</monograph_type>
			</xsl:when>
			<xsl:when test="$uriToken='discussionpaper'">
				<monograph_type>discussion_paper</monograph_type>
			</xsl:when>
			<xsl:otherwise>
				<monograph_type>other</monograph_type>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="thesisType">
        <xsl:param name="uriToken"/>
        <!-- awarding institution -->
		<xsl:if test="../v3:note[@type='institution']">
			<institution><xsl:value-of select="../v3:note[@type='institution']" /></institution>
		</xsl:if>
		<!-- sub type -->
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
		<!-- Supervisors -->
		<xsl:if test="../v3:name[@type='personal' and @authority='pure/supervisor']"> 
			<advisors>
				<xsl:for-each select="../v3:name[@type='personal' and @authority='pure/supervisor']">
					<item>
						<name>
							<family><xsl:value-of select="v3:namePart[@type='family']"/></family>
							<given><xsl:value-of select="v3:namePart[@type='given']"/></given>
						</name>
					</item>
				</xsl:for-each>
			</advisors>
				</xsl:if>
		<xsl:call-template name="journalMatch"/>
	</xsl:template>

	<xsl:template name="conferenceItemType">
        <xsl:param name="uriToken"/>
        <xsl:choose>
			<xsl:when test="$uriToken='keynote'">
				<pres_type>keynote</pres_type>
			</xsl:when>
			<xsl:when test="$uriToken='paper' or $uriToken='proceeding'">
				<pres_type>paper</pres_type>
			</xsl:when>
			<xsl:when test="$uriToken='poster'">
				<pres_type>poster</pres_type>
			</xsl:when>
			<xsl:when test="$uriToken='speech'">
				<pres_type>speech</pres_type>
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
			<patent_applicant><xsl:value-of select="../v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role']='inventor']/v3:namePart[@type='family']" />,  <xsl:value-of select="../v3:name[@type='personal' and v3:role/v3:roleTerm[@authority='pure/role']='inventor']/v3:namePart[@type='given']" /></patent_applicant>
		</xsl:if>
		<xsl:choose>
			<xsl:when test="../v3:subject[@xlin:type='ipc']/v3:topic or ../v3:identifier[@type='patent_number']">
				<id_number>
					<xsl:choose>
						<xsl:when test="../v3:subject[@xlin:type='ipc']/v3:topic and ../v3:identifier[@type='patent_number']">
							<xsl:value-of select="../v3:subject[@xlin:type='ipc']/v3:topic" />-<xsl:value-of select="../v3:identifier[@type='patent_number']" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="../v3:subject[@xlin:type='ipc']/v3:topic" />
							<xsl:value-of select="../v3:identifier[@type='patent_number']" />
						</xsl:otherwise>
					</xsl:choose>
				</id_number>
			</xsl:when>
		</xsl:choose>
		<xsl:call-template name="journalMatch"/>
	</xsl:template>

	<xsl:template name="find-last-token">
		<xsl:param name="uri" />
		<xsl:choose>
			<xsl:when test="contains($uri,'/')">
				<xsl:call-template name="find-last-token">
					<xsl:with-param name="uri" select="substring-after($uri,'/')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="translate($uri, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>