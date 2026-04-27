package com.mutfak_asistanim.controller;

import com.mutfak_asistanim.dto.AuthenticateRequest;
import com.mutfak_asistanim.dto.AuthenticateResponse;
import com.mutfak_asistanim.dto.RefreshTokenRequest;

public interface IRestAuthenticationController {
	
	public RootEntity<AuthenticateResponse> authenticate(AuthenticateRequest input);
	
	public RootEntity<AuthenticateResponse> refreshToken(RefreshTokenRequest input);
}
