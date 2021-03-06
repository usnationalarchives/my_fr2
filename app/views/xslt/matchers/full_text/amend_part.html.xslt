<?xml version="1.0" encoding="ISO-8859-1" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fr="http://federalregister.gov/functions" extension-element-prefixes="fr">

  <xsl:template match="AMDPAR">
    <span class="amend-part-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="amend-part unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#regtext-amendpart-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'Start Amendment Part'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>Start Amendment Part</xsl:text>
        </span>
      </span>
      <span class="unprinted-element-border"></span>
    </span>

    <p class="amendment-part">
      <xsl:attribute name="id">
        <xsl:call-template name="amdpar_paragraph_id" />
      </xsl:attribute>

      <xsl:apply-templates select="fr:amendment_part(child::node())"/>
    </p>

    <span class="amend-part-wrapper unprinted-element-wrapper">
      <span class="unprinted-element-border"></span>
      <span class="amend-part unprinted-element cj-fancy-tooltip document-markup">
        <xsl:attribute name="data-tooltip-template">
          <xsl:value-of select="'#regtext-amendpart-tooltip-template'" />
        </xsl:attribute>

        <xsl:attribute name="data-tooltip-doc-override">
          <xsl:value-of select="'tooltip-enhanced'" />
        </xsl:attribute>

        <xsl:attribute name="data-text">
          <xsl:value-of select="'End Amendment Part'" />
        </xsl:attribute>

        <span class="icon-fr2 icon-fr2-source_code"></span>
        <span class="text">
          <xsl:text>End Amendment Part</xsl:text>
        </span>
      </span>
      <span class="unprinted-element-border"></span>
    </span>
  </xsl:template>

</xsl:stylesheet>
