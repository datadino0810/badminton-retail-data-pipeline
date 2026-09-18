<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8"/>
  <xsl:key name="product_by_code" match="product" use="product_code"/>

  <xsl:template match="/">
    <html><head><title>Out of Stock Products</title></head><body>
      <h1>Out of Stock Products</h1>
      <table border="1"><tr><th>Product code</th><th>Product</th><th>Location</th></tr>
        <xsl:for-each select="badminton_retail_data/inventory_records/inventory[quantity_on_hand = 0]">
          <tr>
            <td><xsl:value-of select="product_code"/></td>
            <td><xsl:value-of select="key('product_by_code', product_code)/product_name"/></td>
            <td><xsl:value-of select="location_id"/></td>
          </tr>
        </xsl:for-each>
      </table>
    </body></html>
  </xsl:template>
</xsl:stylesheet>
