<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8"/>
  <xsl:key name="product_by_code" match="product" use="product_code"/>

  <xsl:template match="/">
    <html><head><title>Low Stock Products</title></head><body>
      <h1>Low Stock Products</h1>
      <table border="1"><tr><th>Product</th><th>Location</th><th>Quantity</th><th>Reorder level</th></tr>
        <xsl:for-each select="badminton_retail_data/inventory_records/inventory[quantity_on_hand &lt; reorder_level]">
          <xsl:sort select="quantity_on_hand" data-type="number"/>
          <tr>
            <td><xsl:value-of select="key('product_by_code', product_code)/product_name"/></td>
            <td><xsl:value-of select="location_id"/></td>
            <td><xsl:value-of select="quantity_on_hand"/></td>
            <td><xsl:value-of select="reorder_level"/></td>
          </tr>
        </xsl:for-each>
      </table>
    </body></html>
  </xsl:template>
</xsl:stylesheet>
