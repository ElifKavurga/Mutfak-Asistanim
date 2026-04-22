package com.mutfak_asistanim.exception;

public class BaseException extends RuntimeException {
	
	public BaseException(ErrorMessage errorMessage) {
		super(errorMessage.prepareErrorMessage());
	}
	
}
