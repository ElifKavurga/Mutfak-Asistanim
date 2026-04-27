package com.mutfak_asistanim.controller;

import com.mutfak_asistanim.dto.DtoUser;
import com.mutfak_asistanim.dto.RegisterRequest;

public interface IRestRegisterController {
	
	public RootEntity<DtoUser> register(RegisterRequest input);
	
}
