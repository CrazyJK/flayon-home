<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" 	uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html>
<head>
<title><s:message code="video.torrent"/></title>
<style type="text/css">
*[onclick] {
	cursor: pointer;
}

/* for navbar 
.navbar {
	border: 0;
	padding-top: 20px;
}
.navbar-default {
	background-image: linear-gradient(to bottom,#865050 0,#f8f8f8 100%);
}
.navbar-header {
	padding-left: 5px;
}
.navbar-nav {
	margin: 5px;
}
.nav-tabs > li > a {
	padding: 5px 20px;
}
*/
/* for box view */
#box>ul {
	padding: 3px 6px;
	text-align: center;
}

#box>ul>li>dl {
	background-repeat: no-repeat;
	background-position: center center;
	background-size: cover;
	transition: all 0.3s;
	margin: 5px;
	padding: 3px;
	width: 285px;
	height: 210px;
	border-radius: 10px;
	text-align: left;
	box-shadow: 0 3px 9px rgba(0, 0, 0, .5);
}

/* #box>ul>li>dl:hover { */
.box-hover {
	transform: scale(1.1, 1.1);
	box-shadow: 0 0 9px 6px rgba(255, 0, 0, 0.5) !important;
}

#box>ul>li>dl>dt.nowrap.text-center {
	width: 97%;
}

/* for logic */
.found {
	background-color: rgba(73, 153, 108, 0.5);
}

.moved {
	background-color: rgba(206, 55, 145, 0.5);
}

.nonExist {
	background-color: rgba(74, 60, 60, 0.3);;
}

.more {
	display: none;
}

.search {
	width: 104px !important;
	padding-bottom: 0px;
}
/* for table view */
.tbl-cover {
	display: none;
	position: fixed;
	/* bottom: 20px;
	left: 20px; */
	width: 600px;
	box-shadow: 0 0 6px rgba(255, 0, 0, 1);
	transition: all .2s ease-in-out;
}
.trFocus {
	background-color: rgba(255, 165, 0, 0.3);
}
</style>
<script type="text/javascript" src="<c:url value="/js/videoMain.js"/>"></script>
<script type="text/javascript" src="<c:url value="/js/video-prototype.js"/>"></script>
<script type="text/javascript">
//bgContinue = false;
"use strict";
var lastPage = false;			// 마지막 페이지까지 다 보여줬는지
var pageSize = 12;				// 한페이지게 보여줄 개수
var currSort = '';				// 정렬 항목
var videoList = new Array(); 	// 비디오 배열
var entryIndex = 0;				// 비디오 인덱스 
var renderingCount = 0;			// 보여준 개수
var sortList = [
		{code: "S", name: "Studio"}, {code: "O", name: "Opus"}, {code: "T", name: "Title"}, 
		{code: "A", name: "Actress"}, {code: "D", name: "Released"}, 
		{code: "R", name: "Rank"}, {code: "Sc", name: "Score"}, 
		{code: "To", name: "Torrent"}, {code: "F", name: "Favorite"}, {code: "C", name: "Candidates"}];
var defaultSort = 'D';
var reverse = true;				// 역정렬 여부
var candidateCount = 0;
var hadTorrentCount = 0;
var videoCount = 0;
var withTorrent = false;
var isShortWidth = false;
var queryFoundCount = 0;
var isCheckedFavorite = false;
var currentView = '#box';
var currentVideoNo = -1;

(function($) {
	$(document).ready(function() {
		// init components
		$.each(sortList, function(i, sort) {
			$("<button>").addClass("btn btn-xs").data("sort", sort).html(sort.code).appendTo($(".btn-group-sort"));
		});
		// add EventListener
		fnAddEventListener();
		// ajax data		
		request();
		
	});
}(jQuery));

function fnAddEventListener() {
	// scroll
	$("#content_div").scroll(function() {
		if (fnIsScrollBottom())
			render(false); // next page
	});

	// search	
	$(".search").on('keyup', function(e) {
		var event = window.event || e;
		if (event.keyCode == 13)
			render(true);
	});
	
	// favorite
	$("#checkbox-favorite").on('click', function() {
		if ($("input:checkbox[id='favorite']").prop("checked")) {
			console.log("favorite", true);
		}
	});
	
	// sorting & render
	$(".btn-group-sort").children().on('click', function() {
		$(this).parent().children().each(function() {
			var sort = $(this).data("sort");
			$(this).removeClass("btn-success").addClass("btn-default").attr({"title": sort.name}).html(sort.code).css({"border-color": "#3e8f3e"});
		});
		var sort = $(this).data('sort');
		if (currSort === sort.code) // 같은 정렬
			reverse = !reverse;
		else	// 다른 정렬
			reverse = true;
		currSort = sort.code;
		
		videoSort(videoList, sort.code, reverse);

		$(".sorted").html(sort.name + (reverse ? " desc" : ""));
		$(this).removeClass("btn-default").addClass("btn-success").html(sort.name + (reverse ? ' ▼' : ' ▲'));
		
		render(true);
	});
	
	// re-request
	$(".count").attr({"title": "re-request"}).on('click', function() {
		defaultSort = 'C';
		request();
	});

	// cover click
/* 	$("#cover").on("click", function() {
		$("#checkbox-viewImage").click();
		$(this).hide();
	}).css({"cursor": "pointer"});
 */

 	// tab event
	$('button[data-toggle="tab"]').on('shown.bs.tab', function (e) {
		$('button[data-toggle="tab"]').removeClass("btn-info").addClass("btn-default").css({"border-color": "#28a4c9"});
		$(e.target).removeClass("btn-default").addClass("btn-info");
		currentView = $(e.target).attr("href");
		if (currentView === '#box') { 	// for box
			$("#magnify").show();
			$("#cover").hide();
			$("#torrent").hide();
		}
		else {							// for table
			$("#magnify").hide();
			$("#cover").show();
			$("#torrent").show();
		}
	});
	$(currentView).addClass("in active");
	$('button[href="' + currentView + '"]').click();

	// custom checkbox
	$("[role='checkbox']").css("cursor", "pointer").each(function() {
		var value = $(this).attr("role-data");
		if (value === 'true') {
			$(this).removeClass("label-default").addClass("label-success").data("checked", "true");
		}
		else {
			$(this).removeClass("label-success").addClass("label-default").data("checked", "false");
		}
	}).on("click", function() {
		var value = $(this).data("checked");
		if (value === 'true') {
			$(this).removeClass("label-success").addClass("label-default").data("checked", "false");
		}
		else {
			$(this).removeClass("label-default").addClass("label-success").data("checked", "true");
		}
	});
	// for favorite checkbox
	$("#favorite").on("click", function() {
		isCheckedFavorite = $(this).data("checked");
		render(true);
	});
	// for cover checkbox
	$("#cover").on("click", function() {
		if ($(this).data("checked") === 'true') {
			showCover();
		}
		else {
			$(".trFocus").removeClass("trFocus").find("img").hide();
		}
	});
	// for torrent checkbox
	$("#torrent").on("click", function() {
		console.log("torrent", $(this).data("checked"));
		if ($(this).data("checked") === 'true') {
			$(".torrent").removeClass("hide");
		}
		else {
			$(".torrent").addClass("hide");
		}
	});
	
	$(window).on('keyup', function(e) {
		if (currentView === '#table') {
			if (e.keyCode == 38) { // up key
				if (currentVideoNo > -1)
					currentVideoNo--;
			} else if (e.keyCode == 40) { // down key
				if (currentVideoNo < renderingCount - 1)
					currentVideoNo++;
			} else {
				// nothing			
			}
			if (e.keyCode == 38 || e.keyCode == 40) {
				showCover(true);
			}
		}
	});
	
}

function showCover(isKey) {
//	console.log("currentVideoNo", currentVideoNo);
	if ($("#cover").data("checked") === 'true') {

		$(".trFocus").removeClass("trFocus").find("img").hide();
	
		if (currentVideoNo > -1) {
			if (isKey) {
				// console.log("curr scrollTop", $("#content_div").scrollTop(), "next scrollTop", currentVideoNo * 30, "imgTop", imgTop);
				$("#content_div").scrollTop(currentVideoNo * 30);
			}

			var thisTr = $("tr[data-no='" + currentVideoNo + "']");
			var imgTop = $(thisTr).offset().top + 40;
			thisTr.addClass("trFocus").find("img").css({"top": imgTop}).show();
		}
	}
}

function request() {
	loading(true, "request...");
	showStatus(true, "Request...");

	// reset variables
	reverse = !reverse;
	hadTorrentCount = 0;
	candidateCount = 0;
	videoCount = 0;
	withTorrent = $("#torrent").data("checked") === 'true';
	
	$.getJSON({
		method: 'GET',
		url: '/video/list.json',
		data: {"t": withTorrent},
		cache: false,
		timeout: 60000
	}).done(function(data) {
		if (data.exception) {
			showStatus(true, data.exception.message, true);
		}
		else {
			videoList = [];
			$.each(data.videoList, function(i, row) { // 응답 json을 videoList 배열로 변환
				if (row.torrents.length > 0)
					hadTorrentCount++;
				if (row.videoCandidates.length > 0)
					candidateCount++;
				if (row.videoFileList.length > 0)
					videoCount++;
				videoList.push(new Video(i, row));
			});
			$(".candidate" ).html("C " + candidateCount);
			$(".videoCount").html("V " + videoCount);
			$("#torrent"   ).html("T " + hadTorrentCount);

			// 정렬하여 보여주기 => sort
			$(".btn-group-sort").children().each(function() {
				var sort = $(this).data("sort");
				if (sort.code === defaultSort) {
					$(this).click();
				}
			});
		}
	}).fail(function(jqxhr, textStatus, error) {
		showStatus(true, textStatus + ", " + error, true);
	}).always(function() {
		loading(false);
	});	
}

function render(first) {
	showStatus(true, "rendering...");
	
	var displayCount = 0;
	var query = $(".search").val();
	var parentOfVideoBox  = $("#box > ul");
	var parentOfTableList = $("#table > table > tbody");
	withTorrent = $("#torrent").data("checked") === 'true';

	if (first) { // initialize if first rendering 
		entryIndex = 0;
		renderingCount = 0;
		lastPage = false;
		parentOfVideoBox.empty();
		parentOfTableList.empty();
		$(".more").show();
		// found count by query
		if (query != '' || isCheckedFavorite === 'true') {
			queryFoundCount = 0;
			for (var i=0; i<videoList.length; i++) {
				if (videoList[i].contains(query, isCheckedFavorite)) {
					queryFoundCount++;
				}
			}
		}
	}
	
	while (entryIndex < videoList.length) {
		if (query != '' || isCheckedFavorite === 'true') { // query filtering
			if (!videoList[entryIndex].contains(query, isCheckedFavorite)) {
				entryIndex++;
				continue;
			}
		}
		
		if (displayCount < pageSize) { // render html
			renderBox(renderingCount, videoList[entryIndex], parentOfVideoBox);
			renderTable(renderingCount, videoList[entryIndex], parentOfTableList);

			renderingCount++; 	// 화면에 보여준 개수
			displayCount++;		// 이번 메서드에서 보여준 개수
			entryIndex++;		// videoList의 현개 인덱스 증가
		}
		else {
			break;
		}
	}

//	console.log("render", first, displayCount, entryIndex, renderingCount, videoList.length);
	if (entryIndex == videoList.length) { // 전부 보여주었으면
		lastPage = true;
		$(".more").hide();
	}
	
	if (fnIsScrollBottom()) // 한페이지에 다 보여서 스크롤이 생기지 않으면 한번더
		render();
	
	if (query != '' || isCheckedFavorite === 'true') {
		$(".count").html(renderingCount + " / " + queryFoundCount);
	}
	else {
		$(".count").html(renderingCount + " / " + videoList.length);
	}
	
	setTblCoverPosition();
	
	showStatus(false);
}

function fnIsScrollBottom() {
	var containerHeight    = $("#content_div").height();
	var containerScrollTop = $("#content_div").scrollTop();
	var documentHeight     = $("ul.nav-tabs").height() + $("div.tab-content").height();
	var scrollMargin       = $("p.more").height();
//	console.log("fnIsScrollBottom", containerHeight, ' + ', containerScrollTop, ' = ', (containerHeight + containerScrollTop), ' > ', documentHeight, ' + ', scrollMargin, ' = ', (documentHeight - scrollMargin), lastPage);
	return (containerHeight + containerScrollTop > documentHeight - scrollMargin) && !lastPage;
}

function showStatus(show, msg, isError) {
	if (show) { // loading start
		if (isError) {
			$(".status").html(msg).show();
		}
		else {
			$(".status").html(msg).show();
		}
	}
	else { // loading complete
		$(".status").fadeOut(1500);
	}
}

function renderBox(index, video, parent) {
	var dl = $("<dl>").css({"background-image": "url('" + video.coverURL + "')"}).addClass("video-cover").hover(function(event) {
		if ($("#magnify").data("checked") === "true") {
			$(this).addClass("box-hover");
		}
	}, function() {
		if ($("#magnify").data("checked") === "true") {
			$(this).removeClass("box-hover");
		}
	});
	$("<dt>").appendTo(dl).html(video.html_title).addClass("nowrap text-center");
	$("<dd>").appendTo(dl).html(video.html_studio);
	$("<dd>").appendTo(dl).html(video.html_opus);
	$("<dd>").appendTo(dl).html(video.html_actress);
	$("<dd>").appendTo(dl).html(video.html_release);
	$("<dd>").appendTo(dl).html(video.html_video);
	$("<dd>").appendTo(dl).html(video.html_subtitles);
	$("<dd>").appendTo(dl).html(video.html_videoCandidates);
	$("<dd>").appendTo(dl).html(video.html_torrents + video.html_torrentFindBtn);
	$("<dd>").appendTo(dl).html(video.overviewText);
	$("<li>").append(dl).appendTo(parent).attr({"data-idx": video.idx});
}

function renderTable(index, video, parent) {
	var tr = $("<tr>").appendTo(parent).attr({"id": "check-" + video.opus, "data-idx": video.idx, "data-no": index}).hover(
			function(event) {
				currentVideoNo = $(this).attr("data-no");
				showCover();
				/* 
				if ($("input:checkbox[id='viewImage']").prop("checked")) {
//					var imgTop = event.clientY + 40;
					var imgTop = $(this).offset().top + 40;
					$(this).find("img").css({"top": imgTop}).show();
//					console.log("tr Y", $(this).offset().top);
				} */
			}, function(event) {
				//$("#tbl-cover-" + video.opus).hide();
			}
	).focus(function() {
		console.log("focus", $(this).attr("data-no"));
	});
	$('<td>').appendTo(tr).addClass("text-right").html("<span class='label label-plain'>" + (index+1) + "</span>");
	$("<td>").appendTo(tr).html(video.html_studio);
	$("<td>").appendTo(tr).html(video.html_opus);
	$('<td>').appendTo(tr).html(
		$('<div>').addClass("nowrap").append(
			$('<span>').addClass('label label-plain').attr({"onclick": "fnViewVideoDetail('" + video.opus + "')"}).html(video.title).attr({"title": video.title, "data-toggle": "tooltip"}) //.tooltip()
		).append(
			$("<img>").attr({"id": "tbl-cover-" + video.opus,"src": video.coverURL}).addClass("img-thumbnail tbl-cover").hide()
		)
	).css({"max-width": "300px"});
	$("<td>").appendTo(tr).html(video.html_actress).css({"max-width": "100px"}).attr({"title": video.actressName});
	$("<td>").appendTo(tr).html(video.html_release).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_video);
	$("<td>").appendTo(tr).html(video.html_subtitles).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_rank).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).html(video.html_score).addClass("shortWidth " + (isShortWidth ? "hide" : ""));
	$("<td>").appendTo(tr).append(
			$("<div>").append(video.html_videoCandidates).append(video.html_torrents).append(video.html_torrentFindBtn)
	).addClass("torrent " + (withTorrent ? "" : "hide"));
}

function fnSelectCandidateVideo(opus, idx) {
	$(".candidate").html("Candidate " + --candidateCount);
	$("[data-idx=" + idx + "]").hide();
}
function goTorrentSearch(opus, idx) {
	$("[data-idx='" + idx + "']").addClass("found");
	popup(videoPath + '/' + opus + '/cover/title', 'SearchTorrentCover', 800, 600);
	popup(videoPath + '/torrent/search/' + opus, 'torrentSearch', 900, 950);
}
function goTorrentMove(opus, idx) {
	$("[data-idx='" + idx + "']").addClass("moved");
	actionFrame(videoPath + "/" + opus + "/moveTorrentToSeed", {}, "POST", "Torrent move");
}
function getAllTorrents() {
	actionFrame(videoPath + "/torrent/getAll", {}, "POST", "Torrent get all");
}
function resizeSecondDiv() {
	isShortWidth = $(window).width() < 950;
	if (isShortWidth)
		$(".shortWidth").addClass("hide");
	else
		$(".shortWidth").removeClass("hide");

	setTblCoverPosition();
}
function setTblCoverPosition() {
	var imgWidth = windowWidth / 2;
	if (imgWidth > 800)
		imgWidth = 800;
	var imgLeft = windowWidth / 4;
	$(".tbl-cover").css({"left": imgLeft, "width": imgWidth});
}
</script>
</head>
<body>
<div class="container-fluid" role="main">

	<div id="header_div" class="box form-inline">
   		<input class="form-control input-sm search" placeholder="Search..."/>
		<span class="label label-info    count pointer">Initialize...</span>
		<span class="label label-warning videoCount" title="video count"></span>
		<span class="label label-primary candidate" title="candidate count"></span>
   		<span class="label label-default" id="torrent"  role="checkbox" role-data="false" title="view torrent">Torrent</span>
   		<span class="label label-default" id="cover"    role="checkbox" role-data="false" title="view cover">Cover</span>
   		<span class="label label-default" id="favorite" role="checkbox" role-data="false" title="only favorite">Favorite</span>
   		<span class="label label-default" id="magnify"  role="checkbox" role-data="false" title="active magnify">Magnify</span>
      	<span class="label label-danger status"></span>
      	
      	<div class="float-right">
			<div class="btn-group">
		      	<button class="btn btn-xs btn-info"    data-toggle="tab" href="#table">Table</button>
		      	<button class="btn btn-xs btn-default" data-toggle="tab" href="#box">Box</button>
			</div>
			<div class="btn-group btn-group-sort"></div>
			<button class="btn btn-xs btn-primary" onclick="getAllTorrents()" title="get all torrent">All T</button>
      	</div>
	</div>
	
	<div id="content_div" class="box" style="overflow-x: hidden;">
		<%-- <ul class="nav nav-tabs">
			<li class="active"><a data-toggle="tab" href="#table">TABLE</a></li>
			<li class=""><a data-toggle="tab" href="#box">BOX</a></li>
			<li class="float-right">
				<span class="label label-info videoCount"></span>
				<span class="label label-primary candidate"></span>
				<span class="label label-warning torrents"></span>
				<span class="label label-success sorted hide"></span>
			</li>
		</ul> --%>
		<div class="tab-content">
			<section id="box" class="tab-pane fade">
				<ul class="list-group list-inline vbox"></ul>
			</section>
			<section id="table" class="tab-pane fade table-responsive">
				<table class="table table-condensed table-hover table-bordered" style="margin-bottom:0;">
					<tbody></tbody>
				</table>
			</section>
			<p class="more text-center"><button class="btn btn-warning" onclick="render()">More...</button></p>
		</div>
	</div>

</div>

</body>
</html>
