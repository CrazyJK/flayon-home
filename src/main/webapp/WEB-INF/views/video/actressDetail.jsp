<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"      uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"     uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="s"      uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="jk"	tagdir="/WEB-INF/tags"%>
<!DOCTYPE html>
<html>
<head>
<title>${actress.name}</title>
<style type="text/css">
#actressForm .form-control {
	background-color: rgba(255,255,255,.75);
}
#favoriteTEXT {
	text-shadow: 0px 0px 5px #0c0c0c;
}
body {
    background-repeat: repeat;
    background-position: center top;
	background-size: initial;
}
input[type='text'].form-control {
	text-align: center;
}
@media (min-width: 1200px) {
	.container-actress {
    	width: 100%;
	}
	ul.list-inline.list-actress > li {
		transform: scale(2, 2);
		margin: 65px 100px;
	}
	.video-card {
		background-color: rgb(171, 116, 91);
    }
	.video-card:hover {
		background-color: rgb(209, 125, 148);
    	transform: none;
    }
}
</style>
<script type="text/javascript">
bgContinue = ${!actress.existImage};
$(document).ready(function() {
	$("form#actressForm").submit(function(event) {
		console.log("form submit...");
		loading(true, "save...");
		setInterval(function() {
//			if (opener) {
//				if (opener.location.href.indexOf("video/actress") > -1) 
//					opener.location.reload();
//			}
			location.href = PATH + "/video/actress/" + $("#newName").val();
		}, 1000);
	});
	!bgContinue && $("body").css({
		background: "url('${PATH}/video/actress/${actress.name}/cover') center top repeat fixed #fff"
	});	
});
</script>
</head>
<body>
<div class="container">
	
	<form id="actressForm" method="post" role="form" action="${PATH}/video/actress" class="form-horizontal">
		<input type="hidden" name="name" value="${actress.name}"/>
		<input type="hidden" name="favorite" id="favorite" value="${actress.favorite}"/>
		<br/>
		<div class="form-group">
			<div class="col-sm-2 text-right">
				<span id="favoriteTEXT" onclick="fnFavorite(this, '${actress.name}')" class="text-danger lead">${actress.favorite ? '★' : '☆'}</span>
			</div>
			<div class="col-sm-4">
				<input class="form-control" type="text" name="newname"   value="${actress.name}"      id="newName" />
			</div>
			<div class="col-sm-4">
				<input class="form-control" type="text" name="localname" value="${actress.localName}" placeholder="local name"/>
			</div>
			<div class="col-sm-1">
				<img src="${PATH}/img/magnify${status.count%2}.png" width="12px" title="<s:message code="video.find-info.actress"/>"
					onclick="popup('<c:url value="${urlSearchActress}"/>${actress.reverseName}', 'infoActress', 800, 600)"/>
			</div>
			<div class="col-sm-1">
				<span class="label label-plain float-right">Score ${actress.score}</span>
			</div>		
		</div>
		<div class="form-group">
			<div class="col-sm-3">
				<input class="form-control" type="text" name="birth"    value="${actress.birth}"    placeholder="Birth"/>
			</div>
			<div class="col-sm-3">
				<input class="form-control" type="text" name="bodySize" value="${actress.bodySize}" placeholder="Body size"/>
			</div>
			<div class="col-sm-2">
				<input class="form-control" type="text" name="height"   value="${actress.height}"   placeholder="Height"/>
			</div>
			<div class="col-sm-2">
				<input class="form-control" type="text" name="debut"    value="${actress.debut}"    placeholder="Debut"/>
			</div>
			<div class="col-sm-2 text-right">
				<button type="submit" class="btn btn-default">Save</button>
			</div>
		</div>
		<div class="form-group">
			<div class="col-sm-12">
				<textarea class="form-control" rows="1" name="comment">${actress.comment}</textarea>
			</div>
		</div>
	</form>
	
	<h3>
		<span class="label label-plain">Studio <small class="badge">${fn:length(actress.studioList)}</small></span>
	</h3>
	<div class="form-group" style="padding-left:60px;">
		<ul class="list-inline">
			<c:forEach items="${actress.studioList}" var="studio">
				<li>
					<div class="box box-small">
						<jk:studio studio="${studio}" view="detail"/>
					</div>
				</li>
			</c:forEach>
		</ul>
	</div>
</div>

<div class="container container-actress">
	<h3>
		<span class="label label-plain">Video <span class="badge">${fn:length(actress.videoList)}</span></span>
	</h3>
	<div class="form-group text-center">
		<c:if test="${actress.name ne 'Amateur'}">
			<ul class="list-inline list-actress">
				<c:forEach items="${actress.videoList}" var="video">
					<li><%@ include file="/WEB-INF/views/video/videoCard.jspf" %></li>
				</c:forEach>
			</ul>
		</c:if>
	</div>
</div>

</body>
</html>
