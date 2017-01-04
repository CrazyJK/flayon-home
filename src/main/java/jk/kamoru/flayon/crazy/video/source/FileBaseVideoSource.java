package jk.kamoru.flayon.crazy.video.source;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import javax.annotation.PostConstruct;
import javax.inject.Inject;
import javax.inject.Provider;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.ArrayUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.Utils;
import jk.kamoru.flayon.crazy.video.ActressNotFoundException;
import jk.kamoru.flayon.crazy.video.StudioNotFoundException;
import jk.kamoru.flayon.crazy.video.VIDEO;
import jk.kamoru.flayon.crazy.video.VideoNotFoundException;
import jk.kamoru.flayon.crazy.video.domain.Actress;
import jk.kamoru.flayon.crazy.video.domain.Studio;
import jk.kamoru.flayon.crazy.video.domain.TitlePart;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.util.VideoUtils;
	

public class FileBaseVideoSource implements VideoSource {
	
	protected static final Logger logger = LoggerFactory.getLogger(FileBaseVideoSource.class);

	// domain map
	private Map<String, Video>     videoMap	= new HashMap<>();
	private Map<String, Studio>   studioMap	= new HashMap<>();
	private Map<String, Actress> actressMap = new HashMap<>();
	
	// Domain provider
	@Inject Provider<Video>     videoProvider;
	@Inject Provider<Studio>   studioProvider;
	@Inject Provider<Actress> actressProvider;

	// logic variables
	private static boolean firstLoad = false;
	private static boolean loading = false;
	
	// property
	private boolean isArchive;
	private String torrentPath;
	private String[] paths;

	public FileBaseVideoSource(boolean isArchive, String torrentPath, String...paths) {
		this.isArchive = isArchive;
		this.torrentPath = torrentPath;
		this.paths = paths;
		logger.info("init {}, {}, {}", toTypeString(), torrentPath, ArrayUtils.toString(paths, "IS NULL"));
	}
	
	private String toTypeString() {
		return isArchive ? "Archive" : "Instance";
	}
	
	/**
	 * 기존에 만든적이 없으면, video source를 로드를 호출한다.
	 */
	private final void videoSource() {
		if (firstLoad) {
			if (loading) {
				do {
					try {
						logger.warn("loading...");
						Thread.sleep(500);
					} catch (InterruptedException e) {
						logger.error("sleep error", e);
						break;
					}
				} while(loading);
			}
		}
		else {
			load(null);
		}
	}
	
	private synchronized void load(StopWatch stopWatch) {
		logger.debug("Start {} video source load", toTypeString());
		boolean standalone = false;
		if (stopWatch == null) {
			standalone = true;
			stopWatch = new StopWatch(toTypeString() + " VideoSource load");
		}
		
		firstLoad = true;
		loading = true;

		List<String> wrongFileNames = new ArrayList<>();
		
		// find files
		stopWatch.start("load : listFiles");
		Collection<File> files = Utils.listFiles(paths, null, true);
		stopWatch.stop();
		logger.debug("    total found file {}", files.size());

		videoMap.clear();
		studioMap.clear();
		actressMap.clear();

		// domain create & data source
		stopWatch.start("load : make Video object in " + files.size() + " files");
		for (File file : files) {
			String filename = file.getName();
			String     name = Utils.getNameExceptExtension(file);
			String      ext = Utils.getExtension(file).toLowerCase();

			try {
				// Unnecessary file exclusion
				if (ext.equals(VIDEO.EXT_ACTRESS) || ext.equals(VIDEO.EXT_STUDIO)
						|| filename.equals(VIDEO.HISTORY_LOG_FILENAME) 
						|| filename.equals(VIDEO.MAC_NETWORKSTORES)
						|| filename.equals(VIDEO.WINDOW_DESKTOPINI)
						|| filename.equals(VIDEO.TAG_DATA_FILENAME)
						|| filename.equals(VIDEO.WRONG_FILENAME)) {
					continue;
				}
				
				/*  1       2     3      4        5       6
				   [studio][opus][title][actress][release]etc...*/
				TitlePart titlePart = new TitlePart(name);
				if (titlePart.isCheck()) {
					logger.warn("wrong file : {}, {}, {}", file.getCanonicalPath(), titlePart.getCheckDescShort(), titlePart.getStyleString());
					wrongFileNames.add(String.format("[%s] : %s, %s, %s", file.getPath(), file.getName(), titlePart.getCheckDescShort(), titlePart.getStyleString()));
					continue;
				}
				
				Video video = videoMap.get(titlePart.getOpus());
				if (video == null) {
					video = videoProvider.get();
					video.setTitlePart(titlePart);
					video.setArchive(isArchive);
					videoMap.put(video.getOpus(), video);
				}
				// set video File
				if (VIDEO.SUFFIX_VIDEO.contains(ext))
					video.addVideoFile(file);
				else if (VIDEO.SUFFIX_IMAGE.contains(ext))
					video.setCoverFile(file);
				else if (VIDEO.SUFFIX_SUBTITLES.contains(ext))
					video.addSubtitlesFile(file);
				else if (VIDEO.EXT_INFO.equalsIgnoreCase(ext))
					video.setInfoFile(file);
				else
					video.addEtcFile(file);
				
				Studio studio = studioMap.get(titlePart.getStudio().toUpperCase());
				if (studio == null) {
					studio = studioProvider.get();
					studio.setName(titlePart.getStudio());
					studioMap.put(studio.getName().toUpperCase(), studio);
				}
				// inject reference
				studio.addVideo(video);
				video.setStudio(studio);
				
				for (String actressName : StringUtils.split(titlePart.getActress(), ",")) {
					actressName = VideoUtils.trimBlank(actressName);
					String forwardActressName = VideoUtils.sortForwardName(actressName);
					
					Actress actress = actressMap.get(forwardActressName);
					if (actress == null) {
						actress = actressProvider.get();
						actress.setName(actressName);
						actressMap.put(forwardActressName, actress);
					}
					// inject reference
					actress.addVideo(video);
					actress.addStudio(studio);

					studio.addActress(actress);
					video.addActress(actress);
				}
			}
			catch (Exception e) {
				logger.error("File loading error : " + filename, e);
			}
		}
		stopWatch.stop();

		stopWatch.start("load : save wrong filename");
		try {
			if (wrongFileNames.size() > 0)
				FileUtils.writeLines(new File(paths[0], VIDEO.WRONG_FILENAME), VIDEO.ENCODING, wrongFileNames.stream().sorted().collect(Collectors.toList()), false);
		} catch (IOException e) {
			logger.error("write wrong file name fail", e);
		}
		stopWatch.stop();
		
		loading = false;
		if (standalone)
			logger.info("{} video source load. {} videos\n\n{}", toTypeString(), videoMap.size(), stopWatch.prettyPrint());
		else
			logger.info("{} video source load. {} videos", toTypeString(), videoMap.size());
	}

	@Override
	public void reload(StopWatch stopWatch) {
		load(stopWatch);
		matchTorrent();
	}

	@Override
	@PostConstruct
	public void reload() {
		reload(null);
	}

	private synchronized void matchTorrent() {
		// find torrents
		if (torrentPath != null) {
			Collection<File> foundTorrent = FileUtils.listFiles(new File(torrentPath), 
					String.format("%s,%s", CRAZY.SUFFIX_TORRENT.toUpperCase(), CRAZY.SUFFIX_TORRENT.toLowerCase()).split(","), true);
			logger.debug("Scan torrents file {}, found {}", torrentPath, foundTorrent.size());
			
			for (Video video : getVideoList()) {
				video.resetTorrents();
				for (File file : foundTorrent) {
					if (StringUtils.contains(file.getName(), video.getOpus())) {
						video.addTorrents(file);
					}
				}
			}
		}
	}
	
	@Override
	public Map<String, Video> getVideoMap() {
		videoSource();
		return videoMap;
	}
	@Override
	public Map<String, Studio> getStudioMap() {
		videoSource();
		return studioMap;
	}
	@Override
	public Map<String, Actress> getActressMap() {
		videoSource();
		return actressMap;
	}
	@Override
	public Video getVideo(String opus) {
		videoSource();
		if (videoMap.containsKey(opus.toUpperCase()))
			return videoMap.get(opus.toUpperCase());
		else
			if (isArchive)
				return null;
			else
				throw new VideoNotFoundException(opus);
	}
	@Override
	public Studio getStudio(String name) {
		videoSource();
		if (studioMap.containsKey(name.toUpperCase()))
			return studioMap.get(name.toUpperCase());
		else
			if (isArchive)
				return new Studio();
			else
				throw new StudioNotFoundException(name);
	}
	@Override
	public Actress getActress(String name) {
		videoSource();
		if (actressMap.containsKey(VideoUtils.sortForwardName(name)))
			return actressMap.get(VideoUtils.sortForwardName(name));
		else
			if (isArchive)
				return new Actress();
			else
				throw new ActressNotFoundException(name);
	}
	@Override
	public List<Video> getVideoList() {
		videoSource();
		return new ArrayList<Video>(videoMap.values());
	}
	@Override
	public List<Studio> getStudioList() {
		videoSource();
		return new ArrayList<Studio>(studioMap.values());
	}
	@Override
	public List<Actress> getActressList() {
		videoSource();
		return new ArrayList<Actress>(actressMap.values());
	}
	@Override
	public void moveVideo(String opus, String destPath) {
		videoSource();
		videoMap.get(opus.toUpperCase()).move(destPath);
	}
	@Override
	public void arrangeVideo(String opus) {
		videoSource();
		videoMap.get(opus.toUpperCase()).arrange();
	}
	@Override
	public void removeVideo(String opus) {
		videoSource();
		videoMap.get(opus.toUpperCase()).removeVideo();
		videoMap.remove(opus.toUpperCase());
	}
	@Override
	public void deleteVideo(String opus) {
		videoSource();
		videoMap.get(opus.toUpperCase()).deleteVideo();
		videoMap.remove(opus.toUpperCase());
	}

}
