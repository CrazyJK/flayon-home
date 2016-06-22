<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8"></meta>
<title>RequestMapping List</title>
<style type="text/css">
table {
	font-size:0.8em; width:100%;
}
tbody > tr:hover {
	background-color:rgba(255,165,0,.25);
}
th {
	background-color:rgba(255,165,0,.5);
}
td {
	font-family: "나눔고딕코딩";
}
* [onclick] {
	cursor:pointer;
}
* [onclick]:hover {
	color:orange; 
	text-decoration:none; 
	text-shadow:1px 1px 1px black;
}
.selected {
	color: blue;
}
</style>
<script type="text/javascript">
$(document).ready(function() {
	var sort = location.search.split("=")[1]; 
	if (sort == 'M')
		$("#M").addClass("selected");
	else if (sort == 'C')
		$("#C").addClass("selected");
	else
		$("#P").addClass("selected");
});
function fnSort(sort) {
	location.href= "?sort=" + sort;
}
</script>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>Request Mapping List</h1>
 	</div>

	<table class="table table-condensed">
		<thead>
			<tr>
				<th align="center">	No</th>
				<th align="left">	<span id="P" onclick="fnSort('P')">Pattern</span></th>
				<th align="center">	<span id="M" onclick="fnSort('M')">Method</span></th>
				<th align="right">	<span id="C" onclick="fnSort('C')">Class</span></th>
				<th align="left">	Method</th>
			</tr>
		</thead>
		<tbody>
			<c:forEach items="${mappingList}" var="mapping" varStatus="mappingStat">
			<tr>
				<td align="center">${mappingStat.count}</td>
				<td align="left"  >${mapping.reqPattern}</td>
				<td align="center">${mapping.reqMethod}</td>
				<td align="right" >${mapping.beanType}</td>
				<td align="left"  >${mapping.beanMethod}</td>
			</tr>
			</c:forEach>
		</tbody>
	</table>

</div>
</body>
</html>
