package jk.kamoru.flayon.crazy.video;

import java.io.BufferedWriter;
import java.io.File;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;

import javax.annotation.PostConstruct;

import org.apache.commons.io.FileUtils;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.util.StopWatch;

import jk.kamoru.flayon.crazy.CrazyConfig;
import jk.kamoru.flayon.crazy.error.VideoException;
import jk.kamoru.flayon.crazy.util.ZipUtils;
import jk.kamoru.flayon.crazy.video.domain.History;
import jk.kamoru.flayon.crazy.video.domain.Video;
import jk.kamoru.flayon.crazy.video.service.HistoryService;
import jk.kamoru.flayon.crazy.video.service.VideoService;
import jk.kamoru.flayon.crazy.video.service.noti.NotiQueue;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@Component
public class VideoBatch {

	@Autowired CrazyConfig config;

	public static enum Option {
		/** moveWatchedVideo */ W, /** deleteLowerRankVideo */ R, /** deleteLowerScoreVideo */ S;
	}
	
	public static enum Type {
		/** InstanceVideoSource */ I, /** ArchiveVideoSource */ A, /** Backup */ B,
		/** moveWatchedVideo */ W, /** deleteLowerRankVideo */ R, /** deleteLowerScoreVideo */ S;
	}
	
	@Autowired   VideoService   videoService;
	@Autowired HistoryService historyService;

	public Boolean setBatchOption(Option option, boolean setValue) {
		try {
			switch (option) {
			case R:
				return config.setDeleteLowerRankVideo(setValue);
			case S:
				return config.setDeleteLowerScoreVideo(setValue);
			case W:
				return config.setMoveWatchedVideo(setValue);
			default:
				throw new VideoException("batch option key is invalid. k=" + option);
			}
		} finally {
			showProperties();
		}
	}

	public Boolean getBatchOption(Option option) {
		switch (option) {
		case R:
			return config.isDeleteLowerRankVideo();
		case S:
			return config.isDeleteLowerScoreVideo();
		case W:
			return config.isMoveWatchedVideo();
		default:
			throw new VideoException("batch option key is invalid. k=" + option);
		}
	}

	public void startBatch(Type type) {
		switch(type) {
		case I:
			batchInstanceVideoSource(); 
			break;
		case A:
			batchArchiveVideoSource(); 
			break;
		case B:
			try {
				backup();
				 break;
			} catch (IOException e) {
				throw new VideoException("batch.backup error", e);
			}
		case R:
			videoService.removeLowerRankVideo();
			break;
		case S:
			videoService.removeLowerScoreVideo();
			break;
		case W:
			videoService.moveWatchedVideo();
			break;
		default:
			throw new VideoException("unknown videobatch type : " + type);
		}
	}

	@PostConstruct
	private void showProperties() {
		log.info("Batch properties");
		log.info("  - batch.watched.moveVideo = {}", config.isMoveWatchedVideo());
		log.info("  - batch.rank.deleteVideo  = {}", config.isDeleteLowerRankVideo());
		log.info("  - batch.score.deleteVideo = {}", config.isDeleteLowerScoreVideo());
	}
	
	// cron every 1h
	@Scheduled(cron="0 0 */1 * * *")
	public synchronized void batchInstanceVideoSource() {
		log.info("BATCH Instance VideoSource START");
		StopWatch stopWatch = new StopWatch("Instance VideoSource Batch");

		log.info(" - delete lower rank video [{}]", config.isDeleteLowerRankVideo());
		if (config.isDeleteLowerRankVideo()) {
			stopWatch.start("delete lower rank");
			videoService.removeLowerRankVideo();
			stopWatch.stop();
		}
		
		log.info(" - delete lower score video [{}]", config.isDeleteLowerScoreVideo());
		if (config.isDeleteLowerScoreVideo()) {
			stopWatch.start("delete lower score");
			videoService.removeLowerScoreVideo();
			stopWatch.stop();
		}
		
		log.info(" - delete garbage file");
		stopWatch.start("delete garbage file");
		videoService.deleteGarbageFile();
		stopWatch.stop();
		
		log.info(" - arrange to same folder");
		stopWatch.start("arrange to same folder");
		videoService.arrangeVideo();
		stopWatch.stop();
		
		log.info(" - move watched video [{}]", config.isMoveWatchedVideo());
		if (config.isMoveWatchedVideo()) {
			stopWatch.start("move watched video");
			videoService.moveWatchedVideo();
			stopWatch.stop();
		}
		
		log.info(" - delete empty folder");
		videoService.deletEmptyFolder();

		videoService.reload(stopWatch);

		log.info("BATCH Instance VideoSource END\n\n{}", stopWatch.prettyPrint());
		
		NotiQueue.pushNoti("Instance VideoBatch end");
	}

	// cron every 2h 13m
	@Scheduled(cron="0 13 */2 * * *")
	public synchronized void batchArchiveVideoSource() {
		log.info("BATCH Archive VideoSource START");
		
		log.info(" - arrange to DateFormat folder");
		videoService.arrangeArchiveVideo();
		
		videoService.reloadArchive();

		log.info("BATCH Archive VideoSource END");

		NotiQueue.pushNoti("Archive VideoBatch end");
	}

	// fixedDelay per 1 min
	@Scheduled(fixedDelay = 1000 * 60) 
	public synchronized void moveFile() {
		log.trace("BATCH File move START {}", Arrays.toString(config.getMoveFilePaths()));

		// 설정이 안됬거나
		if (config.getMoveFilePaths() == null) {
			log.error("PATH_MOVE_FILE is not set");
			return;
		}
		// 값이 없으면 pass
		if (config.getMoveFilePaths().length == 0)
			return;
		
		// 3배수가 아니면
		if (config.getMoveFilePaths().length % 3 != 0) {
			log.error("PATH length is not 3 multiple", Arrays.toString(config.getMoveFilePaths()));
			return;
		}
		// 2,3번째가 폴더가 아니거나
		for (int i=0; i<config.getMoveFilePaths().length; i++) {
			if (i % 3 == 0)
				continue;
			else
				if (!new File(config.getMoveFilePaths()[i]).isDirectory()) {
					log.error("PATH [{}] is not Directory", config.getMoveFilePaths()[i]);
					return;
				}
		}
		for (int i=0; i<config.getMoveFilePaths().length;) {
			String ext = config.getMoveFilePaths()[i++];
			File from = new File(config.getMoveFilePaths()[i++]);
			File to   = new File(config.getMoveFilePaths()[i++]);
			for (File file : FileUtils.listFiles(from, new String[]{ext.toUpperCase(), ext.toLowerCase()}, false)) {
				try {
					log.info("Moving... {} to {}", file.getAbsolutePath(), to.getAbsolutePath());
					FileUtils.moveFileToDirectory(file, to, false);
				}
				catch (IOException e) {
					log.error("File to move", e);
				}
			}
		}
		
		log.trace("BATCH File move END");
	}
	
	// fixedRate per 13 min
	@Scheduled(fixedRate = 1000 * 60 * 13) 
	public synchronized void deletEmptyFolder() {
		log.info("BATCH - delete empty folder");
		videoService.deletEmptyFolder();

		NotiQueue.pushNoti("Delete empty folder end");
	}
	
//	@Scheduled(fixedDelay = 1000 * 60 * 60 * 24) // fixedDelay per day 
//	@PreDestroy
	// cron every 2h 13m
	@Scheduled(cron="0 0 0 * * *")
	public synchronized void backup() throws IOException {
		
		if (StringUtils.isBlank(config.getBackupPath())) {
			log.warn("BATCH - backup path not set");
			return;
		}
		log.info("BATCH - backup to {}", config.getBackupPath());
		
		File backupPath = new File(config.getBackupPath());
		if (!backupPath.exists())
			backupPath.mkdirs();

		final String csvHeader = "Studio, Opus, Title, Actress, Released, Rank, Fullname";
		final String csvFormat = "\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",%s,\"%s\"";

		// video list backup to csv
		List<Video>        videoList =   videoService.getVideoList(true, false);
		List<Video> archiveVideoList =   videoService.getVideoList(false, true);
		List<History>    historyList = historyService.getDeduplicatedList();
		List<String>    instanceList = new ArrayList<>();
		List<String>     archiveList = new ArrayList<>();

		// instance
		instanceList.add(csvHeader);
		for (Video video : videoList)
			instanceList.add(String.format(csvFormat, video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), video.getRank(), video.getFullname()));
		// archive
		archiveList.add(csvHeader);
		for (Video video : archiveVideoList)
			archiveList.add(String.format(csvFormat, video.getStudio().getName(), video.getOpus(), video.getTitle(), video.getActressName(), video.getReleaseDate(), "", video.getFullname()));
		for (History history : historyList) {
			String opus = history.getOpus();
			boolean foundInArchive = false;
			for (Video video : archiveVideoList) {
				if (video.getOpus().equals(opus)) {
					foundInArchive = true;
					break;
				}
			}
			if (!foundInArchive)
				archiveList.add(String.format(csvFormat, "", history.getOpus(), "", "", "", "", history.getDesc()));
		}
		writeFileWithUTF8BOM(new File(backupPath, VIDEO.BACKUP_INSTANCE_FILENAME), instanceList); 
		log.info("BATCH - backup. {} {}", VIDEO.BACKUP_INSTANCE_FILENAME, instanceList.size());
		writeFileWithUTF8BOM(new File(backupPath, VIDEO.BACKUP_ARCHIVE_FILENAME),  archiveList);
		log.info("BATCH - backup. {} {}", VIDEO.BACKUP_ARCHIVE_FILENAME, archiveList.size());
		
		// history backup
		FileUtils.copyFileToDirectory(new File(config.getStoragePath(), VIDEO.HISTORY_LOG_FILENAME), backupPath);
		log.info("BATCH - backup. {}", VIDEO.HISTORY_LOG_FILENAME);
		
		// tag data backup
		FileUtils.copyFileToDirectory(new File(config.getStoragePath(), VIDEO.TAG_DATA_FILENAME), backupPath);
		log.info("BATCH - backup. {}", VIDEO.TAG_DATA_FILENAME);
		
		// zip to cover, info, subtitles file on instance
		File backupTempPath = new File(config.getQueuePath(), "backuptemp");
		if (backupTempPath.isDirectory())
			FileUtils.cleanDirectory(backupTempPath);
		else
			Files.createDirectory(backupTempPath.toPath());
		for (Video video : videoList)
			for (File file : video.getFileWithoutVideo())
				if (file != null && file.exists())
					FileUtils.copyFileToDirectory(file, backupTempPath, false);
		ZipUtils.zip(backupTempPath, backupPath, VIDEO.BACKUP_FILE_FILENAME, VIDEO.ENCODING, true);
		FileUtils.deleteDirectory(backupTempPath);
		log.info("BATCH - backup. {}", VIDEO.BACKUP_FILE_FILENAME);
		
		// _info folder backup to zip
		ZipUtils.zip(new File(config.getStoragePath(), "_info"), backupPath, VIDEO.BACKUP_INFO_FILENAME, VIDEO.ENCODING, true);
		log.info("BATCH - backup. {}", VIDEO.BACKUP_INFO_FILENAME);

		NotiQueue.pushNoti("Backup completed");
	}
	
	private void writeFileWithUTF8BOM(File file, Collection<String> lines) {
		try (BufferedWriter bufferedWriter = Files.newBufferedWriter(file.toPath(), Charset.forName("UTF-8"), StandardOpenOption.CREATE, StandardOpenOption.WRITE)) {
			bufferedWriter.write(65279); // UTF-8의 BOM인 "EF BB BF"를 UTF-16BE 로 변환
			for (String line : lines) {
				bufferedWriter.write(line);
				bufferedWriter.newLine();
			}
			bufferedWriter.flush();
		} catch (IOException e) {
			throw new VideoException("Fail to writeFileWithUTF8BOM", e);
		}
		
	}
}
