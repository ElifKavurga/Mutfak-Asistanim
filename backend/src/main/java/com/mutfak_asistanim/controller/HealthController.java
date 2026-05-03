package com.mutfak_asistanim.controller;

import java.util.LinkedHashMap;
import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HealthController {

	@GetMapping("/health")
	public Map<String, Object> health() {
		Map<String, Object> response = new LinkedHashMap<>();
		response.put("status", "ok");
		response.put("service", "backend");
		return response;
	}
}
