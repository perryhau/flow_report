#!/usr/bin/env perl
use strict;
use lib "./";
use html;
use Fatal qw(open close);
use POSIX qw(strftime);

my $mod = 'ucsec';
my @mod = qw(idps_api uc-secure secure-svc Fdy token-svc token-web uclog);
my @mod_date = qw(%Y%m%d_idps_api %Y%m%d_uc-secure %Y%m%d_secure-svc 
                  %Y%m%d_Fdy %Y%m%d_token-svc %Y%m%d_token-web %Y%m%d_uclog);
my $save_file = `date +%Y%m%d_$mod`;

#邮件相关变量
my $from = 'sf-op@baidu.com';
#my @to = ('zengfuwei@baidu.com','zengfuwei@baidu.com');
my @to = ('zengfuwei@baidu.com',
          'youshengtao@baidu.com',
          'pengxiaobo01@baidu.com',
          'tangxiaoxi@baidu.com',
          'zhangdongdong01@baidu.com',
          'tiantian01@baidu.com',
          'liupeng04@baidu.com',
          'chenyi02@baidu.com',
          'chen_yong@baidu.com',
          'lihaotao@baidu.com',
          'sunhaitao@baidu.com',
          'huangxiaoting@baidu.com',
       );
#my @mail_group = ('zengfuwei@baidu.com');
my @mail_group = ('sf-op@baidu.com','druc-qa@baidu.com','druc-rd@baidu.com');
my $subject    = `date --date='1 days ago' +[$mod][流量统计][%Y%m%d]`;
my $mail_file = "${mod}_mail";

my ( %today_flow,%yes_flow,%week_flow );
chomp $save_file;
unlink $save_file if -e $save_file;
unlink $mail_file if -e $mail_file;

system "date +%Y%m%d";
system "perl idps_api_flow.pl";
sleep 60;
system "perl uc-secure_flow.pl";
sleep 60;
system "perl secure-svc_flow.pl";
sleep 60;
system "perl Fdy_flow.pl";
sleep 60;
system "perl token-svc_flow.pl";
sleep 60;
system "perl token-web_flow.pl";
sleep 60;
system "perl uclog_flow.pl";
sleep 60;

get_today_flow();
get_yes_flow();
get_week_flow();
while (my ($k,$v ) = each %week_flow){
    print "$k => $v\n";
    system "echo $k\t$v >> $save_file";
}
email_content();
com_flow();
send_mail();

sub get_today_flow{
         my @today_file = @mod_date;
         map { $_ = strftime $_,localtime(time) } @today_file;
         for my $f ( @today_file ) {
             open my $fh, '<' , $f;
             while ( <$fh> ) {
                  chomp;
                  $today_flow{$1} += $2 if /(\S+)\s+(\S+)/;
             }
             close $fh;
         }
}

sub get_yes_flow {
         my @yes_file = @mod_date;
         map { $_ = strftime $_,localtime(time - 86400) } @yes_file;
         for my $f ( @yes_file ) {
             open my $fh, '<' , $f;
             while ( <$fh> ) {
                  chomp;
                  $yes_flow{$1} += $2 if /(\S+)\s+(\S+)/;
             }
             close $fh;
         }
}

sub get_week_flow{
         my @week_file = @mod_date;
         map { $_ = strftime $_,localtime(time - 7*86400) } @week_file;
         for my $f ( @week_file ) {
             open my $fh, '<' , $f;
             while ( <$fh> ) {
                  chomp;
                  $week_flow{$1} += $2 if /(\S+)\s+(\S+)/;
             }
             close $fh;
         }
}

sub email_content{
    open my $fh, '>>' , $mail_file;
    print $fh "$head $css \n";
    print $fh "<h2>${mod}流量统计</h2>\n";
    idc_report($fh);
    mach_report($fh);
    print $fh "$end\n";
    close $fh;
}

sub idc_report{
        my $fh = shift;
        print $fh "$idc_table_head\n";
        while ( my ( $k, $v ) = each %today_flow ) {
              if ( $k =~ /^[^-|(all)]+$/ ) {
                   my $week_rate = decimal_format(eval{ ($v - $week_flow{$k})/$week_flow{$k} * 100 });
                   my $yes_rate = decimal_format(eval{ ($v - $yes_flow{$k})/$yes_flow{$k} * 100 });
                   ( $week_flow{$k}, $yes_flow{$k}, $v ) = std_num( $week_flow{$k}, $yes_flow{$k}, $v );
                   my $week_col = $week_rate !~ /\-/ ? 'red' : 'green';
                   my $yes_col = $yes_rate !~ /\-/ ? 'red' : 'green';
                   print $fh "<tr><td class='bold'>$k <td>$v
                                  <td>$week_flow{$k} <td class=$week_col>$week_rate
                                  <td>$yes_flow{$k} <td class=$yes_col>$yes_rate\n";
              }
        }
        my $all_week_rate = decimal_format(eval{ ($today_flow{'all'} - $week_flow{'all'})/$week_flow{'all'} * 100 });
        my $all_yes_rate = decimal_format(eval{ ($today_flow{'all'} - $yes_flow{'all'})/$yes_flow{'all'} * 100 });
        ( $week_flow{'all'}, $yes_flow{'all'}, $today_flow{'all'} ) = std_num( $week_flow{'all'}, $yes_flow{'all'}, $today_flow{'all'} );
        my $all_week_col = $all_week_rate !~ /\-/ ? 'red' : 'green';
        my $all_yes_col = $all_yes_rate !~ /\-/ ? 'red' : 'green';
        print $fh "<tr><td class='bold'>all <td>$today_flow{'all'}
                                  <td>$week_flow{'all'} <td class=$all_week_col>$all_week_rate
                                  <td>$yes_flow{'all'} <td class=$all_yes_col>$all_yes_rate\n";
        print $fh "$table_end\n";
}

sub mach_report{
        my $fh = shift;
        print $fh "$mach_table_head\n";
        while ( my ( $k, $v ) = each %today_flow ) {
              if ( $k !~ /^[\w-]+$/ ) {
                   my $week_rate = decimal_format(eval{ ($v - $week_flow{$k})/$week_flow{$k} * 100 });
                   my $yes_rate = decimal_format(eval{ ($v - $yes_flow{$k})/$yes_flow{$k} * 100 });
                   my $week_col = $week_rate !~ /\-/ ? 'red' : 'green';
                   my $yes_col = $yes_rate !~ /\-/ ? 'red' : 'green';
                   ( $week_flow{$k}, $yes_flow{$k}, $v ) = std_num( $week_flow{$k}, $yes_flow{$k}, $v );
                   print $fh "<tr><td class='bold'>$k <td>$v 
                                  <td>$week_flow{$k} <td class=$week_col>$week_rate
                                  <td>$yes_flow{$k} <td class=$yes_col>$yes_rate\n";
              }
        }
        print $fh "$table_end\n";
}

sub send_mail {
    open RM, '<', $mail_file;
    my @mail_msg = <RM>;
    my $type     = "text/html";
    open( MAIL, '|/usr/lib/sendmail -t' );
    select(MAIL);
    print <<"MAIL_EOF";
Content-Type: $type
to:@to
from:$from
cc:@mail_group
subject:$subject
@mail_msg
MAIL_EOF
    close MAIL;
    print "send mail success!" if $? eq '0';
    select STDOUT;
}

sub decimal_format{
    my $decimal = shift;
    $decimal = sprintf("%.2f\%",$decimal);
}

sub std_num{
    my @num = @_;
    s/(?<=\d)(?=(?:\d{3})+$)/,/g for @num;
    return @num;
}

sub com_flow{
    my @cas_mail = @mod;
    map { $_ = $_."_mail" } @cas_mail;
    open my $all_fh, '>>' , $mail_file;
    for my $f ( @cas_mail ) {
        open my $fh, '<' , $f;
        while ( <$fh> ) {
            print $all_fh $_;
        }
        close $fh;
    }
    close $all_fh;
}
