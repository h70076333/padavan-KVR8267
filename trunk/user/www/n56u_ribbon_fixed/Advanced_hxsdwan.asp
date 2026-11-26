<!DOCTYPE html>
<html>
<head>
<title><#Web_Title#> - HXSDWAN智能组网</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="Expires" content="-1">

<link rel="shortcut icon" href="images/favicon.ico">
<link rel="icon" href="images/favicon.png">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/bootstrap.min.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/main.css">
<link rel="stylesheet" type="text/css" href="/bootstrap/css/engage.itoggle.css">

<script type="text/javascript" src="/jquery.js"></script>
<script type="text/javascript" src="/bootstrap/js/bootstrap.min.js"></script>
<script type="text/javascript" src="/bootstrap/js/engage.itoggle.min.js"></script>
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" src="/client_function.js"></script>
<script type="text/javascript" src="/itoggle.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script>
var $j = jQuery.noConflict();
<% hxwan_status(); %>
<% login_state_hook(); %>
$j(document).ready(function() {
	init_itoggle('hxwan_enable');
	init_itoggle('hxwan_ipv6_enable');
	init_itoggle('hxwan_log');
	init_itoggle('hxwan_proxy');
	init_itoggle('hxwan_first');
	init_itoggle('hxwan_finger');
	init_itoggle('hxwan_serverw');
	$j("#tab_hxwan_cfg, #tab_hxwan_sta, #tab_hxwan_log").click(
	function () {
		var newHash = $j(this).attr('href').toLowerCase();
		showTab(newHash);
		return false;
	});

});

</script>
<script>

var m_routelist = [<% get_nvram_list("HXSDWAN", "HXSDWANLrout"); %>];
var mroutelist_ifield = 4;
if(m_routelist.length > 0){
	var m_routelist_ifield = m_routelist[0].length;
	for (var i = 0; i < m_routelist.length; i++) {
		m_routelist[i][mroutelist_ifield] = i;
	}
}

var isMenuopen = 0;
function initial(){
	show_banner(2);
	show_menu(5, 17, 0);
	showROUListi();
	fill_status(hxwan_status());
	show_footer();

}

function fill_status(status_code){
	var stext = "Unknown";
	if (status_code == 0)
		stext = "<#Stopped#>";
	else if (status_code == 1)
		stext = "<#Running#>";
	$("hxwan_status").innerHTML = '<span class="label label-' + (status_code != 0 ? 'success' : 'warning') + '">' + stext + '</span>';
}

var arrHashes = ["cfg","sta","log"];
function showTab(curHash) {
	var obj = $('tab_hxwan_' + curHash.slice(1));
	if (obj == null || obj.style.display == 'none')
	curHash = '#cfg';
	for (var i = 0; i < arrHashes.length; i++) {
		if (curHash == ('#' + arrHashes[i])) {
			$j('#tab_hxwan_' + arrHashes[i]).parents('li').addClass('active');
			$j('#wnd_hxwan_' + arrHashes[i]).show();
		} else {
			$j('#wnd_hxwan_' + arrHashes[i]).hide();
			$j('#tab_hxwan_' + arrHashes[i]).parents('li').removeClass('active');
			}
		}
	window.location.hash = curHash;
}

function applyRule(){
	showLoading();
	
	document.form.action_mode.value = " Apply ";
	document.form.current_page.value = "/Advanced_hxsdwan.asp";
	document.form.next_page.value = "";
	
	document.form.submit();
}

function done_validating(action){
	refreshpage();
}

function textarea_scripts_enabled(v){
    	inputCtrl(document.form['scripts.hxwan.conf'], v);
}

function change_hxwan_model(mflag){
	var m = document.form.hxwan_model.value;
	var Showmodel = (m >= 1 && m <= 7);


	showhide_div("hxwan_key_tr", Showmodel);
	showhide_div("hxwan_key_td", Showmodel);
}

function change_hxwan_enable(mflag){
	var m = document.form.hxwan_enable.value;
	var is_hxwan_enable = (m == "1" || m == "2") ? "重启" : "更新";
	document.form.restarthxwan.value = is_hxwan_enable;

		if(m == "2"){
		showhide_div("hxwan_file_tr", 1);
		showhide_div("hxwan_token_tr", 0);
		showhide_div("hxwan_token_td", 0);
		showhide_div("hxwan_ip_tr", 0);
	
		showhide_div("hxwan_mapping_table", 0);
	} 
	
	if(m == "1"){	
		showhide_div("hxwan_file_tr", 0);
		showhide_div("hxwan_token_tr", 1);
		showhide_div("hxwan_token_td", 1);
		showhide_div("hxwan_ip_tr", 1);
	
		showhide_div("hxwan_mapping_table", 1);
		o_mtu = document.form.hxwan_mtu;
		
		if (o_mtu && parseInt(o_mtu.value) == 0)
			o_mtu.value = "";
			
		if (o_mtu && parseInt(o_mtu.value) > 1500)
			o_mru.value = "1500";
	}
	
}

function button_restarthxwan() {
    var m = document.form.hxwan_enable.value;

    var actionMode = (m == "1" || m == "2") ? ' Restarthxwan ' : ' Updatehxwan ';

    change_hxwan_enable(m); 

    var $j = jQuery.noConflict(); 
    $j.post('/apply.cgi', {
        'action_mode': actionMode 
    });
}

function markrouteRULES(o, c, b) {
	document.form.group_id.value = "HXSDWANLrout";
	if(b == " Add "){
		if (document.form.hxwan_routenum_x_0.value >= c){
			alert("<#JS_itemlimit1#> " + c + " <#JS_itemlimit2#>");
			return false;
		}else if (document.form.hxwan_route_x_0.value==""){
			alert("<#JS_fieldblank#>");
			document.form.hxwan_route_x_0.focus();
			document.form.hxwan_route_x_0.select();
			return false;
		}else if(document.form.hxwan_ip_x_0.value==""){
			alert("<#JS_fieldblank#>");
			document.form.hxwan_ip_x_0.focus();
			document.form.hxwan_ip_x_0.select();
			return false;
		}else{
			for(i=0; i<m_routelist.length; i++){
				if(document.form.hxwan_route_x_0.value==m_routelist[i][1]) {
				if(document.form.hxwan_ip_x_0.value==m_routelist[i][2]) {
					alert('<#JS_duplicate#>' + ' (' + m_routelist[i][1] + ')' );
					document.form.hxwan_route_x_0.focus();
					document.form.hxwan_ip_x_0.select();
					return false;
					}
				}
			}
		}
	}
	pageChanged = 0;
	document.form.action_mode.value = b;
	return true;
}

function showROUListi(){
	var code = '<table width="100%" cellspacing="0" cellpadding="4" class="table table-list">';
	if(m_routelist.length == 0)
		code +='<tr><td colspan="5" style="text-align: center;"><div class="alert alert-info"><#IPConnection_VSList_Norule#></div></td></tr>';
	else{
	    for(var i = 0; i < m_routelist.length; i++){
		code +='<tr id="rowrl' + i + '">';
		code +='<td width="28%">&nbsp;' + m_routelist[i][0] + '</td>';
		code +='<td width="38%">&nbsp;' + m_routelist[i][1] + '</td>';
		code +='<td colspan="2" width="40%">' + m_routelist[i][2] + '</td>';
		code +='<td width="50%"></td>';
		code +='<center><td width="20%" style="text-align: center;"><input type="checkbox" name="HXSDWANLrout_s" value="' + m_routelist[i][mroutelist_ifield] + '" onClick="changeBgColorrl(this,' + i + ');" id="check' + m_routelist[i][mroutelist_ifield] + '"></td></center>';
		
		code +='</tr>';
	    }
		code += '<tr>';
		code += '<td colspan="5">&nbsp;</td>'
		code += '<td><button class="btn btn-danger" type="submit" onclick="markrouteRULES(this, 64, \' Del \');" name="HXSDWANLrout"><i class="icon icon-minus icon-white"></i></button></td>';
		code += '</tr>'
	}
	code +='</table>';
	$("MrouteRULESList_Block").innerHTML = code;
}

function clearLog(){
	var $j = jQuery.noConflict();
	$j.post('/apply.cgi', {
		'action_mode': ' ClearhxwanLog ',
		'next_host': 'Advanced_hxsdwan.asp#log'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_hxwan_info(){
	var $j = jQuery.noConflict();
	$j('#btn_info').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDsdinfo ',
		'next_host': 'Advanced_hxsdwan.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_hxwan_all(){
	var $j = jQuery.noConflict();
	$j('#btn_all').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDsdall ',
		'next_host': 'Advanced_hxsdwan.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_hxwan_list(){
	var $j = jQuery.noConflict();
	$j('#btn_list').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDsdlist ',
		'next_host': 'Advanced_hxsdwan.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

function button_hxwan_route(){
	var $j = jQuery.noConflict();
	$j('#btn_route').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDsdroute ',
		'next_host': 'Advanced_hxsdwan.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}


function button_hxwan_status() {
	var $j = jQuery.noConflict();
	$j('#btn_status').attr('disabled', 'disabled');
	$j.post('/apply.cgi', {
		'action_mode': ' CMDsdstatus ',
		'next_host': 'Advanced_hxsdwan.asp#sta'
	}).always(function() {
		setTimeout(function() {
			location.reload(); 
		}, 3000);
	});
}

</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">

<div class="wrapper">
	<div class="container-fluid" style="padding-right: 0px">
	<div class="row-fluid">
	<div class="span3"><center><div id="logo"></div></center></div>
	<div class="span9" >
	<div id="TopBanner"></div>
	</div>
	</div>
	</div>

	<div id="Loading" class="popup_bg"></div>

	<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

	<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">

	<input type="hidden" name="current_page" value="Advanced_hxsdwan.asp">
	<input type="hidden" name="next_page" value="">
	<input type="hidden" name="next_host" value="">
	<input type="hidden" name="sid_list" value="HXSDWAN;LANHostConfig;General;">
	<input type="hidden" name="group_id" value="HXSDWANLrout;HXSDWANmapp">
	<input type="hidden" name="action_mode" value="">
	<input type="hidden" name="action_script" value="">
	<input type="hidden" name="hxwan_routenum_x_0" value="<% nvram_get_x("HXSDWANLrout", "hxwan_routenum_x"); %>" readonly="1" />
	<input type="hidden" name="hxwan_mappnum_x_0" value="<% nvram_get_x("HXSDWANmapp", "hxwan_mappnum_x"); %>" readonly="1" />

	<div class="container-fluid">
	<div class="row-fluid">
	<div class="span3">
	<!--Sidebar content-->
	<!--=====Beginning of Main Menu=====-->
	<div class="well sidebar-nav side_nav" style="padding: 0px;">
	<ul id="mainMenu" class="clearfix"></ul>
	<ul class="clearfix">
	<li>
	<div id="subMenu" class="accordion"></div>
	</li>
	</ul>
	</div>
	</div>
	<div class="span9">
	<!--Body content-->
	<div class="row-fluid">
	<div class="span12">
	<div class="box well grad_colour_dark_blue">
	<h2 class="box_head round_top">HXSD-WAN</h2>
	<div class="round_bottom">
	<div>
	<ul class="nav nav-tabs" style="margin-bottom: 10px;">
	<li class="active"><a id="tab_hxwan_cfg" href="#cfg">基本设置</a></li>
	<li><a id="tab_hxwan_sta" href="#sta">运行状态</a></li>
	<li><a id="tab_hxwan_log" href="#log">运行日志</a></li>
	</th>
	</tr>
	<tr>
	</div>
	<div class="row-fluid">
									<div id="tabMenu" class="submenuBlock"></div>
									<div class="alert alert-info" style="margin: 10px;">
									<p>SD-WAN智能组网是一个易于配置异地组网 直连技术支持IPV6【安卓 电脑 MACOS 】：<a href="https://pan.baidu.com/s/1JR-JZm09dJ3Og487o9b2AQ?pwd=3388" target="blank">点击百度网盘下载</a></div>
									</p>
										</div>
										<table width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
									<tr> <th><#running_status#></th>
                                            <td id="hxwan_status" colspan="3"></td>
                                        </tr><td></td><td></td><td></td>
										<tr>
										<tr>
										<th width="30%" style="border-top: 0 none;">启用组网客户端</th>
											<td style="border-top: 0 none;">
													<div class="main_itoggle">
													<div id="hxwan_enable_on_of">
														<input type="checkbox" id="hxwan_enable_fake" <% nvram_match_x("", "hxwan_enable", "1", "value=1 checked"); %><% nvram_match_x("", "hxwan_enable", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="hxwan_enable" id="hxwan_enable_1" class="input" value="1" <% nvram_match_x("", "hxwan_enable", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="hxwan_enable" id="hxwan_enable_0" class="input" value="0" <% nvram_match_x("", "hxwan_enable", "0", "checked"); %> /><#checkbox_No#>
												</div>
											</td>

										</tr>

										<tr>
										<th>本机识别码(不要改动) </th>
				<td>
					<input type="text" class="input" name="hxwan_token" id="hxwan_token" style="width: 200px" value="<% nvram_get_x("","hxwan_token"); %>" />
				</td>

										</tr>

										<tr>
										<th>设备ID名（格式 20）</th>
				<td>
					<input type="text" class="input" name="hxwan_desname" id="hxwan_desname" style="width: 100px" value="<% nvram_get_x("","hxwan_desname"); %>" />
				</td>

										</tr>
										<tr>
										<th>本机虚拟ip（格式 10.26.0.x)</th>
				<td>
					<input type="text" class="input" name="hxwan_ip" id="hxwan_ip" style="width: 200px" value="<% nvram_get_x("","hxwan_ip"); %>" />
				</td>
										<tr>
										<th width="30%" style="border-top: 0 none;">仅使用IPV6连接（必须都有IPV6)</th>
											<td style="border-top: 0 none;">
													<div class="main_itoggle">
													<div id="hxwan_ipv6_enable_on_of">
														<input type="checkbox" id="hxwan_ipv6_enable_fake" <% nvram_match_x("", "hxwanipv6_enable", "1", "value=1 checked"); %><% nvram_match_x("", "hxwan_ipv6_enable", "0", "value=0"); %>  />
													</div>
												</div>
												<div style="position: absolute; margin-left: -10000px;">
													<input type="radio" value="1" name="hxwan_ipv6_enable" id="hxwan_ipv6_enable_1" class="input" value="1" <% nvram_match_x("", "hxwan_ipv6_enable", "1", "checked"); %> /><#checkbox_Yes#>
													<input type="radio" value="0" name="hxwan_ipv6_enable" id="hxwan_ipv6_enable_0" class="input" value="0" <% nvram_match_x("", "hxwan_ipv6_enable", "0", "checked"); %> /><#checkbox_No#>
												</div>

										</tr>
										<tr>
										<th>服务器地址（默认)</th>
				<td>
					<input type="text" class="input" name="hxwan_serverw" id="hxwan_serverw" style="width: 200px" value="<% nvram_get_x("","hxwan_serverw"); %>" />
				</td>
	</div>
	</td>
	</tr><tr id="hxwan_log_td"><td colspan="3"></td></tr>
	<table id="hxwan_subnet_table" width="100%" align="center" cellpadding="4" cellspacing="0" class="table">
	<tr> <th colspan="4" style="background-color: #FF4040;">子网配置也就是接收对端的网关网段和上虚拟IP (多个可以点加号后再填入，如果作为发送点可以不填入）</th></tr>
	<tr id="row_rules_caption">
	<th width="10%"> 备注名称 </th>
	<th width="20%">远端目标网段 </th>
	<th width="20%">远端虚拟IP </th>
	<th width="5%"><center><i class="icon-th-list"></i></center></th>
	</tr>
	<tr>
	<th><input type="text" placeholder="如：家里" maxlength="128" class="span12" style="width: 100px" size="200" name="hxwan_name_x_0" value="<% nvram_get_x("", "hxwan_name_x_0"); %>"/></th>
	<th><input type="text" placeholder="192.168.2.0/24" maxlength="255" class="span12" style="width: 150px" size="200" name="hxwan_route_x_0" value="<% nvram_get_x("", "hxwan_route_x_0"); %>"/></th>
	<th><input type="text" placeholder="10.26.0.2" maxlength="255" class="span12" style="width: 150px" size="200" name="hxwan_ip_x_0" value="<% nvram_get_x("", "hxwan_ip_x_0"); %>" /></th>
	<th><button class="btn" style="max-width: 219px" type="submit" onclick="return markrouteRULES(this, 64, ' Add ');" name="markrouteRULES2" value="<#CTL_add#>" size="12"><i class="icon icon-plus"></i></button></th>
	</tr>
	<tr id="row_rules_body" >
	<td colspan="4" style="border-top: 0 none; padding: 0px;">
	<div id="MrouteRULESList_Block"></div>
	</td>
	</tr>
										</tr>
										<tr>
									
										<td colspan="4" style="border-top: 0 none;">
												<br />
												<center><input class="btn btn-primary" style="width: 219px" type="button" value="<#CTL_apply#>" onclick="applyRule()" /></center>
											</td>
										</tr>														
	</table>
	</div>
	</div>
	</div>
	</div>
	<!-- 状态 -->
	<div id="wnd_hxwan_sta" style="display:none">
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
		<td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
			<textarea rows="21" class="span12" style="height:377px; font-family:'Courier New', Courier, mono; font-size:13px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("hxwan_cmd.log",""); %></textarea>
		</td>
	</tr>
	<tr>
		<td colspan="5" style="border-top: 0 none; text-align: center;">
			<!-- 按钮并排显示 -->
			<input class="btn btn-success" id="btn_info" style="width:100px; margin-right: 10px;" type="button" name="hxwan_info" value="本机设备信息" onclick="button_hxwan_info()" />
			<input class="btn btn-success" id="btn_all" style="width:100px; margin-right: 10px;" type="button" name="hxwan_all" value="所有设备信息" onclick="button_hxwan_all()" />
			<input class="btn btn-success" id="btn_list" style="width:100px; margin-right: 10px;" type="button" name="hxwan_list" value="所有设备列表" onclick="button_hxwan_list()" />
			<input class="btn btn-success" id="btn_route" style="width:100px; margin-right: 10px;" type="button" name="hxwan_route" value="路由转发信息" onclick="button_hxwan_route()" />
			<input class="btn btn-success" id="btn_status" style="width:100px; margin-right: 10px;" type="button" name="hxwan_status" value="运行状态信息" onclick="button_hxwan_status()" />
		</td>
	</tr>
	<tr>
		<td colspan="5" style="border-top: 0 none; text-align: center; padding-top: 5px;">
			<span style="color:#888;">🔄 点击上方按钮刷新查看</span>
		</td>
	</tr>
	</table>
	</div>
	<!-- 日志 -->
	<div id="wnd_hxwan_log" style="display:none">
	<table width="100%" cellpadding="4" cellspacing="0" class="table">
	<tr>
	<td colspan="3" style="border-top: 0 none; padding-bottom: 0px;">
	<textarea rows="21" class="span12" style="height:377px; font-family:'Courier New', Courier, mono; font-size:13px;" readonly="readonly" wrap="off" id="textarea"><% nvram_dump("hxwan.log",""); %></textarea>
	</td>
	</tr>
	<tr>
	<td width="15%" style="text-align: left; padding-bottom: 0px;">
	<input type="button" onClick="location.reload()" value="刷新日志" class="btn btn-primary" style="width: 200px">
	</td>
	<td width="15%" style="text-align: left; padding-bottom: 0px;">
	<input type="button" onClick="location.href='hxwan.log'" value="<#CTL_onlysave#>" class="btn btn-success" style="width: 200px">
	</td>
	<td width="75%" style="text-align: right; padding-bottom: 0px;">
	<input type="button" onClick="clearLog();" value="清除日志" class="btn btn-info" style="width: 200px">
	</td>
	</tr>
	<br><td colspan="5" style="border-top: 0 none; text-align: center; padding-top: 4px;">
	<span style="color:#888;">🚫注意：日志包含 token 和 密码 等隐私信息，切勿随意分享！</span>
	</td>
	</table>
	</div>
</body>

</html>
