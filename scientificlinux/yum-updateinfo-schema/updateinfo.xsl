<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!--
     Written by Pat Riehecky <riehecky@fnal.gov> for Scientific Linux

     This program is free software; you can redistribute it and/or modify
     it under the terms of the GNU General Public License as published by
     the Free Software Foundation; either version 2 of the License, or
     (at your option) any later version.

     This program is distributed in the hope that it will be useful,
     but WITHOUT ANY WARRANTY; without even the implied warranty of
     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
     GNU General Public License for more details.

     You should have received a copy of the GNU General Public License
     along with this program; if not, write to the Free Software
     Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
-->

<xsl:output method="html" encoding="UTF-8" indent="yes" />

<!--
     Our keys for efficient lookups
-->
<xsl:key name="collection" match="/updates/update/pkglist/collection/name/text()" use="." />
<xsl:key name="idByPackage" match="update/id" use="../pkglist/collection/package/@name" />

<!--
     The full update list
-->
<xsl:template match="updates">
 <h3>Update Information</h3>
 <table width="100%">
  <tr>
   <th width="26px"> </th>
   <th>Update ID</th>
   <th>Title</th>
   <th width="15%">Released</th>
   <th width="15%">Severity</th>
  </tr>
  <xsl:apply-templates select="update">
   <xsl:sort select="issued/@date" data-type="text" order="descending"/>
  </xsl:apply-templates>
 </table>
</xsl:template>

<!--
     A single update
-->
<xsl:template match="update">
 <tr id="{id}">
  <xsl:choose>
   <xsl:when test="@type='security'">
    <td class='security_icon'> </td>
   </xsl:when>
   <xsl:when test="@type='enhancement'">
    <td class='enhancement_icon'> </td>
   </xsl:when>
   <xsl:when test="@type='bugfix'">
    <td class='bugfix_icon'> </td>
   </xsl:when>
   <xsl:when test="@type='newpackage'">
    <td class='newpackage_icon'> </td>
   </xsl:when>
  </xsl:choose>

  <td>
  <a name="#{id}" href="#{id}" onclick="toggledisplay('{id}-description');return false;">
  <xsl:value-of select="id" /></a></td>
  <td><xsl:value-of select="title" /></td>
  <td><xsl:value-of select="substring(issued/@date,0,11)" /></td>
  <td><xsl:value-of select="severity" /></td>
 </tr>

 <tr id="{id}-description" style="display:none">
  <td> </td>
  <td colspan="4">
   <br />
   <xsl:apply-templates select="references" />
   <b>From: </b><a href="mailto:{@from}?Subject={id} in {release}"><xsl:value-of select="@from" /></a>
   <br />
   <dt>Description:</dt>
   <dd><xsl:value-of select="description" /></dd>
   <br />
   <dt>Packages:</dt>
   <dd>
    <xsl:for-each select="pkglist">
     <xsl:apply-templates select="collection">
      <xsl:sort data-type="text" select="name" />
     </xsl:apply-templates>
    </xsl:for-each>
   </dd>
   <dt>All Related Updates:</dt>
   <dd>
     <xsl:apply-templates select="pkglist" />
   </dd>
  <hr />
  </td>
 </tr>
</xsl:template>

<!--
     List references
-->
<xsl:template match="references">
 <xsl:for-each select="reference">
  <xsl:sort data-type="text" select="@type" />
  <xsl:if test="@type = 'self'">
   <a href="{@href}" style="color:#0000FF;text-decoration:underline"><xsl:value-of select="@title" /></a>
   <br />
  </xsl:if>
 </xsl:for-each>
</xsl:template>

<!--
     We don't want the file path, so assemble the name here from parts.
-->
<xsl:template match="collection">
 <i><xsl:value-of select="name" /></i>
 <ul>
  <xsl:for-each select="package">
   <xsl:sort data-type="text" select="filename" />
   <li><xsl:value-of select="@name" />-<xsl:value-of select="@version" />-<xsl:value-of select="@release" />.<xsl:value-of select="@arch" />.rpm</li>
  </xsl:for-each>
 </ul>
</xsl:template>

<!--
     List out related updates
-->
<xsl:template match="pkglist">
  <ul>
  <xsl:for-each select="key('idByPackage', collection/package/@name)[. != current()/../id]">
    <xsl:sort select="../issued/@date" data-type="text" order="descending"/>
    <xsl:choose>
     <xsl:when test="../@type='security'">
      <li class="security_icon"><a href="#{.}"><xsl:value-of select="." /></a> - <xsl:value-of select="substring(../issued/@date,0,11)" /></li>
     </xsl:when>
     <xsl:when test="../@type='enhancement'">
      <li class="enhancement_icon"><a href="#{.}"><xsl:value-of select="." /></a> - <xsl:value-of select="substring(../issued/@date,0,11)" /></li>
     </xsl:when>
     <xsl:when test="../@type='bugfix'">
      <li class="bugfix_icon"><a href="#{.}"><xsl:value-of select="." /></a> - <xsl:value-of select="substring(../issued/@date,0,11)" /></li>
     </xsl:when>
     <xsl:when test="../@type='newpackage'">
      <li class="newpackage_icon"><a href="#{.}"><xsl:value-of select="." /></a> - <xsl:value-of select="substring(../issued/@date,0,11)" /></li>
     </xsl:when>
    </xsl:choose>
  </xsl:for-each>
  </ul>
</xsl:template>

<xsl:template match="/">
 <html>
  <head>
   <title>Update Information</title>
   <style type="text/css">
   .levbar {
       position: absolute;
       top: 0px;
       left: 0px;
       width: 11em;
       height: 100%;
       border-right: 4px dotted gray;
       border-bottom: 4px dotted gray;
       background-color: gainsboro;
   }
   .main {
       position: absolute;
       left: 13em;
       width: 75%;
   }
   .pagetitle {
       border-top: 1px dotted gray;
       border-bottom: 1px dotted gray;
       padding-top: 5%;
       padding-bottom: 5%;
       margin-top: 5%;
       margin-bottom: 5%;
       text-align: center;
       width: 100%;
       color: gray;
       background-color: white;
   }
   td.bugfix_icon {
       width: 24px;
       height: 24px;
       background-repeat: no-repeat;
       background-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAAN1gAADdYBkG95nAAAAAd0SU1FB9gDARAhLRjDw7EAAATtSURBVEjHzZZbbJRFFMd/M999d7vbrb1RaRBBEFGUWgQMUQyGGHzwhibqmhij0QcvUZ+8JMZEn4xGYzRqDNFYHyRqiMQbxngLwWgpxQhWULm1pdJl22339n3fzDc+gEYUBY0PTnJeJnP+Z87/zP+cgf/TGrhJvDFQ4LJ/4iNOGrzA5U627Z2kUS7qKJrT00flZPzkSYJnLMdZ1736KplbsCwnpHziX2UwUMAWQnwrLPldovQnwJfAoLDk0/mzlt0y88KlnlIWu9avi9V0aSUwBCwFllu2tUor/VVPH/f+LUWDN1tf589e0QsmrI7ul/FUEWHbYt7aW2xZHkSkOpiawOz/YL2SQdbxW2fUM13dTnnvbhoHf7q9p491v8ez/xggUXqT7Ypz288+x+PcM1GJT6ITwsk9BPUSpj5JtvMCMffa2x3Xt5BJNcDLU9o5oIAtf8Szj0Pb5unh/fe0zZ3lmLF+pJBI22fvaIW5bUdKZg5sxrV9iGtMaxevYwmqUgqPUnbCIm9pFA8GJrFBJxCHUC8jEkW5EoGKf9v7uVTj3W1T1MdHEJitPX2Yvw0wUKBFSPGMsKxENeoYJEbFGK3oTkV8tFNh4uiIacWGrZNcsWQGSdgAZO9AgdsGCsfWVf4OvCAsa0/z7AXXnbFqta3Le/lxZIqdo4rJimb3eMjbg1M8uKFItaFBa0g0bm2EXN7htJWrU35L+7NDk3z76TUsPOYVbbtJfCKDphXd5/fa6YxDUvoB4ioAkZF8ccDl1a+qVJXBcgKCqEgu7RLQ4IFVzbzSX6Epk6Eus3S5cXKWHjZGqUd6+nhcAhhjXjZhrTo5PByqSCOsNCiN0RrHsVh1uibvhkjbJ45CpkUTY1ETe6YcdgxX8aXg1ktms3JOE4tTtVgkuh948xgdDBRoFoInpZcudM6b72SbPaGLQwg/QFqSSkNz34ZJDussJokBg+WmsJC4SYX7lubi5z/bJ+rKbNpVFuuBN745YBriOG1hOUJunrOkV4iJIWTgIRwHlOKujZqfQ4tEK5ygCRKNQSBtH1M9HI6Ol17r38cdi7rFXGAt4B1PByXL9bRjarZWDXTV8OG+BuMVjYlijEoj3RQm0bh+DqVDSDSyqdVLhfKyzlyx+5sDZhfw+HF1oA0r/FQQUi9TaSS82B9xXpfLzb0B9y+zWNM1jRA2IFA6xA3yWE4KDORbW2fO7EivA4K/EpqQgpWpjJfSdoCTn80Ni9uTjJ1KhJXm4x9jhCVwohLS9iBJSOIGbuYULMdHGE17W8fyBTNZ/Wt9/0SRFFxUGp/SxYMlS+toeKJutuUDeYkzb1ZT4Hus7Wlhfr4WP7W9ZNxsq6vVEVU7fhatIjzP9tN+cCfUNwL6mACvr8GONC8cKla3P7+doff3AJB58uLk8kvdsUdDmXJGy/Da4ITYd8h83hyxuK29s0XHNbRqYNkuKqyQyeZmQd38KYMb30MBTwAu4AMpoHH/Z7z3dnP96kjLHj1e04eqZsuOER7LjJfyZ9RrD83o6DrH9VxXRzWk7aLjch2O9CXrLwaROWoJoAElYPP1c+JCJdRbXtrB6/kU2UPTfD02od4yamKratRakoR4ulIZqU4efnhsiu9PNEptwAPSQA5o2Xgld9y9mIVS0L7wVJ4DmoHM0WzdoxcW/8kPY1G3uHdRt+g80blfAJPBOwsT4IFGAAAAAElFTkSuQmCC);
   }
   li.bugfix_icon {
       list-style-image: url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAAN1gAADdYBkG95nAAAAAd0SU1FB9gDARAhLRjDw7EAAATtSURBVEjHzZZbbJRFFMd/M999d7vbrb1RaRBBEFGUWgQMUQyGGHzwhibqmhij0QcvUZ+8JMZEn4xGYzRqDNFYHyRqiMQbxngLwWgpxQhWULm1pdJl22339n3fzDc+gEYUBY0PTnJeJnP+Z87/zP+cgf/TGrhJvDFQ4LJ/4iNOGrzA5U627Z2kUS7qKJrT00flZPzkSYJnLMdZ1736KplbsCwnpHziX2UwUMAWQnwrLPldovQnwJfAoLDk0/mzlt0y88KlnlIWu9avi9V0aSUwBCwFllu2tUor/VVPH/f+LUWDN1tf589e0QsmrI7ul/FUEWHbYt7aW2xZHkSkOpiawOz/YL2SQdbxW2fUM13dTnnvbhoHf7q9p491v8ez/xggUXqT7Ypz288+x+PcM1GJT6ITwsk9BPUSpj5JtvMCMffa2x3Xt5BJNcDLU9o5oIAtf8Szj0Pb5unh/fe0zZ3lmLF+pJBI22fvaIW5bUdKZg5sxrV9iGtMaxevYwmqUgqPUnbCIm9pFA8GJrFBJxCHUC8jEkW5EoGKf9v7uVTj3W1T1MdHEJitPX2Yvw0wUKBFSPGMsKxENeoYJEbFGK3oTkV8tFNh4uiIacWGrZNcsWQGSdgAZO9AgdsGCsfWVf4OvCAsa0/z7AXXnbFqta3Le/lxZIqdo4rJimb3eMjbg1M8uKFItaFBa0g0bm2EXN7htJWrU35L+7NDk3z76TUsPOYVbbtJfCKDphXd5/fa6YxDUvoB4ioAkZF8ccDl1a+qVJXBcgKCqEgu7RLQ4IFVzbzSX6Epk6Eus3S5cXKWHjZGqUd6+nhcAhhjXjZhrTo5PByqSCOsNCiN0RrHsVh1uibvhkjbJ45CpkUTY1ETe6YcdgxX8aXg1ktms3JOE4tTtVgkuh948xgdDBRoFoInpZcudM6b72SbPaGLQwg/QFqSSkNz34ZJDussJokBg+WmsJC4SYX7lubi5z/bJ+rKbNpVFuuBN745YBriOG1hOUJunrOkV4iJIWTgIRwHlOKujZqfQ4tEK5ygCRKNQSBtH1M9HI6Ol17r38cdi7rFXGAt4B1PByXL9bRjarZWDXTV8OG+BuMVjYlijEoj3RQm0bh+DqVDSDSyqdVLhfKyzlyx+5sDZhfw+HF1oA0r/FQQUi9TaSS82B9xXpfLzb0B9y+zWNM1jRA2IFA6xA3yWE4KDORbW2fO7EivA4K/EpqQgpWpjJfSdoCTn80Ni9uTjJ1KhJXm4x9jhCVwohLS9iBJSOIGbuYULMdHGE17W8fyBTNZ/Wt9/0SRFFxUGp/SxYMlS+toeKJutuUDeYkzb1ZT4Hus7Wlhfr4WP7W9ZNxsq6vVEVU7fhatIjzP9tN+cCfUNwL6mACvr8GONC8cKla3P7+doff3AJB58uLk8kvdsUdDmXJGy/Da4ITYd8h83hyxuK29s0XHNbRqYNkuKqyQyeZmQd38KYMb30MBTwAu4AMpoHH/Z7z3dnP96kjLHj1e04eqZsuOER7LjJfyZ9RrD83o6DrH9VxXRzWk7aLjch2O9CXrLwaROWoJoAElYPP1c+JCJdRbXtrB6/kU2UPTfD02od4yamKratRakoR4ulIZqU4efnhsiu9PNEptwAPSQA5o2Xgld9y9mIVS0L7wVJ4DmoHM0WzdoxcW/8kPY1G3uHdRt+g80blfAJPBOwsT4IFGAAAAAElFTkSuQmCC);
   }
   td.enhancement_icon {
       width: 24px;
       height: 24px;
       background-repeat: no-repeat;
       background-image:url(data:image/png;base64,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);
   }
   li.enhancement_icon {
       list-style-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYEAYAAACw5+G7AAAABGdBTUEAALGPC/xhBQAAAAFzUkdCAK7OHOkAAAAgY0hSTQAAeiYAAICEAAD6AAAAgOgAAHUwAADqYAAAOpgAABdwnLpRPAAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAAN1gAADdYBkG95nAAAAAl2cEFnAAAAGAAAABgAeEylpgAABf9JREFUWMPdV81LVG0U/93n3jt3Zhx1NHU09VUwIkmI0EhJxHAp/QfSokW1iQiCoE24aFER1CKQCKFlEC1atGiREYj2IaaIGgVmfqSOM86Mzv2+z30X532YRp003lq87wE5c+99Ps7v9/zOOY/Af9zkP7Xw+fPXrrW3P3nS2trZWVe3tTU2Njy8uPjly+/eR/ozgff2BgLBIPD8uee5LrC+Tr6p6eHDW7dGR7e2ftd+7PcGHokwJsvA4OChQy0tZWWMxWINDUBpqSQxBty587sJK3gCFJCi0NPUFAU2M8O55wFDQ/R+dJT8x48U4L17sVhjI3DuXF3dwYP19ZrGue9zDkxNjY0tLTmObZsm0N1N82ZnyZ88Sb6jg/bp6aF93r2jE7ty5ZcBCLt48fr19vb376urGxuBtjZ6a1mZTCIBMGaaug4AjDEGSNLRo8eP19Qoimlalq4DiqKqgQBgWZZlmr7/+fPk5Oam69JbVS0qikYBwygujkZlWVWTyZUVzwO2tlIp4MIFAjA4WCg+ZS8AxMTLl7KsKLJ87FhFxYEDsZimxWJVVb4PeB4x7PvkXZfUvt1HIuFwSYkktbS0tQWDqsoYcU0WCsmyLMsysLr67dvSkuvS+5GRveLbEwDZ8HAqFY973uXL0Wg06jiqquu6/mMqSpIkSRIB8f2dK2QyxOnOcfQcDgeDRUUAScyy8iX2rwGMjOh6JgOEQgBtyznnnO9v9s8sEAgEAgFA1w0jR8jYGElnNyryrWAfoCQuL6fkvH+fDrylpby8slLTGPM8koZIUt+nP85JdEJSgPhGjIuQxG/GKHscx3FsG0inEwnOKytbW0+dqquLx6mPjI9TH9kZp7R74H19FPiDB+Xl1dWAplVWxmIlJZomNG3bti0OejcTUhFWSFpiXDAYDIZCgOu6rusCy8tzc4ZhWVQkJieJjrNn6WRy0pLyAx8aUlVNAzo7a2ubmgIBRdE0TdM0wDAMQ9eJ8d0CYSw/4L1spwRpvqoqiqrmpJVOp9Obm563tjY/T/M8D7hxg4DcvLmtkT165LqOA2SzmczGhm1blmBEkuioOXddkgwFsD3wQgDFW9d1HM8jpn0/58UIISnTtCzTBFKp1VXAdenrhw+02tOne0goGqWnu3cVJRAA+vqqqurrAVUNBkOhYFCSdF3XTZPqPGM5IIUACOCc01fPcxwAoOIJhMORSDAIbGysr5umbafT8ThgWcT4pUvE+OPHe+bA7oA6OuhpePivv44ckWVJMoxs1vMAakgAY4rCWO5kcszTkwjctg0jJxggFCouZgwwjM1NzoFEYnkZmJig2T09FHgiUSi+fd6FkklZVhTA83KM0m+qHfnSIobzv7suedG+qEiQpDins83tFw7Pzr59C6RSXV3d3e3thbNrnwA6O+l2aVlCw0IouwsGcBzTJCDUVQWw7akuxgkpEbCmpoqK2lqgtPSfMFkhIAUB5E/o7ta0cBgIhxmTZUkCAoFQKHcSnFuWYQCci++CYcG4ptF4w9jcpKQkQIJ5USTopC0rEikrA9rbaX9x6dgJYJ+duKuLLgKel8kkEr4vyxT44qLjWBYwPk7l9/Tpysr6et8vLqbkzyX5xsbKCue2nUqtrQGfPtG6uk7zmptlWVE4j0ToRDWNiqkA8OrVLwOor29uBhSFmBoY2Nra2AAmJlZX5+eB2VliUlgkUlXV0AD09hKD/f01NU1NjKmq45gm50A2m04Dtj0/Pz0N9PdTTsTjAggxHomUlVVXA4cPk6SoUuX6904rCGBhYWYGELdC8Y8IsQqIhAuHyZsmNZoXL0pKysuBM2dSqdVVzk+coBuO71N1uX2bAl9ZoXmilxsGEbS+Tn56WgAj/+OlJN8K5sCbN69f5y5TYgHBCCUekM2Sz2TIp1Lfv8/NAVevkuRcl9rR8HA8vrAAPHtG49bXySeTYh55cZ0TgVPl+hmAPf+pn5//+nVx0fcbGhob6+rEW7GgKKvipGybqkoySZJYXEwmV1aAgQHTzGaBtbX8AAUB1BtyxAiixPq+n0/o/8j+BpDn1Lo80cC4AAAAAElFTkSuQmCC);
   }
   td.newpackage_icon {
       width: 24px;
       height: 24px;
       background-repeat: no-repeat;
       background-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9kEAg0QNMXC/LsAAAJPSURBVEjHzZVBTxNBFMd/O9sWLJZiaKGGJmgWEnY5oNmESMKBmx74CpxM8DN44+bdGx716NWDfgNjQpQDYKJEjNKWYJqWTduV7sx46La0WOMW08R32pl58//P/72378GQzQDQWg8H3DAQw1YQ+9PBk405F9gE3L9g7ADPHr/4vBM5RCH49vqD+27mZh6Ar5/2uH3vLgBf3r5ndn4RgB/F77x6/WYHeHSZpG+I2uBrqyvuZCaDbvqUC0cY6SRCJBAigZFOUi4coZs+k5kMa6srLrAd3u2xfjnYcpcW3Hwui/Q9pO9xfFIiN2shzFGEOUpu1uL4pNQ5z+eyuEsLLrAVJQfr0zM2hXKdes3Dq1UpFQtMnxapnBY7TkffCvgBpMbSJMdSTM/YsPtxPVKSx/Mz5LrWex/eEUuYPT5z1jyLd5Y76/qgVYQKuhckxpKXHUIfIwy2ORiBlOcY4WWlFLHReC+8kkjZDEtRg0gOqCDw0RigQRGAKXoqQiEhaKAwEGiID0ggg3PQYQSUJKhWqVQ8JiZSVCoeKNnyAeRV/mQlm7QYWlY+LFH1zlCpGlXvLEzTeesB+ioEyg+/TOZv5UHAVHYcgKnsjZaP/gnyQuhABFq2hUt+j4OM3Ow6eXNsy3BsK/2v3dOxrUnHtkQ/BTHgohav5yNCKkDQqDfaG/HuiPV0U8e2RjaW409RweZVXu83ef5yVz/cPzgM2t20b7t2bCsOXANSQBIYCRWaXc8OgAbgATXAbwN3t+vII9OxrY7s/YPDSDN2IIL/diYP3X4BlTXiyCzUaVYAAAAASUVORK5CYII=);
   }
   li.newpackage_icon {
       list-style-image:url(data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABgAAAAYCAYAAADgdz34AAAAAXNSR0IArs4c6QAAAAZiS0dEAP8A/wD/oL2nkwAAAAlwSFlzAAALEwAACxMBAJqcGAAAAAd0SU1FB9kEAg0QNMXC/LsAAAJPSURBVEjHzZVBTxNBFMd/O9sWLJZiaKGGJmgWEnY5oNmESMKBmx74CpxM8DN44+bdGx716NWDfgNjQpQDYKJEjNKWYJqWTduV7sx46La0WOMW08R32pl58//P/72378GQzQDQWg8H3DAQw1YQ+9PBk405F9gE3L9g7ADPHr/4vBM5RCH49vqD+27mZh6Ar5/2uH3vLgBf3r5ndn4RgB/F77x6/WYHeHSZpG+I2uBrqyvuZCaDbvqUC0cY6SRCJBAigZFOUi4coZs+k5kMa6srLrAd3u2xfjnYcpcW3Hwui/Q9pO9xfFIiN2shzFGEOUpu1uL4pNQ5z+eyuEsLLrAVJQfr0zM2hXKdes3Dq1UpFQtMnxapnBY7TkffCvgBpMbSJMdSTM/YsPtxPVKSx/Mz5LrWex/eEUuYPT5z1jyLd5Y76/qgVYQKuhckxpKXHUIfIwy2ORiBlOcY4WWlFLHReC+8kkjZDEtRg0gOqCDw0RigQRGAKXoqQiEhaKAwEGiID0ggg3PQYQSUJKhWqVQ8JiZSVCoeKNnyAeRV/mQlm7QYWlY+LFH1zlCpGlXvLEzTeesB+ioEyg+/TOZv5UHAVHYcgKnsjZaP/gnyQuhABFq2hUt+j4OM3Ow6eXNsy3BsK/2v3dOxrUnHtkQ/BTHgohav5yNCKkDQqDfaG/HuiPV0U8e2RjaW409RweZVXu83ef5yVz/cPzgM2t20b7t2bCsOXANSQBIYCRWaXc8OgAbgATXAbwN3t+vII9OxrY7s/YPDSDN2IIL/diYP3X4BlTXiyCzUaVYAAAAASUVORK5CYII=);
   }
   td.security_icon {
       width: 24px;
       height: 24px;
       background-repeat: no-repeat;
       background-image:url(data:image/png;base64,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);
   }
   li.security_icon {
       list-style-image:url(data:image/png;base64,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);
   }
   h1,h2,h3,h4,h5 {
       border-bottom: 1px dotted gray;
       border-top: 1px dotted gray;
       background-color: whitesmoke;
       font-weight: normal;
   }
   dt {
       font-weight: bold;
       margin-top: 1%;
   }
   th {
       background-color: whitesmoke;
       text-align: left;
   }
   tr:nth-child(4n+0) {
       background: whitesmoke;
   }
   a {
       color:#000000;
       text-decoration:none;
   }
   a:hover {
       text-decoration:underline;
   }
   </style>
   <script type="text/javascript">
    function toggledisplay(id){
      if (document.getElementById(id).style.display == "none") {
         document.getElementById(id).style.display = "";
      } else {
         document.getElementById(id).style.display = "none";
      }
    }
   </script>
  </head>
  <body>
  <div class="levbar">
   <p class="pagetitle">Updates for:<br />
    <!--
       print unique collection names
    -->
    <xsl:for-each select="/updates/update/pkglist/collection/name/text()[generate-id()=generate-id(key('collection',.)[1])]">
     <xsl:value-of select="."/><br />
    </xsl:for-each>
   </p>
  </div>
  <div class="main">
   <xsl:apply-templates select="updates" />
  </div>

  </body>
 </html>
</xsl:template>

</xsl:stylesheet>
