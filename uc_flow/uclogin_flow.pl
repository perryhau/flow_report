#!/usr/bin/env perl
use strict;
use lib "./";
use html;
use Fatal qw(open close);

my $mod = 'uclogin';
my $lh_str = '*-dr-ucweb-*';
my $monitor = 'uclogin_apache_flow';
my $beg_t = `date --date='1 days ago' +%Y%m%d000000`;
my $end_t = `date +%Y%m%d000000`;
my $save_file = `date +%Y%m%d_$mod`;

#邮件相关变量
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
#my @to = ('zengfuwei@baidu.com');
my $from = 'sf-op@baidu.com';
my @mail_group = ('sf-op@baidu.com','druc-rd@baidu.com','druc-qa@baidu.com');
#my @mail_group = ('zengfuwei@baidu.com');
my $subject    = `date --date='1 days ago' +[$mod][流量统计][%Y%m%d]`;

#my @mach = `lh -h $lh_str -m tc -m jx -x jx-dr-ucweb07.jx -x jx-dr-ucweb06.jx -x tc-dr-ucweb06.tc`;
my @mach = `lh -h $lh_str`;
my ( %today_flow,%yes_flow,%week_flow );
@mach = grep { s/\n$// }
        grep { !/result/ } @mach;
my $mach = join ',' , @mach;
chomp ( $beg_t,$end_t,$subject,$save_file );


system "date +%Y%m%d";
unlink $save_file if -e $save_file;
unlink "mail.txt" if -e "mail.txt";
get_today_flow();
get_yes_flow();
get_week_flow();

while (my ($k,$v ) = each %today_flow){
     system "echo $k\t$v >> $save_file";
}

email_content();
send_mail();
print "\n";

sub get_today_flow{
    QUERY:
    my $res = system "./noahquery -l 60 -t machine -h $mach -i $monitor -s $beg_t -e $end_t -T 60";
    print "**fail**\n" and sleep 60 and goto QUERY if $res ne '0';
    for ( @mach ) {
         my $flow = `awk -v sum=0 '/[0-9]/{sum += \$3};END{printf sum}' "./noah_data/$_"`;
         $today_flow{$_} = $flow;
         if ( /^(\w+?)\-/ ) {
              $today_flow{$1} += $flow;
              $today_flow{'all'} += $flow;
         }
    }
}

sub get_yes_flow {
    my $file = `date --date='1 days ago' +%Y%m%d_$mod`;
    chomp $file;
    print "file:$file\n";
    open my $fh, '<' , $file;
    while ( <$fh> ) {
        $yes_flow{$1} = $2 if /(\S+)\s+(\d+)/;
    }
    close $fh;
}

sub get_week_flow{
    my $file = `date --date='7 days ago' +%Y%m%d_$mod`;
    chomp $file;
    open my $fh, '<' , $file;
    while ( <$fh> ) {
        $week_flow{$1} = $2 if /(\S+)\s+(\d+)/;
    }
    close $fh;
}

sub email_content{
    open my $fh, '>>' , "mail.txt";
    print $fh "$head $css \n";
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
    open RM, '<', "mail.txt";
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
