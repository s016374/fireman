# Welcome to BLMS
BLMS (bid level manage system), is a web-application that includes everything needed to
manage bid.

-----

## Requirements
* Install [Docker](https://docs.docker.com/) on your environment.
* And install [docker-compose](https://docs.docker.com/compose/install/).

## Getting Started
1. Launch applications:
  <pre style="background-color:#f6f8fa; padding:16px; overflow:auto; font-size:85%; line-height:1.45; border-radius:3px;">
    <code># docker-compose -f blms.yml up -d</code>
  </pre>
2. DB migration:
  <pre style="background-color:#f6f8fa; padding:16px; overflow:auto; font-size:85%; line-height:1.45; border-radius:3px;">
    <code># cp db_init.sql db_data</code>
    <code># docker-compose -f blms.yml exec db bash -c 'mysql -u root -p$MYSQL_ROOT_PASSWORD -Dblms < /var/lib/mysql/db_init.sql'</code>
  </pre>
3. Using a browser, go to http://localhost:40002/blms and get it.
