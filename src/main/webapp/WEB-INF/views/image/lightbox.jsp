<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Lightbox</title>
<link rel="stylesheet" href="${PATH}/css/lightbox.css">
<style type="text/css">
.progress {
	position: fixed;
	top: 0px;
	left: 0px;
	width: 100px;
	margin: 5px;
	z-index: 2000;
	float: right;
	background-image: linear-gradient(to bottom,#403a3a 0,#2f2626 100%);
}
#timerBar {
	background: #000;
}
.form-control {
	border: 0;
    box-shadow: none;
    min-height: 40px;
}
.form-group {
    margin: auto 5px 5px 5px !important;
}
.form-group:not(:last-child) {
	border-bottom: 1px dashed #ddd;
    padding-bottom: 5px;
}
.form-group input[type='range'],.form-group input[type='text'] {
	font-size: 12px;
	padding: 0 6px;
	height: 27px;
	min-height: 27px;
}
.control-label {
	text-transform: capitalize;
}
</style>
<script type="text/javascript">
"use strict";

bgContinue = false;
var imagepath = '<s:url value="/image/"/>';
var imageCount;
var imageMap;

var playInterval, playSec, playMode, playSlide = false;

$(document).ready(function() {

	$.getJSON(imagepath + "data.json" ,function(data) {
		imageCount = data['imageCount'];
		imageMap = data['imageNameMap'];
		
		$(".imageCount").html(imageCount);
		
		var $imageset = $('#imageset');
		for (var i=0; i<imageCount; i++) {
			$("<a>").attr({
				'href': imagepath + i,
				'data-lightbox': 'lightbox-set',
				'data-title': "<a href='" + imagepath + i + "' target='image-" + i + "'>" + imageMap[i] + "</a>",
				"data-index": i
			}).appendTo($imageset);
		}
	
		fnCurrImage();
	});

	var playTimer = setInterval(function() {
		if (playSlide) {
			if (--playSec % playInterval == 0) {
				if (playMode === 'r') {
					fnRandomImage();
				}
				else {
			    	fnNextImage();
				}
				playSec = playInterval;
			}
			showTimer(playSec);
		}
	},	1000);

	fnSetOption();
	$(".form-control, .checkbox-inline, .radio-inline").on("change", function() {
		var changeOptionText;
		if (this.nodeName === 'LABEL')
			if (this.control.type === 'radio')
				changeOptionText = $(this.control).attr("name") + " = " + $('input:radio[name="' + $(this.control).attr("name") + '"]:checked').val();
			else if (this.control.type === 'checkbox')
				changeOptionText = $(this.control).attr("id") + " = " + $(this.control).is(":checked");
			else
				changeOptionText = "unknown change";
		else
			changeOptionText = $(this).attr("id") + " = " + $(this).val();

		showSnackbar(changeOptionText, 1000);
		fnSetOption();
	});
});

function fnPrevImage() {
	$("a.lb-prev").click();
}
function fnNextImage() {
	$("a.lb-next").click();
}
function fnCurrImage(selectedNumber) {
	if (!selectedNumber)
		selectedNumber = parseInt(getlocalStorageItem("thumbnamils.currentImageIndex", getRandomInteger(0, imageCount-1))) + 1;
	$("#imageset a:nth-child(" + selectedNumber + ")").click();
}
function fnRandomImage() {
	fnCurrImage(getRandomInteger(0, imageCount-1));
}
function fnPlayImage() {
	playSlide = !playSlide;
	if (playSlide) { // start
		playSec = playInterval;
		fnRandomImage();
	}
	else { // stop
		showTimer(playInterval, "Play");
	}
}
function showTimer(sec, text) {
	if (text)
		$("#timer").html(text);
	else
		$("#timer").html(sec + "s");
	$("#timerBar").attr("aria-valuenow", sec).css("width", sec/playInterval*100 + "%");
}
function fnSetOption() {
	lightbox.option({
		'albumLabel': 				  $("#albumLabel").val(),
		'showDataLabel': 			  $("#showDataLabel").is(":checked"),
		'showImageNumberLabel': 	  $("#showImageNumberLabel").is(":checked"),
		'resizeDuration':	 parseInt($("#resizeDuration").val()),
      	'fadeDuration': 	 parseInt($("#fadeDuration").val()),
      	'imageFadeDuration': parseInt($("#imageFadeDuration").val()),
      	'wrapAround': 				  $("#wrapAround").is(":checked"),
      	'positionFromTop': 	 parseInt($("#positionFromTop").val()),
      	'randomImageEffect':    	  $("#randomImageEffect").is(":checked"),
      	'sanitizeTitle': false,
      	disableScrolling: true
    });
	playInterval = parseInt($("#playInterval").val());
	playMode = $('input:radio[name="playMode"]:checked').val();
	$("#timerBar").attr("aria-valuemax", playInterval);
}
</script>
</head>
<body>
	<div class="container">
		<div class="page-header">
			<h1>Lightbox
				<small class="badge imageCount"></small>
			</h1>
		</div>
	
		<div class="form-horizontal box">
			<h1 class="text-center">Options</h1>
			<div class="form-group">
				<label class="control-label col-xs-6" for="albumLabel">albumLabel:</label>
				<div class="col-xs-6">
					<input type="text" class="form-control" id="albumLabel" value="Image %1 of %2" placeholder="%1 of %2"/>
				</div>
			</div>
			<div class="form-group">        
				<label class="control-label col-xs-6" for="showDataLabel">showDataLabel:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="showDataLabel">showDataLabel</label>
				</div>
			</div>
			<div class="form-group">        
				<label class="control-label col-xs-6" for="showImageNumberLabel">showImageNumberLabel:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="showImageNumberLabel">showImageNumberLabel</label>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="resizeDuration">resizeDuration:</label>
				<div class="col-xs-6">
					<input type="range" class="form-control" id="resizeDuration" value="700" min="100" max="1000" step="100"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="fadeDuration">fadeDuration:</label>
				<div class="col-xs-6"> 
					<input type="range" class="form-control" id="fadeDuration" value="600" min="100" max="1000" step="100"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="imageFadeDuration">imageFadeDuration:</label>
				<div class="col-xs-6"> 
					<input type="range" class="form-control" id="imageFadeDuration" value="700" min="100" max="1000" step="100"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="randomImageEffect">randomImageEffect:</label>
				<div class="col-xs-6"> 
					<label class="checkbox-inline"><input type="checkbox" id="randomImageEffect">randomImageEffect</label>
				</div>
			</div>
			<div class="form-group"> 
				<label class="control-label col-xs-6" for="wrapAround">wrapAround:</label>
      			<div class="col-xs-6">
					<label class="checkbox-inline"><input type="checkbox" checked="checked" id="wrapAround">wrapAround</label>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="playInterval">playInterval:</label>
				<div class="col-xs-6"> 
					<input type="range" class="form-control" id="playInterval" value="10" min="5" max="20" step="1"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6" for="positionFromTop">positionFromTop:</label>
				<div class="col-xs-6"> 
					<input type="range" class="form-control" id="positionFromTop" value="30" min="30" max="100" step="10"/>
				</div>
			</div>
			<div class="form-group">
				<label class="control-label col-xs-6">playMode</label>
				<div class="col-xs-6">
					<label class="radio-inline"><input type="radio" name="playMode" value="r" checked="checked">Random</label>
					<label class="radio-inline"><input type="radio" name="playMode" value="s">Sequential</label>
				</div>
			</div>
			<div class="form-group">
      			<div class="col-xs-12">
					<button class="btn btn-default btn-block btn-lg" onclick="fnCurrImage()">View</button>
				</div>
			</div>
		</div>
		<div class="debug"></div>
	</div>

	<div class="progress" onclick="fnPlayImage();">
  		<div id="timerBar" class="progress-bar progress-bar-info" role="progressbar" aria-valuenow="10"
  			aria-valuemin="0" aria-valuemax="10" style="width:100%"><span id="timer">Play</span></div></div>

	<div id="imageset"></div>

	<script src="${PATH}/js/lightbox.js"></script>
</body>
</html>
