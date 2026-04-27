package com.mutfak_asistanim.dto;

import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AuthenticateRequest {
	
	@NotEmpty
	private String username;
	
	@NotEmpty
	private String password;
 
}
