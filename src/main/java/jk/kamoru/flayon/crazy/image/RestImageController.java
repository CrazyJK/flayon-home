package jk.kamoru.flayon.crazy.image;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jk.kamoru.flayon.crazy.image.service.ImageService;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.VideoService;

@RestController
@RequestMapping("/rest/image")
public class RestImageController {

	@Autowired VideoService videoService;
	@Autowired ImageService imageService;

	@RequestMapping("/data")
	public Map<String, Object> getData() {
		Map<String, Object> data = new HashMap<>();
		data.put("imageCount",   imageService.getImageSourceSize());
		data.put("imageNameMap", imageService.getImageNameMap());
		int index = 0;
		Map<Integer, String> map = new HashMap<>();
		for (Video video : videoService.getVideoList()) {
			map.put(index++, video.getOpus());
		}
		data.put("coverCount",   index);
		data.put("coverNameMap", map);
		return data;
	}

}