package com.mutfak_asistanim.handler;


import java.util.Date;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Exception <E> {
	
	private String path;
	
	private Date createdAt;
	
	private String hostName;
	
	private E message;
	
}
