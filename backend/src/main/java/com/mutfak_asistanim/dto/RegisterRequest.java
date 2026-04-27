package com.mutfak_asistanim.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class RegisterRequest {
	
	@NotEmpty
	private String firstName;
	
	@NotEmpty
	private String lastName;
	
	@NotEmpty
	private String username;
	
	@NotEmpty
	private String password;
	
	@Email
	@NotEmpty
	private String email;
	
}
