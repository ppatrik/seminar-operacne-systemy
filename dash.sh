#!/bin/dash
USERS=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)
echo '<!DOCTYPE html><html><head><meta charset="UTF-8"><title>USER ANALYSIS by Patrik Pekarcik</title></head><body>'
for USERNAME in $USERS
do
	echo '<hr>'
	MENOAPRIEZVISKO=$(getent passwd $USERNAME | cut -d: -f 5 | cut -d, -f 1)
	HOME=$(grep "/home" < /etc/passwd | grep $USERNAME: | cut -d: -f6)
	PUBLIC_HTML=0
	if [ -d "$HOME/public_html" ]; then
		PUBLIC_HTML=1
	fi
	BASH=$(grep "/home" < /etc/passwd | grep $USERNAME: | cut -d: -f7)
	LASTLOGIN=$(last $USERNAME | head -1 | awk '{ print $4 " " $5 " " $6 " " $7 }')
	VELKOST=$(du $BASH -h -c | tail -1 | awk '{ print $1 }')
	VELKOSTVLASTNIK=$(du -ch $(find / -user $USERNAME 2> /dev/null) -h -c 2> /dev/null | tail -1 | awk '{ print $1 }')

	echo -n '<h1>'
	echo -n $MENOAPRIEZVISKO
	printf ' [%s]' $USERNAME
	if [ $PUBLIC_HTML -eq 1 ]; then
		printf ' [<a href="~%s">web</a>]' $USERNAME
	fi
	echo '</h1>'

	echo '<b>Shell:</b> ' $BASH '<br>'
	echo '<b>Domovský priečinok:</b> ' $HOME '<br>'
	echo '<b>Posledný login:</b>' $LASTLOGIN '<br>'
	echo -n '<b>Adresár <code>public_html</code>:</b> '
	if [ $PUBLIC_HTML -eq 1 ]; then
		echo -n $HOME '/public_html'
	else
		echo -n '<i>neexistuje</i>'
	fi
	echo '<br>'
	echo '<b>Veľkosť priečinka:</b> ' $VELKOST '<br>'
	echo '<b>Veľkosť súborov, ktoré vlastní:</b> ' $VELKOSTVLASTNIK '<br>'
	echo '<h3>Rozdelenie súborov podľa prípon</h3><ul>'
	find $HOME -type f 2> /dev/null | awk -F"/" '{ print $NF }' | awk -F"." '{ if(NF==1){ print "-" } else { print $NF } }' | sort | uniq -c | sort -n | awk '{ print "<li><b>"; if($NF!="-") { print "." } print $2 ":</b> " $1 "</li>" }'
	echo '</ul>'
done
echo '</body></html>'

