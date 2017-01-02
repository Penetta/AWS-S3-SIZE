#!/bin/bash

remetente="EMAIL_SENDING"
smtp="smtp.zoho.com:587"

usuario="LOGIN_YOUR_EMAIL" 
senha="PASSWORD_YOUR_EMAIL" 
assunto="SUBJECT_EMAIL"
destinatario="EMAIL_DESTINATION"

NAME_BUCK="NAME_YOUR_BUCKET"

NAME_BUCK="tcngfiles"

CMD_TOTAL_COPIA=$(/usr/bin/s3cmd du -H s3://$NAME_BUCK | cut -d " " -f1)
CMD_TOTAL_FILE=$(/usr/bin/s3cmd ls s3://$NAME_BUCK --recursive  | wc -l)

TOTAL_DADOS=1024  ##### MUDAR AQUI PORRAAA

TOTAL_PERC=$(echo $CMD_TOTAL_COPIA | sed 's/G//g' | sed -e 's/^[ \t]*//')
CALCU_PERC=$(echo $TOTAL_PERC/$TOTAL_DADOS*100 | bc -l | cut -d "." -f1)

DATA=`date +%d-%m-%Y`
HORA=`date +%H:%M`

FILE_LOG="/tmp/log_tecnogera.log"

echo -e $DATA $HORA '\t' $CMD_TOTAL_COPIA '\t\t' $CMD_TOTAL_FILE >> $FILE_LOG

READ_LOG_ANT_SIZE=$(cat $FILE_LOG | tail -n 2 | cut -d " " -f4 | head -1)
READ_LOG_ANT_FILE=$(cat $FILE_LOG | tail -n 2 | cut -d " " -f6 | head -1)

READ_LOG_ULT_SIZE=$(cat $FILE_LOG | tail -n 1 | cut -d " " -f4)
READ_LOG_ULT_FILE=$(cat $FILE_LOG | tail -n 1 | cut -d " " -f6)

### CALC SPEED AVG COPY
N_LINE=$( cat $FILE_LOG | wc -l )
TOTAL_COPY=$( echo $READ_LOG_ULT_SIZE | sed 's/G//' )
MEDIA=$( echo "scale=2; $TOTAL_COPY/$N_LINE" | bc -l  )


HTML1=""

if [[ "$READ_LOG_ANT_SIZE" = "$READ_LOG_ULT_SIZE" || "$READ_LOG_ANT_FILE" = "$READ_LOG_ULT_FILE" ]]; then
   HTML1="
<tr>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:10px;'><img src='http://zabbix.cscm3.com.br/alerta/cinza_verm.gif' width='23' height='22' /></td>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:3px;padding-left:3px; font-family:Verdana, Geneva, sans-serif; font-size:14px;'><b>PROBLEMA: Valor da última cópia está igual a essa!</b></td>
</tr>
"
#else
#   HTMPL1= COPIA OK
fi


HTML="
<meta http-equiv='Content-Type' content='text/html; charset=iso-8859-1'>
<title>CSC - AWS</title>
</head>

<body>
<table width='555' border='0' cellspacing='0' cellpadding='0'>
  <tr>
    <td colspan='2'><img src='http://zabbix.cscm3.com.br/alerta/cabecalho1.jpg' width='555' height='49'></td>
  </tr>

<tr>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:10px;'><img src='http://zabbix.cscm3.com.br/alerta/S3.png' width='23' height='22' /></td>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:3px;padding-left:3px; font-family:Verdana, Geneva, sans-serif; font-size:14px;'>Volume de dados copiados: $CMD_TOTAL_COPIA (Aprox. $CALCU_PERC%)</td>
</tr>
<tr>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:10px;'><img src='http://zabbix.cscm3.com.br/alerta/FILE-S3.PNG' width='23' height='22' /></td>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:3px;padding-left:3px; font-family:Verdana, Geneva, sans-serif; font-size:14px;'>Total de arquivos copiados: $CMD_TOTAL_FILE</td>
</tr>
<tr>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:10px;'><img src='http://zabbix.cscm3.com.br/alerta/MEDIA.PNG' width='23' height='22' /></td>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:3px;padding-left:3px; font-family:Verdana, Geneva, sans-serif; font-size:14px;'>Velocidade Média da Cópia: $MEDIA Gb / Hora</td>
</tr>
$HTML1
<tr>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:10px;'><img src='http://zabbix.cscm3.com.br/alerta/DATE.png' width='23' height='22' /></td>
    <td height='40' style='background-image:url(http://zabbix.cscm3.com.br/alerta/bg.jpg); background-repeat:no-repeat;  padding-left:3px;padding-left:3px; font-family:Verdana, Geneva, sans-serif; font-size:14px;'><b>Atualizado: $HORA, $DATA by Penetta</b></td>
</tr>
</table>
</body>
</html>

"

#echo $HTML
mail/email_s3.php "$smtp" "$remetente" "$senha" "$destinatario" "$assunto" "$HTML"

