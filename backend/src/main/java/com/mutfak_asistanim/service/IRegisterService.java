package com.mutfak_asistanim.service;

import com.mutfak_asistanim.dto.DtoUser;
import com.mutfak_asistanim.dto.RegisterRequest;

public interface IRegisterService {
	
	public DtoUser register(RegisterRequest input);
	
}
