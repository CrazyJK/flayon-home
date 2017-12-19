<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="http://www.springframework.org/tags" %>
<!DOCTYPE html>
<html> 
<head>
<meta charset="UTF-8">
<title>Image Tablet</title>
<link rel="stylesheet" href="${PATH}/css/app/image/slide.css"/>
<link rel="stylesheet" href="${PATH}/css/app/image/tablet.css"/>
<script src="${PATH}/js/crazy.image.timer.engine.js"></script>
<script src="${PATH}/js/crazy.image.tablet.js"></script>
<script type="text/javascript">
bgContinue = false;
$(function() {
	tablet.init();
});
</script>
</head>
<body>
	<div class="container-fluid container-tablet">
		<div>
			<div id="leftTop">
				<div id="progressWrapper"></div>
			</div>
			<div id="leftBottom">
				<div class="configInfo">
					<code class="label label-plain   imageSource"></code>
					<code class="label label-plain    showMethod"></code>
					<code class="label label-plain  rotateDegree"></code>
					<code class="label label-plain    nextMethod"></code>
					<code class="label label-plain  playInterval"></code>
					<code class="label label-plain    hideMethod"></code>
					<code class="label label-plain displayMethod"></code>
				</div>
			</div>
			<div id="rightTop"></div>
			<div id="rightBottom"></div>
			<div id="fixedBox">
				<img class="btn-config" src="${PATH}/img/config.png" width="20px" data-toggle="modal" data-target="#configModal"/>
				<span class="label label-plain displayCount">&nbsp;</span>
				<span class="label label-plain title popup-image">&nbsp;</span>
				<span class="close close-o0 delete-image">&times;</span>
			</div>
		</div>
		<div id="imageDiv"></div>
	</div>
	
	<div id="configModal" class="modal fade" role="dialog">
		<div class="modal-dialog modal-lg">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">&times;</button>
					<h4 class="modal-title"><i class="shortcuts">C</i>onfiguration
					<button class="btn btn-plain btn-sm btn-shuffle">Shu<i class="shortcuts">f</i>fle</button>
					</h4>
				</div>
				<div class="modal-body">
					<div id="configBox">
						<div class="row">
							<div class="col-xs-2 text-bold">Image Source</div>
							<div class="col-xs-1"><kbd>Insert</kbd></div>
							<div class="col-xs-4 text-right">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="imageSource">Image</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="imageSource" value="1" min="0" max="1" class="config-switch-range"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="imageSource">Cover</span>
							</div>
						</div>
						<div class="row">
							<div class="col-xs-2 text-bold">Show Method</div>
							<div class="col-xs-1"><kbd>Home</kbd></div>
							<div class="col-xs-4 text-right">
								<select id="effectShowTypes" class="config-select"></select>
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="showMethod">Specific</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="showMethod" value="1" min="0" max="1" class="config-switch-range"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="showMethod">Random</span>
							</div>
						</div>	
						<div class="row">
							<div class="col-xs-2 text-bold">Show Rotate</div>
							<div class="col-xs-1"><kbd>&nbsp;0&nbsp;</kbd></div>
							<div class="col-xs-1 text-right"><kbd>&nbsp;-&nbsp;</kbd></div>
							<div class="col-xs-7">
								<input type="range" id="rotateDegree" class="config-range" value="15" min="0" max="360"/>
							</div>
							<div class="col-xs-1"><kbd>&nbsp;+&nbsp;</kbd></div>
						</div>
						<div class="row">
							<div class="col-xs-2 text-bold">Next Method</div>
							<div class="col-xs-1"><kbd>PageUp</kbd></div>
							<div class="col-xs-4 text-right">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="nextMethod">Sequencial</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="nextMethod" value="1" min="0" max="1" class="config-switch-range"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="nextMethod">Random</span>
							</div>
						</div>	
						<div class="row">
							<div class="col-xs-2 text-bold">Play Interval</div>
							<div class="col-xs-1"><kbd>Numpad</kbd></div>
							<div class="col-xs-1 text-right"><kbd>Numpad -</kbd></div>
							<div class="col-xs-7">
								<input type="range" id="playInterval" class="config-range" value="10" min="1" max="20"/>
							</div>
							<div class="col-xs-1"><kbd>Numpad +</kbd></div>
						</div>
						<div class="row">
							<div class="col-xs-2 text-bold">Hide Method</div>
							<div class="col-xs-1"><kbd>End</kbd></div>
							<div class="col-xs-4 text-right">
								<select id="effectHideTypes" class="config-select">
									<option value="own">Own</option>
								</select>
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="hideMethod">Effect</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="hideMethod" value="1" min="0" max="1" class="config-switch-range"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="hideMethod">Remove</span>
							</div>
						</div>	
						<div class="row">
							<div class="col-xs-2 text-bold">Display Method</div>
							<div class="col-xs-1"><kbd>PageDown</kbd></div>
							<div class="col-xs-4 text-right">
								<span class="label label-default label-switch" data-role="switch" data-value="0" data-target="displayMethod">Tablet</span>
							</div>
							<div class="col-xs-1 text-center">
								<input type="range" role="switch" id="displayMethod" value="1" min="0" max="1" class="config-switch-range"/>
							</div>
							<div class="col-xs-4 text-left">
								<span class="label label-default label-switch" data-role="switch" data-value="1" data-target="displayMethod">Tile</span>
							</div>
						</div>	
					</div>
				</div>
				<div class="modal-footer">
					<div class="config-summary">
						<span class="config-key">Source  </span> <span class="config-value   imageSource"></span> 
						<span class="config-key">Show    </span> <span class="config-value    showMethod"></span> 
						<span class="config-key">Rotate  </span> <span class="config-value  rotateDegree"></span>
						<span class="config-key">Next    </span> <span class="config-value    nextMethod"></span>
						<span class="config-key">Interval</span> <span class="config-value  playInterval"></span>
						<span class="config-key">Hide    </span> <span class="config-value    hideMethod"></span> 
						<span class="config-key">Display </span> <span class="config-value displayMethod"></span> 
					</div>
					<div class="box box-small box-inset text-left key-map">
						<div class="row">
  							<div class="col-xs-3">
  								<kbd>Esc</kbd> Blind
  							</div>
  							<div class="col-xs-3">
  							</div>
  							<div class="col-xs-3">
  								<kbd>C</kbd> Config
  							</div>
  							<div class="col-xs-3">
  								<kbd>F</kbd> Shuffle
  							</div>
						</div>
						<div class="row">
  							<div class="col-xs-3">
  								<kbd>E</kbd> Empty image 
  							</div>
  							<div class="col-xs-3">
  								<kbd>Shift</kbd> Tile
  							</div>
  							<div class="col-xs-3">
  								<kbd>Ctrl</kbd> Shake
  							</div>
  							<div class="col-xs-3">
  								<kbd>Space</kbd> Play image<br>
  							</div>
						</div>
						<hr/>
						<div class="row">
  							<div class="col-xs-12 text-center">
  								<table style="display:inline-block;">
  									<tr>
  										<td rowspan="2">
  											Prev image
  											 <kbd>Left</kbd> 
  										</td>
  										<td>
  										</td>
  										<td style="border-right: 2px solid #222; border-bottom: 2px solid #222; padding-bottom:2px;">
  											<kbd>Up</kbd>
  										</td>
  										<td style="width:5px; border-top: 2px solid #222;">
  										</td>
  										<td rowspan="2">
  											<kbd>Right</kbd> 
  											Next image
  										</td>
  									</tr>
  									<tr>
  										<td style="width:5px; border-bottom: 2px solid #222;">
  										</td>
  										<td style="border-left: 2px solid #222; padding-top:2px;">
  											<kbd>Down</kbd>
  										</td>
  										<td>
  										</td>
  									</tr>
  								</table>
  							</div>
						</div>
						<hr/>
						<div class="row">
  							<div class="col-xs-3">
  								Mouse
  							</div>
  							<div class="col-xs-3">
  								<kbd>Left</kbd> Drag, Focus
  							</div>
  							<div class="col-xs-3">
  								<kbd>Middle</kbd> Shake
  							</div>
  							<div class="col-xs-3">
  								<kbd>Right</kbd>
  							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
</body>
</html>
