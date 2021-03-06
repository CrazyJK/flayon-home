<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c"    uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt"  uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8" />
<title>Memory</title>
</head>
<body>
<div class="container">

	<div class="page-header">
		<h1>JVM Memory</h1>
	</div>

	<table class="table table-bordered">
		<thead class="bg-primary">
			<tr>
				<th>Area</th>
				<th class="text-right">Init</th>
				<th class="text-right">Used</th>
				<th class="text-right">Commit</th>
				<th class="text-right">Max</th>
				<th class="text-right">Used</th>
			</tr>
		</thead>
		<tbody>
			<tr>
				<th>Heap</th>
				<td class="text-right"><fmt:formatNumber value="${heap.init / 1024 / 1024}" pattern="#,### MB"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.used / 1024 / 1024}" pattern="#,### MB"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.committed / 1024 / 1024}" pattern="#,### MB"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.max / 1024 / 1024}" pattern="#,### MB"/></td>
				<td class="text-right"><fmt:formatNumber value="${heap.used / heap.max}" type="percent"/></td>
			</tr>
			<tr>
				<th>Non Heap</th>
	 			<td class="text-right"><fmt:formatNumber value="${nonHeap.init / 1024 / 1024}" type="number" maxFractionDigits="0"/> MB</td>
				<td class="text-right"><fmt:formatNumber value="${nonHeap.used / 1024 / 1024}" type="number" maxFractionDigits="0"/> MB</td>
				<td class="text-right"><fmt:formatNumber value="${nonHeap.committed / 1024 / 1024}" type="number" maxFractionDigits="0"/> MB</td>
				<td class="text-right"><c:if test="${nonHeap.max > 0}"><fmt:formatNumber value="${nonHeap.max / 1024 / 1024}" type="number" maxFractionDigits="0"/> MB</c:if></td>
				<td class="text-right"><c:if test="${nonHeap.max > 0}"><fmt:formatNumber value="${nonHeap.used / nonHeap.max}" type="percent"/></c:if></td>
			</tr>
		</tbody>
	</table>

	<pre>Heap : ${heap}<br>Non-Heap : ${nonHeap}</pre>

</div>
</body>
</html>
