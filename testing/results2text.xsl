<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="text" indent="no"/>

  <xsl:template match="/testsuite">
    Testsuite: <xsl:value-of select="@name" />
    <xsl:text>
    Tests run: </xsl:text>
    <xsl:value-of select="@tests" />
    <xsl:text>, Failures: </xsl:text>
    <xsl:value-of select="@failures" />
    <xsl:text>, Errors: </xsl:text>
    <xsl:value-of select="@errors" />
    <xsl:text>, Time elapsed: </xsl:text>
    <xsl:value-of select="@time" />
    <xsl:text> sec</xsl:text>
    <xsl:apply-templates select="system-out" />
    <xsl:apply-templates select="system-err" />
    <xsl:text>
    --------- ----------- ---------
    </xsl:text>
    <xsl:apply-templates select="testcase" />
  </xsl:template>

  <xsl:template match="testcase">
    <xsl:text>
</xsl:text>
    <xsl:value-of select="@name" />
    <xsl:text> took </xsl:text>
    <xsl:value-of select="@time" />
	<xsl:choose>
		<xsl:when test="failure">
		    <xsl:text> [FAILURE] 
  </xsl:text>
	    	<xsl:value-of select="failure" />
		    <xsl:text> 
			</xsl:text>
		</xsl:when>
		<xsl:when test="error">
		    <xsl:text> [ERROR]
  </xsl:text>
	    	<xsl:value-of select="error" />
		    <xsl:text> 
			</xsl:text>
		</xsl:when>
		<xsl:otherwise>
		    <xsl:text> [PASSED] </xsl:text>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:template>

  <xsl:template match="system-out">
    <xsl:text>
    ------ Standard output ------
    </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="system-err">
    <xsl:text>
    ------ Error output ------
    </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

</xsl:stylesheet>
