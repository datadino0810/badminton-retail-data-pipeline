<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8"/>
  <xsl:key name="product_by_code" match="product" use="product_code"/>
  <xsl:key name="supplier_by_id" match="supplier" use="supplier_id"/>

  <xsl:template match="/">
    <html><head><title>Supplier Restock List</title></head><body>
      <h1>Supplier Restock List</h1>
      <table border="1"><tr><th>Supplier</th><th>Product</th><th>Quantity</th><th>Reorder level</th></tr>
        <xsl:for-each select="badminton_retail_data/inventory_records/inventory[quantity_on_hand &lt;= reorder_level]">
          <xsl:variable name="product" select="key('product_by_code', product_code)"/>
          <tr>
            <td><xsl:value-of select="key('supplier_by_id', $product/supplier_id)/supplier_name"/></td>
            <td><xsl:value-of select="$product/product_name"/></td>
            <td><xsl:value-of select="quantity_on_hand"/></td>
            <td><xsl:value-of select="reorder_level"/></td>
          </tr>
        </xsl:for-each>
      </table>
    </body></html>
  </xsl:template>
</xsl:stylesheet>
