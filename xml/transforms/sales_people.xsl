<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8"/>
  <xsl:key name="staff_by_id" match="staff" use="staff_id"/>
  <xsl:key name="customer_by_id" match="customer" use="customer_id"/>

  <xsl:template match="/">
    <html><head><title>Sales and People</title></head><body>
      <h1>Sales and People</h1>
      <table border="1"><tr><th>Sale</th><th>Date</th><th>Staff member</th><th>Customer</th></tr>
        <xsl:for-each select="badminton_retail_data/sales/sale">
          <xsl:sort select="sale_date"/>
          <tr>
            <td><xsl:value-of select="sale_id"/></td>
            <td><xsl:value-of select="sale_date"/></td>
            <td><xsl:value-of select="key('staff_by_id', staff_id)/staff_name"/></td>
            <td><xsl:value-of select="key('customer_by_id', customer_id)/customer_name"/></td>
          </tr>
        </xsl:for-each>
      </table>
    </body></html>
  </xsl:template>
</xsl:stylesheet>
