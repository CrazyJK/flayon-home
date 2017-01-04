package jk.kamoru.flayon.crazy;

import jk.kamoru.flayon.boot.FlayOnApplication;

public interface CRAZY {

	public static final long SERIAL_VERSION_UID = FlayOnApplication.SERIAL_VERSION_UID;

	public static final String SUFFIX_VIDEO = "avi,mpg,mkv,wmv,mp4,mov,rmvb";

	public static final String SUFFIX_IMAGE = "jpg,jpeg,png,gif";
	
	public static final String SUFFIX_SUBTITLES = "smi,srt,ass,smil";

	public static final String SUFFIX_TORRENT = "torrent";

	public static final String STAGE = "Stage";
	
	public static final String COVER = "Cover";
	
	public static final String REGEX_DATE = "^((19|20)\\d\\d).(0?[1-9]|1[012]).(0?[1-9]|[12][0-9]|3[01])$";

	public static final String REGEX_DATE_SIMPLE = "\\d{4}.\\d{2}.\\d{2}";

	public static final String REGEX_KOREAN = ".*[ㄱ-ㅎㅏ-ㅣ가-힣]+.*";

	public static final String REGEX_ENGLISH = " ^[a-zA-Z]*$";
	
	public static final String ARCHIVE = "Archive";

	public static final String ENCODING = "UTF-8";

	public static final String LINE = System.getProperty("line.separator");
}
