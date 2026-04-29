package com.mutfak_asistanim.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

import com.mutfak_asistanim.enums.UnitType;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DtoInventory extends DtoBase {
	
	private BigDecimal quantity;
	
	private UnitType unitType;
	
	private LocalDate expirationDate;
		
	private DtoProduct product;	
}
