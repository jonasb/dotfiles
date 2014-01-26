use strict;
use Irssi;
use vars qw($VERSION %IRSSI);
$VERSION = "0.1";
%IRSSI = (
  authors     => 'Jonas Bengtsson',
  contact     => 'jonas.b@gmail.com',
  name        => 'pushbullet.pl',
  description => 'Uses PushBullet to notify user of hilights and private messages',
);

sub notify {
  my ($server, $title, $body) = @_;
  $server->command("EXEC - pushbullet.sh '$title' '$body'");
}

sub print_text {
    my ($dest, $text, $stripped) = @_;
    my $server = $dest->{server};
    return if (!$server || !($dest->{level} & MSGLEVEL_HILIGHT));

    my $sender = $stripped;
    $sender =~ s/^\<.([^\>]+)\>.+/\1/ ;
    $stripped =~ s/^\<.[^\>]+\>.// ;
    my $summary = $dest->{target} . ": " . $sender;
    notify($server, $summary, $stripped);
}

sub message_private {
  my ($server, $msg, $nick, $address) = @_;
  return if (!$server);

  notify($server, $nick, $msg);
}

Irssi::signal_add_last('print text', 'print_text');
Irssi::signal_add_last('message private', 'message_private');
