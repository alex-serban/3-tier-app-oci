#!/bin/sh

echo Content-type: text/html
echo

echo "<html>"
echo "<head><title>Application</title></head>"
echo "<body>"

echo "<p>This application is running on <b><u>"`hostname`"</u></b>!</p>"

sqlplus64 -s ADMIN/ORACLEoracle_123@AUTDB_high <<!
        SET MARKUP HTML ON
        SET FEEDBACK OFF
        SELECT PROD_NAME, PROD_DESC
        FROM SH.PRODUCTS
        ORDER BY PROD_NAME;

        QUIT
!

echo "</body></html>"
