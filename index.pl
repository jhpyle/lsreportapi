#!/usr/bin/perl
use strict;
use Carp;
use warnings;
use CGI qw/:standard/;
use JSON;
my $basepath = '/bin:/usr/bin:/usr/local/bin';
$ENV{'PATH'} = $basepath;
chdir('/tmp');

my $q = CGI->new();

print $q->header(-type => 'application/json', -expires => 'now');
my $site     = $q->param('s') // undef;
my $user     = $q->param('u') // undef;
my $password = $q->param('p') // undef;
my $report   = $q->param('r') // undef;
unless (defined($site) && defined($user) && defined($password) && defined($report)){
  print "{'result': 'argument(s) missing'}";
  exit;
}
my $pid = open(CASPER, "| casperjs /opt/lsreportapi/ls-report-api.js");
unless ($pid){
  print "{'result': 'failed'}";
  exit;
}
print CASPER encode_json(["https://" . $site . ".legalserver.org", $user, $password, $report]);
close CASPER;
my $the_pid = waitpid($pid, 0);
if ($the_pid >= 0){
  my $exitcode = $? >> 8;
  print STDERR "$the_pid exited with $?\n";
}
exit;
