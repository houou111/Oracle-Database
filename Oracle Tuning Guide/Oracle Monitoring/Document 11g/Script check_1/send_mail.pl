#!/usr/bin/perl -w
use Net::SMTP;
use MIME::Base64; 

$EMAIL_ORA="/export/home/oradb/hyper/scripts/email.ora";

$SENDER="oraclealert\@abr.com";
$TO_USER="oraclealert\@abr.com";
@CC_USER=("");
$CC_USER_FOR_VIEW="";

$user="oraclealert\@abr.com";
$passwd="Abcd@123";

sub send_email
{

my $ALARM=" ";
my $SUBJECT_MSG=" ";

        open (LOG_FILE,$EMAIL_ORA)||die("cannot open file $EMAIL_ORA!!!");
        my @lines=<LOG_FILE>;
        close(LOG_FILE);
        $max_row=$#lines;
        $i=0;

        while ($i <= $max_row)
        {
                chomp($lines[$i]);
                $ALARM=$ALARM.$lines[$i]."<br>";
                $i++;
        }
        

$smtp = Net::SMTP->new("10.1.244.54",
                    Hello => 'Test',
                    Timeout => 60);

my $subject =" ";
$subject="Canh bao STREAMS NSBR Basic";


my $MESSAGE_BODY = "<body><h2>CANH BAO TU HE THONG: </h2><font face='Arial' size='2'>$ALARM</font></body>";

$smtp->datasend("AUTH LOGIN\n");
 
$smtp->response();
$smtp->datasend(encode_base64($user) ); 
$smtp->response();
$smtp->datasend(encode_base64($passwd)); 
$smtp->response();

$smtp->mail($SENDER); 
$smtp->to($TO_USER);
$smtp->cc(@CC_USER);

$smtp->data();

$smtp->datasend("To: $TO_USER\n");
$smtp->datasend("From: $SENDER\n");
$smtp->datasend("CC: $CC_USER_FOR_VIEW\n");
$smtp->datasend("Content-Type: text/html;charset=utf-8\n"); 
$smtp->datasend("Subject: $subject\n");
$smtp->datasend("\n");
$smtp->datasend("$MESSAGE_BODY");
$smtp->datasend("\n");

$smtp->dataend(); 
$smtp->quit;
};

send_email