<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output method="html" encoding="UTF-8" indent="yes" doctype-public="-//W3C//DTD HTML 4.01//EN" doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>

	<xsl:template match="/">
        <html>
            <head>
                <meta http-equiv="Content-Language" content="cs"/>
                <meta http-equiv="Cache-Control" content="no-cache"/>
                <meta http-equiv="Pragma" content="no-cache"/>
                <meta name="description" content=""/>
                <meta name="keywords" content=""/>
				<link rel="stylesheet" type="text/css" href="mystyle.css"/>
				<title>Kontakty</title>
            </head>
            <body>
                <div class="jumbotron">
                    <h1>Kontakty</h1>
                </div>
                <div class="container">
                    <table>
			<thead><h3>Zoznam kontaktov</h3></thead>
                        <xsl:for-each select="people/person">
				<xsl:sort select="lastname" lang="sk"/>
				<tr>
					<td>
						<span style="font-size: 25px;">
							<xsl:value-of select="lastname"/>&#xA0;<xsl:value-of select="firstname"/>
						</span>
						<div>
							<table class="table">
								<xsl:apply-templates select="*"/>
							</table>
						</div>
					</td>
				</tr>
			</xsl:for-each>
                    </table>
                </div>
            </body>
        </html>
    </xsl:template>
	
	<xsl:template match="email">
		<tr>
			<td>Email&#xA0;<xsl:value-of select="@type"/></td>
			<td>
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:text>mailto:</xsl:text>
						<xsl:value-of select="text()" />     
					</xsl:attribute>
					<xsl:value-of select="text()" />
				</xsl:element>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="phone">
		<tr>
			<td>Telefón&#xA0;<xsl:value-of select="@type"/></td>
			<td><xsl:value-of select="text()"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="link">
		<tr>
			<td>Webová adresa&#xA0;<xsl:value-of select="@type"/></td>
			<td>
				<xsl:element name="a">
					<xsl:attribute name="href">
						<xsl:value-of select="text()"/>
					</xsl:attribute>
					<xsl:value-of select="text()"/>
				</xsl:element>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="other">
		<tr>
			<td><xsl:value-of select="service"/></td>
			<td><xsl:value-of select="id"/></td>
		</tr>
	</xsl:template>
	
	<xsl:template match="address">
		<tr>
			<td>Adresa</td>
			<td>
				<xsl:value-of select="street"/>&#xA0;<xsl:value-of select="number"/>,&#xA0;<xsl:value-of select="postCode"/>&#xA0;<xsl:value-of select="city"/>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="note">
		<tr>
			<td>Poznámka</td>
			<td>
				<xsl:call-template name="LFsToBRs">
					<xsl:with-param name="input" select="text()"/>
				</xsl:call-template>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:template match="firstname"/>
	<xsl:template match="lastname"/>
	
	<xsl:template name="LFsToBRs">
		<xsl:param name="input"/>
		<xsl:choose>
			<xsl:when test="contains($input, '&#10;')">
				<xsl:value-of select="substring-before($input, '&#10;')" /><br />
				<xsl:call-template name="LFsToBRs">
					<xsl:with-param name="input" select="substring-after($input, '&#10;')" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:transform>
