package com.mutfak_asistanim.service;

import com.mutfak_asistanim.dto.AuthenticateRequest;
import com.mutfak_asistanim.dto.AuthenticateResponse;
import com.mutfak_asistanim.dto.RefreshTokenRequest;

public interface IAuthenticationService {
	
	public AuthenticateResponse authenticate(AuthenticateRequest input);
	
	public AuthenticateResponse refreshToken(RefreshTokenRequest input);
	
}
