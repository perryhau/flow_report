package html;
use strict;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw($css $head $idc_table_head $mach_table_head $table_end $end);

our $head=<<"HEAD_EOF";
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML xmlns="http://www.w3.org/1999/xhtml">
<HEAD>
<META http-equiv=Content-Type content="text/html; charset=gbk">
HEAD_EOF

our $css=<<"CSS_EOF";
<STYLE type=text/css>
*     { FONT-SIZE: 14px; 
        FONT-FAMILY: ??ì?  
}
H2    { FONT-SIZE: 20px; 
        TEXT-ALIGN: center;
        COLOR: #FF0000;
}
BODY  { FONT-SIZE: 12px 
}
TABLE { MARGIN: 0px auto; 
        BORDER-COLLAPSE: collapse; 
        TEXT-ALIGN: center;
}
TD {
        BORDER-RIGHT: #888 1px solid; 
        PADDING-RIGHT: 4px; 
        BORDER-TOP: #888 1px solid; 
        PADDING-LEFT: 4px; PADDING-BOTTOM: 1px; 
        BORDER-LEFT: #888 1px solid; PADDING-TOP: 1px; 
        BORDER-BOTTOM: #888 1px solid;
        height:25; 
}
TR.header { 
        COLOR:#FFFFFF;
        BACKGROUND-COLOR:#000000;
        font-weight:bold;
}
TR.label {
        #BACKGROUND-COLOR: #00b0f0;
        font-weight:bold;
}
TR.label2 {
        #BACKGROUND-COLOR: #93cddd;
}
.red {color: #FF0000}
.green {color: #00FF00}
.bold {font-weight:bold}
</STYLE>
CSS_EOF

our $idc_table_head =<<"TAB_HEAD";
<div>
   <TABLE width="1045" border=1>
         <TBODY>
		    <tr class=header>
		      <td colspan=6>总访问量
			<tr class="label"> 
		      <td rowspan=2>机房
			  <td>今天
			  <td colspan="2">上周同期
			  <td colspan="2">昨天
			<tr class="label2">
			  <td>访问量
			  <td>访问量
			  <td>增长率
			  <td>访问量
			  <td>增长率
TAB_HEAD


our $mach_table_head =<<"TAB_HEAD";
<div>
   <TABLE width="1045" border=1>
         <TBODY>
		    <tr class=header>
		      <td colspan=6>各服务器访问量
			<tr class="label"> 
		      <td rowspan=2>机器
			  <td>今天
			  <td colspan="2">上周同期
			  <td colspan="2">昨天
			<tr class="label2">
			  <td>访问量
			  <td>访问量
			  <td>增长率
			  <td>访问量
			  <td>增长率
TAB_HEAD

our $table_end = "</TBODY></TABLE><br></div>";
our $end = "</BODY></HEAD></HTML>";
