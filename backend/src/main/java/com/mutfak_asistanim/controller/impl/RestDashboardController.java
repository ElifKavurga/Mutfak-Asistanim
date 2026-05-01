package com.mutfak_asistanim.controller.impl;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import com.mutfak_asistanim.controller.IRestDashboardController;
import com.mutfak_asistanim.controller.RestBaseController;
import com.mutfak_asistanim.controller.RootEntity;
import com.mutfak_asistanim.dto.DtoDashboard;
import com.mutfak_asistanim.service.IDashboardService;

@RestController
public class RestDashboardController extends RestBaseController implements IRestDashboardController {
	
	@Autowired
	private IDashboardService iDashboardService;
	
	@GetMapping("/dashboard")
	@Override
	public RootEntity<DtoDashboard> getDashboard() {
		return ok(iDashboardService.getDashboard());
	}

}
