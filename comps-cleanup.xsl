<?xml version="1.0" encoding="UTF-8"?>
<!-- This stylesheet will:
     - reorder and indent a comps file,
     - merge duplicate groups and categories,
     - warn about packages referenced multiple times,
     - keep a single package reference per group,

     Typical usage is:
     $ xsltproc -o output-file comps-cleanup.xsl original-file

     You can use the "novalid" xsltproc switch to kill the warning about
     Fedora not installing the comps DTD anywhere xsltproc can find it.
     However without DTD there is no way to check the files completely.

     © Nicolas Mailhot <nim at fedoraproject dot org> 2006 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes" encoding="UTF-8" doctype-system="comps.dtd" doctype-public="-//Red Hat, Inc.//DTD Comps info//EN"/>
  <xsl:key name="unique-groups" match="/comps/group" use="id/text()"/>
  <xsl:key name="unique-categories" match="/comps/category" use="id/text()"/>
  <xsl:key name="packages-by-group" match="/comps/group/packagelist/packagereq" use="../../id/text()"/>
  <xsl:key name="unique-packages" match="/comps/group/packagelist/packagereq" use="text()"/>
  <xsl:key name="unique-package-entries" match="/comps/group/packagelist/packagereq" use="concat(../../id/text(),'/',text())"/>
  <xsl:key name="groups-by-category" match="/comps/category/grouplist/groupid" use="../../id/text()"/>
  <xsl:key name="unique-group-entries" match="/comps/category/grouplist/groupid" use="concat(../../id/text(),'/',text())"/>
  <xsl:variable name="lcletters">abcdefghijklmnopqrstuvwxyz</xsl:variable>
  <xsl:variable name="ucletters">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
<!-- Preserve most nodes -->
  <xsl:template match="*" priority="0">
<!-- Group comments with the logically-following element -->
    <xsl:apply-templates select="preceding-sibling::node()[normalize-space()][1][self::comment()] "/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|text()"/>
    </xsl:copy>
  </xsl:template>
<!-- Preserve attributes and text nodes -->
  <xsl:template match="comment()|text()">
    <xsl:apply-templates select="preceding-sibling::node()[normalize-space()][1][self::comment()] "/>
    <xsl:copy/>
  </xsl:template>
<!-- Preserve attributes -->
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
<!-- Sort groups by id -->
  <xsl:template match="comps" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="group">
        <xsl:sort select="translate(id/text(),$lcletters,$ucletters)"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="category">
        <xsl:sort select="display_order/text()"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
<!-- Warn about duplicate groups being merged -->
  <xsl:template match="group[generate-id(.) != generate-id(key('unique-groups',id/text())[1])]" priority="2">
    <xsl:message> ☹☹ Duplicate group <xsl:value-of select="concat(_name/text(),' (',id/text(),')')"/> will be merged.</xsl:message>
  </xsl:template>
<!-- Warn about duplicate categories being merged -->
  <xsl:template match="category[generate-id(.) != generate-id(key('unique-categories',id/text())[1])]" priority="2">
    <xsl:message> ☹☹ Duplicate category <xsl:value-of select="concat(_name/text(),' (',id/text(),')')"/> will be merged.</xsl:message>
  </xsl:template>
<!-- Sort packages within a group by class then name -->
  <xsl:template match="packagelist" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="key('packages-by-group',../id/text())[@type = 'mandatory']">
        <xsl:sort select="translate(text(),$lcletters,$ucletters)"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="key('packages-by-group',../id/text())[@type = 'conditional']">
        <xsl:sort select="translate(text(),$lcletters,$ucletters)"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="key('packages-by-group',../id/text())[@type = 'default']">
        <xsl:sort select="translate(text(),$lcletters,$ucletters)"/>
      </xsl:apply-templates>
      <xsl:apply-templates select="key('packages-by-group',../id/text())[@type = 'optional']">
        <xsl:sort select="translate(text(),$lcletters,$ucletters)"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
<!-- Sort groups within a category by name -->
  <xsl:template match="category/grouplist" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="key('groups-by-category',../id/text())">
        <xsl:sort select="translate(text(),$lcletters,$ucletters)"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
<!-- Kill duplicate package entries -->
  <xsl:template match="packagereq[generate-id(.) != generate-id(key('unique-package-entries',concat(../../id/text(),'/',text()))[1])]" priority="2">
    <xsl:message>☹☹☹ Ignoring duplicate reference to <xsl:value-of select="concat(@type,' package ',text())"/> in group <xsl:value-of select="concat(../../_name/text(),' (',../../id/text(),')')"/>.</xsl:message>
    <xsl:message>  Only its first reference (<xsl:value-of select="key('unique-package-entries',concat(../../id/text(),'/',text()))[1]/@type"/> package) will be kept.</xsl:message>
  </xsl:template>
<!-- Kill duplicate group entries -->
  <xsl:template match="category/grouplist/groupid[generate-id(.) != generate-id(key('unique-group-entries',concat(../../id/text(),'/',text()))[1])]" priority="1">
    <xsl:message>  ☹ Ignoring duplicate reference to group <xsl:value-of select="text()"/> in category <xsl:value-of select="concat(../../_name/text(),' (',../../id/text(),')')"/>.</xsl:message>
  </xsl:template>
<!-- Warn about packages referenced several times (at least twice;)) -->
  <xsl:template match="packagereq[generate-id(.) = generate-id(key('unique-packages',text())[2])]" priority="1">
    <xsl:variable name="dupes" select="key('unique-packages',text())"/>
    <xsl:message>  ☹ Package <xsl:value-of select="text()"/> is referenced by <xsl:value-of select="count($dupes)"/> groups:</xsl:message>
    <xsl:for-each select="$dupes">
      <xsl:sort select="translate(../../id/text(),$lcletters,$ucletters)"/>
      <xsl:message>     ✓ <xsl:value-of select="@type"/> package in group <xsl:value-of select="concat(../../_name/text(),' (',../../id/text(),')')"/></xsl:message>
    </xsl:for-each>
    <xsl:apply-templates select="preceding-sibling::node()[normalize-space()][1][self::comment()] "/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="*|text()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
