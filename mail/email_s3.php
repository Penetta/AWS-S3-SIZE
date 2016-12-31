#!/usr/bin/php

<?php

//header("Content-Type: text/html;  charset=ISO-8859-1",true);

// Pega os valores do FORMULARIO	

$smtp     = explode(":",$argv[1]); // Smtp destinatário + Porta
$smtp_name= $smtp[0]; // Smtp destinatário 
$smtp_port= $smtp[1]; // Smtp Porta 

$remetente= $argv[2]; // Usuário conta SMTP
$senha    = $argv[3]; // Senha SMTP

$destinatario = $argv[4]; // Destinatario
$assunto      = $argv[5]; // Assunto Email
$mensagem     = $argv[6]; // Corpo Email (html)
//$cc_email   = $argv[7]; // Com Cópia


// Include da Class Enviar Email.
include('km_smtp_class.php');

/* $mail = new KM_Mailer(server, port, username, password, secure); */
/* secure can be: null, tls or ssl */

$mail = new KM_Mailer("$smtp_name", "$smtp_port", "$remetente", "$senha", "tls");

if($mail->isLogin) {

	/* codificacao html*/
	//$mail->contentType = "text/plain";
	$mail->contentType = "text/html";

	/* add CC recipient */
	//$mail->addCC("CC Recipient <$email>");

	/* add BCC recipient */
	//$mail->addBCC('CC Recipient <epgoncalves@saraiva.com.br>');
	//$mail->addBCC('CC Recipient <eduardo@cisiti.com.br>');

	/* add attachment */
	//$mail->addAttachment'pathToFileToAttach');

	/* $mail->send(from, to, subject, body, headers = optional) */
	$mail->send("CSC - Tecnogera [STATUS] <$remetente>", "$destinatario", "$assunto", mb_convert_encoding("$mensagem","ISO-8859-1", "UTF-8") );

	/* clear recipients and attachments */
	$mail->clearRecipients();
	$mail->clearCC();
	$mail->clearBCC();
	$mail->clearAttachments();

	echo "Enviado com sucesso! | Send email success!" ; 
	
} else {

	echo "Login failed <br>";
}


?>
