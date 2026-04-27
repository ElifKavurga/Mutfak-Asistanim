package com.mutfak_asistanim.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoUser extends DtoBase {
	
	private String firstName;
	
	private String lastName;
	
	private String username;
	
	private String password;
	
	private String email;
	
}