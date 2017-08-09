bgContinue = false;

/**
 * aperture module
 */
var apertureApp = (function() {

	var imagepath = PATH + '/image/';
	var selectedNumber;
	var selectedImgUrl;
	var imageCount;
	var imageMap;
	var playSlide = false;

	var app = {
			popup: function fnFullyImageView() {
				console.log("popup");
				popupImage(selectedImgUrl);
			},
			prevNumber: function getPrevNumber() {
				return selectedNumber == 0 ? imageCount - 1 : selectedNumber - 1;
			},
			nextNumber: function getNextNumber() {
				return selectedNumber == imageCount -1 ? 0 : selectedNumber + 1;
			},
			first: function fnFirstImageView() {
				console.log("first");
				app.view(0);
			},
			prev: function fnPrevImageView() {
				console.log("prev");
				app.view(app.prevNumber());
			},
			next: function fnNextImageView() {
				console.log("next");
				app.view(app.nextNumber());
			},
			end: function fnEndImageView() {
				console.log("end");
				app.view(imageCount-1);
			},
			random: function fnRandomImageView() {
				console.log("random");
				app.view(getRandomInteger(0, imageCount-1));
			},
			resize: function resizeImage() {
				console.log("resize");
				var windowHeight = $(window).height();
				var windowWidth  = $(window).width();
				var navHeight = $('div#navDiv').height();
				var progressMarginBottom = 5;
				var imageDivPadding = 15;
				var imageDivHeight = windowHeight - navHeight - imageDivPadding * 2 - progressMarginBottom;
				$("#imageDiv").height(imageDivHeight).css({padding: imageDivPadding});
				$("#aperture").aperture({
					src: selectedImgUrl,
					outerMargin: "auto",
					width: (windowWidth - imageDivPadding * 2) + "px",
					height: (imageDivHeight) + "px",
					outerRadius: "0",
//					baseColor: (playSlide ? "#000" : "#fff"),
					color1: randomColor(0.5),
					color2: randomColor(0.5),
					color3: randomColor(0.5),
					color4: randomColor(0.5),
					innerCirclePadding: "0px",
					borderRadius: "50%"
				});
			},
			view: function fnViewImage(current) {
				console.log("view");
				selectedNumber = current;
				selectedImgUrl = imagepath + selectedNumber;
				setLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, selectedNumber);

				$("#aperture .circle-img").css("background-image", "url('"+selectedImgUrl+"')");
				$("#leftNo").html(app.prevNumber());
				$("#currNo").html(selectedNumber);
				$("#rightNo").html(app.nextNumber());
				$("#imageTitle").html(imageMap[selectedNumber]);
			},
			playCallback: function fnPlayImage(status) {
				console.log("play");
				if (status) {
					$(".circle").css({'background-color': '#000'});
					$("body").css("background", "#000");
					$(".label-info").css("background", "#000");
					$(".progress-bar").css("background", "#000");
					$(".progress").css("background-image", "linear-gradient(to bottom,#403a3a 0,#2f2626 100%)");
					$(".paging").hide();
				}
				else {
					$(".circle").css({'background-color': '#fff'});
					$("body").css("background", "#fff");
					$(".label-info").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
					$(".progress-bar").css("background-image", "linear-gradient(to bottom,#5bc0de 0,#31b0d5 100%)");
					$(".progress").css("background-image", "linear-gradient(to bottom,#ebebeb 0,#f5f5f5 100%)");
					$(".paging").show();
				}
			}
	};
	
	var addEventListener = function() {
		$(window).on("mousewheel DOMMouseScroll", function(e) {
			var delta = mousewheel(e);
			if (delta > 0) 
				app.prev();
		    else 	
				app.next();
		}).on("keyup", function(e) {
			var event = window.event || e;
			switch (event.keyCode) {
			case 37: // left
			case 40: // down
				app.prev(); break;
			case 39: // right
			case 38: // up
				app.next(); break;
			case 32: // space
				app.random(); break;
			case 13: // enter
				break;
			}
		}).on("resize", app.resize);
		
		$(".paging-first").on("click", app.first);
		$(".paging-prev" ).on("click", app.prev);
		$(".paging-next" ).on("click", app.next);
		$(".paging-end"  ).on("click", app.end);
		$("#imageTitle"  ).on("click", app.popup);
		$("#imageDiv"    ).on("click", function(event) {
			switch (event.which) {
			case 1: // left click
				app.next(); break;
			case 2: // middle click
				app.random(); break;
			case 3: // right click
				break;
			}
			event.stopImmediatePropagation();
			event.preventDefault();
			event.stopPropagation();
		});
		
	};
	
	var initModule = function() {
		
		$.getJSON(imagepath + "data.json" ,function(data) {
			imageCount = data['imageCount'];
			imageMap   = data['imageNameMap'];
			selectedNumber = parseInt(getLocalStorageItem(THUMBNAMILS_IMAGE_INDEX, getRandomInteger(0, imageCount-1)));

			$("#firstNo").html(0);
			$("#endNo").html(imageCount-1);

			// play engine
			timerEngine.init(app.random, 10, "#progressWrapper", {width: "100px", margin: "5px 0px", zIndex: "18"}, "Random Play", app.playCallback);

			app.view(selectedNumber);
			app.resize();
		});
	};
	
	return {
		init: function() {
			addEventListener();
			initModule();
		}
	};
	
}());

$(document).ready(apertureApp.init);