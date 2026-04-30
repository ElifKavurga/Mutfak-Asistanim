package com.mutfak_asistanim.dto;

import java.time.LocalDate;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoNotification extends DtoBase {

	private String message;
	
	private LocalDate sendingDate;
	
	private Boolean isRead;
	
	private Long inventoryId;
	
	private String productName;
}
