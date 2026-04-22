package com.mutfak_asistanim.enums;

import lombok.Getter;

@Getter
public enum MessageType {
	
	NO_RECORD_EXIST("1004", "No record found!"),
	GENERAL_EXCEPTION("9999", "A general error occurred!");
	
	private String code;
	private String message;
	
	MessageType(String code, String message){
		this.code=code;
		this.message=message;
	}
	
}
