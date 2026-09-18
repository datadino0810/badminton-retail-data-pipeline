<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8"/>
  <xsl:key name="products_by_category" match="product" use="category_id"/>

  <xsl:template match="/">
    <html><head><title>Products by Category</title></head><body>
      <h1>Products by Category</h1>
      <table border="1"><tr><th>Category</th><th>Product count</th></tr>
        <xsl:for-each select="badminton_retail_data/categories/category">
          <tr>
            <td><xsl:value-of select="category_name"/></td>
            <td><xsl:value-of select="count(key('products_by_category', category_id))"/></td>
          </tr>
        </xsl:for-each>
      </table>
    </body></html>
  </xsl:template>
</xsl:stylesheet>
