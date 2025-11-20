
function sql() {
  local HO=$(echo "$NOMAD_ADDR_db" | cut -f1 -d:)
  local PO=$(echo "$NOMAD_ADDR_db" | cut -f2 -d:)

  [ "$#" = 0 ] && \
    mysql -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -h$HO -P$PO  $WORDPRESS_DB_NAME

	[ "$#" = 0 ] || echo "$@" | \
    mysql -u$WORDPRESS_DB_USER -p$WORDPRESS_DB_PASSWORD -h$HO -P$PO  $WORDPRESS_DB_NAME
}

function lt() {
	/bin/ls -A -F -l -tr "$@"
}

function lh() {
	/bin/ls -FAltrh "$@"
}

function line () {
	perl -e 'print "_"x80; print "\n\n";'
}


alias  grep=" grep --color"
alias egrep="egrep --color"
alias fgrep="fgrep --color"
