package jk.kamoru.flayon.crazy;

public abstract class NotFoundException extends CrazyException {

	private static final long serialVersionUID = CRAZY.SERIAL_VERSION_UID;

	public NotFoundException(String msg, KIND kind) {
		super(msg, kind);
	}

	public NotFoundException(String msg, Throwable cause, KIND kind) {
		super(msg, cause, kind);
	}

}
