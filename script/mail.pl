# File: mail.pl
#   Mail a file to a list of recipients. It includes the file contents in the
#   email body, and also attaches the file to the email.
#
# Use: perl mail.pl "<subject>" <filepath> <email1,email2,...> (<from>)
#

# =============================================================================
use MIME::Lite;
use strict;

# Required arguments and message of misuse.
unless ($#ARGV == 2 || $#ARGV == 3) { # unless 3|4 args
	print "\nUsage: perl mail.pl \"<subject>\" <filepath> <email1,email2,...> (<from>)\n\n";
	print "\nFirst arg is quoted subject.";
	print "\n\nSecond arg is path to TEXT file to email to list of addresses.";
	print "\n\nThird arg is comma-separated list of recipient email addresses.";
	print "\n\tDo NOT use spaces between addresses.";
	print "\n\n(Optional) Fourth arg is sender address.";
	print "\n\tSender will be username executing this script if left unspecified";
	print "\n\n";
	exit 1;
}

# Grab command line args.
my $subject = shift;
my $path = shift;
my $to = shift;
my $from;

# Shifting @ARGV changes its size.
# If there is an argument left, it is the from address.
if ($#ARGV == 0) { # if 1 arg
	$from = shift;
}
else {
	$from = `whoami`;
}

# -----------------------------------------------------------------------------
# Read information from file specified by <filepath>
my $content;
open(my $file, "<", $path) or die "Cannot open < $path: $!";
while (<$file>) {
	$content .= $_;
}

# Add visual separation between inline content and attached file
$content .= "\n\n\n########################################" .
	"\n    Attachment of above information" .
	"\n########################################\n";

close($file) or die "Cannot close $file: $!";

# -----------------------------------------------------------------------------
# Create and prepare email object
my $msg = MIME::Lite->new(
	From    => $from,
	To      => $to,
	Subject => $subject,
	Type    => 'multipart/mixed'
);

# Insert (attach) contents of text file into body of email
# Disposition defaults to 'inline'
$msg->attach(
	Type    => 'TEXT',
	Data    => $content
);

# Attach text file to email
$msg->attach(
	Type        => 'TEXT',
	Path        => $path,
	Disposition => 'attachment'
);

# Send via default mailer
$msg->send;

# =============================================================================

