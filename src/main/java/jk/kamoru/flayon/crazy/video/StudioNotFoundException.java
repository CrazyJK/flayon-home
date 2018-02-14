package jk.kamoru.flayon.crazy.video;

import jk.kamoru.flayon.crazy.CRAZY;
import jk.kamoru.flayon.crazy.NotFoundException;

public class StudioNotFoundException extends NotFoundException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;

	public StudioNotFoundException(String studioName, Throwable cause) {
		super("Studio [" + studioName + "] not found", cause, KIND.StudioNotFound);
	}

	public StudioNotFoundException(String studioName) {
		super("Studio [" + studioName + "] not found", KIND.StudioNotFound);
	}

}
